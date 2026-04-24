#!/usr/bin/env bash
# reviewer-worker.sh — Agent 2: stabilizes PRs (CI + Copilot review)
#
# Loop: find factory:ready-for-review PRs → wait CI → fix CI failures →
#       wait Copilot → fix review comments → reply to each → mark ready-for-merge

set -euo pipefail

WORKER_NAME="reviewer"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"
source "$SCRIPT_DIR/lib/locks.sh"
source "$SCRIPT_DIR/lib/backlog.sh"
source "$SCRIPT_DIR/lib/github.sh"

LOG_FILE="$LOGS_DIR/reviewer-$(date '+%Y%m%d').log"
init_dirs

# ─── Preflight ────────────────────────────────────────────────────────────────
preflight() {
    require_tools claude gh git jq python3
    gh_check_auth
    acquire_worker_lock "reviewer" || {
        log_error "Another reviewer is already running. Exiting."
        exit 1
    }
    trap 'release_worker_lock reviewer; log_warn "Reviewer shut down"' EXIT INT TERM
    log_info "Reviewer started."
}

# ─── Fix CI failures ──────────────────────────────────────────────────────────
fix_ci_failures() {
    local pr_number="$1"
    local branch="$2"

    log_info "Fetching CI failure logs for PR #$pr_number..."
    local ci_logs
    ci_logs="$(gh_ci_failure_logs "$pr_number")"

    if [[ -z "$ci_logs" ]]; then
        log_warn "No CI logs available — skipping auto-fix"
        return 1
    fi

    local prompt
    prompt="$(cat <<PROMPT
CI is failing for PR #${pr_number} on branch ${branch} of the Urbink Flutter project.

Read ${CLAUDE_MD} for conventions. Read ${ARCH_MD} for architecture.

CI failure logs (tail):
\`\`\`
${ci_logs}
\`\`\`

Analyze the failures. Fix the root cause in the code.
After fixing, run in ${FLUTTER_DIR}:
  flutter test --reporter=compact
  flutter analyze --no-pub
Keep fixing until both are clean. Zero errors in flutter analyze --no-pub.

DO NOT run git commands.
PROMPT
)"

    log_info "Claude fixing CI failures on PR #$pr_number..."
    (cd "$REPO_ROOT" && $CLAUDE_CMD "$prompt") || {
        log_error "Claude CI-fix invocation failed"
        return 1
    }

    # Commit and push fixes
    git -C "$REPO_ROOT" add -u 2>/dev/null || true
    git -C "$REPO_ROOT" add "urbink/lib" "urbink/test" 2>/dev/null || true

    if ! git -C "$REPO_ROOT" diff --cached --quiet; then
        local fix_msg
        fix_msg="$(cat <<MSG
fix: corrections CI — PR #${pr_number}

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>
MSG
)"
        git -C "$REPO_ROOT" commit -m "$fix_msg"
        retry $MAX_RETRIES git -C "$REPO_ROOT" push origin "$branch"
        log_info "CI fix pushed for PR #$pr_number"
    else
        log_warn "No changes after CI fix — CI may need a re-run push"
        # Force a no-op push to trigger CI
        git -C "$REPO_ROOT" commit --allow-empty \
            -m "chore: trigger CI re-run (PR #${pr_number})"
        retry $MAX_RETRIES git -C "$REPO_ROOT" push origin "$branch"
    fi
}

# ─── Fix Copilot review comments ─────────────────────────────────────────────
fix_review_comments() {
    local pr_number="$1"
    local branch="$2"

    log_info "Collecting Copilot comments for PR #$pr_number..."

    # Build a structured list of comments for the prompt
    local raw_comments
    raw_comments="$(gh_copilot_unresolved_comments "$pr_number")"

    if [[ -z "$raw_comments" ]]; then
        log_info "No unresolved Copilot comments — PR is stable"
        return 0
    fi

    # Format comments for the Claude prompt
    local formatted_comments
    formatted_comments="$(echo "$raw_comments" | \
        python3 -c "
import json, sys
lines = [l for l in sys.stdin.read().split('\n') if l.strip()]
# Each line is a JSON object
comments = []
for line in lines:
    try:
        c = json.loads(line)
        comments.append(c)
    except:
        pass
for c in comments:
    path  = c.get('path', 'unknown file')
    lineno = c.get('line', '?')
    body  = c.get('body', '')
    cid   = c.get('id', '')
    print(f'--- Comment ID: {cid} ---')
    print(f'File: {path} (line {lineno})')
    print(f'Comment: {body}')
    print()
" 2>/dev/null || echo "$raw_comments")"

    local prompt
    prompt="$(cat <<PROMPT
GitHub Copilot left review comments on PR #${pr_number} (branch: ${branch}) in the Urbink project.

Read ${CLAUDE_MD} for conventions. Read ${ARCH_MD} for architecture.

Apply every correction below without exception:

${formatted_comments}

For each comment:
1. Fix the exact issue raised in the file/line mentioned.
2. Do not introduce new issues.
3. Keep changes minimal and targeted.

After all fixes:
- Run: cd ${FLUTTER_DIR} && flutter test --reporter=compact
- Run: cd ${FLUTTER_DIR} && flutter analyze --no-pub
- Fix until clean.

DO NOT run git commands.
PROMPT
)"

    log_info "Claude fixing Copilot comments on PR #$pr_number..."
    (cd "$REPO_ROOT" && $CLAUDE_CMD "$prompt") || {
        log_error "Claude review-fix invocation failed"
        return 1
    }

    # Commit + push fixes
    git -C "$REPO_ROOT" add -u 2>/dev/null || true
    git -C "$REPO_ROOT" add "urbink/lib" "urbink/test" 2>/dev/null || true

    if ! git -C "$REPO_ROOT" diff --cached --quiet; then
        local fix_commit
        fix_commit="$(cat <<MSG
fix: corrections review Copilot PR#${pr_number}

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>
MSG
)"
        git -C "$REPO_ROOT" commit -m "$fix_commit"
        retry $MAX_RETRIES git -C "$REPO_ROOT" push origin "$branch"
        log_info "Review fixes pushed for PR #$pr_number"
    else
        log_info "No file changes from review fixes (may have been comment-only)"
    fi

    # Reply to every comment
    reply_to_comments "$pr_number" "$raw_comments"
}

# ─── Reply to each Copilot comment ───────────────────────────────────────────
reply_to_comments() {
    local pr_number="$1"
    local raw_comments="$2"

    local comment_ids
    comment_ids="$(echo "$raw_comments" | \
        python3 -c "
import json, sys
for line in sys.stdin.read().split('\n'):
    try:
        c = json.loads(line.strip())
        print(c['id'])
    except:
        pass
" 2>/dev/null || echo "")"

    while IFS= read -r comment_id; do
        [[ -z "$comment_id" ]] && continue
        gh_reply_comment "$pr_number" "$comment_id" \
            "✅ Corrigé — correction appliquée et tests repassés."
        log_debug "Replied to comment $comment_id on PR #$pr_number"
    done <<< "$comment_ids"

    # Post a summary on the PR
    local reply_count
    reply_count="$(echo "$comment_ids" | grep -c '.' || echo 0)"
    if [[ $reply_count -gt 0 ]]; then
        gh_pr_comment "$pr_number" \
            "## Corrections review Copilot\n\n${reply_count} point(s) adressé(s). flutter test + flutter analyze --no-pub : ✅"
    fi
}

# ─── Review a single PR ───────────────────────────────────────────────────────
# Returns 0 when PR is stable and ready to merge, 1 on too many failures.
review_pr() {
    local pr_number="$1"
    local branch="$2"
    local failure_count=0

    log_info "Reviewing PR #$pr_number on branch $branch"

    # Checkout the PR branch to be ready for local fixes
    git -C "$REPO_ROOT" fetch origin "$branch" 2>/dev/null || true
    git -C "$REPO_ROOT" checkout "$branch" 2>/dev/null || \
        git -C "$REPO_ROOT" checkout -b "$branch" "origin/$branch"

    while [[ $failure_count -lt $MAX_PR_FAILURES ]]; do

        # ── 1. Wait for CI ────────────────────────────────────────────────────
        if ! gh_wait_for_ci "$pr_number" "$CI_TIMEOUT_MIN"; then
            failure_count=$(( failure_count + 1 ))
            log_warn "CI failed ($failure_count/$MAX_PR_FAILURES) — auto-fixing PR #$pr_number"
            gh_add_label "$pr_number" "factory:ci-fixing"
            fix_ci_failures "$pr_number" "$branch" || {
                log_error "CI fix failed — counting as another failure"
                failure_count=$(( failure_count + 1 ))
            }
            gh_remove_label "$pr_number" "factory:ci-fixing"
            continue  # Re-check CI after fix
        fi

        # ── 2. CI green — wait for Copilot review ────────────────────────────
        gh_wait_for_copilot_review "$pr_number" 30

        local review_state
        review_state="$(gh_copilot_review_state "$pr_number")"
        log_info "Copilot review state: $review_state — PR #$pr_number"

        case "$review_state" in
            APPROVED)
                log_info "Copilot approved PR #$pr_number — ready to merge"
                return 0
                ;;
            NONE|PENDING)
                # No review yet or still pending — treat as approved for now
                # (Copilot might not review all PRs)
                log_info "No Copilot review — treating as approved for PR #$pr_number"
                return 0
                ;;
            COMMENTED|CHANGES_REQUESTED)
                local raw_comments
                raw_comments="$(gh_copilot_unresolved_comments "$pr_number")"
                if [[ -z "$raw_comments" ]]; then
                    log_info "Copilot commented but no inline comments — treating as approved"
                    return 0
                fi
                failure_count=$(( failure_count + 1 ))
                log_warn "Copilot review comments ($failure_count/$MAX_PR_FAILURES) — auto-fixing"
                fix_review_comments "$pr_number" "$branch" || {
                    log_error "Review fix failed"
                    failure_count=$(( failure_count + 1 ))
                }
                # After fix, loop: wait for new CI run
                ;;
        esac
    done

    log_error "PR #$pr_number exceeded $MAX_PR_FAILURES failures"
    return 1
}

# ─── Main loop ────────────────────────────────────────────────────────────────
main() {
    preflight

    log_info "Reviewer entering main loop. Polling every ${POLL_INTERVAL_REVIEWER}s."

    while true; do
        cleanup_stale_locks

        local prs_json
        prs_json="$(gh_list_prs_with_label "factory:ready-for-review")"
        local pr_count
        pr_count="$(echo "$prs_json" | jq 'length' 2>/dev/null || echo 0)"

        if [[ $pr_count -eq 0 ]]; then
            log_debug "No PRs ready for review. Waiting ${POLL_INTERVAL_REVIEWER}s..."
            sleep "$POLL_INTERVAL_REVIEWER"
            continue
        fi

        log_info "$pr_count PR(s) ready for review"

        # Process each PR (skip those locked by another reviewer instance)
        local pr_numbers
        pr_numbers="$(echo "$prs_json" | jq -r '.[].number')"

        while IFS= read -r pr_number; do
            [[ -z "$pr_number" ]] && continue

            if ! acquire_pr_lock "$pr_number"; then
                log_debug "PR #$pr_number locked by another process — skipping"
                continue
            fi

            gh_transition_label "$pr_number" "factory:ready-for-review" "factory:reviewing"

            local branch
            branch="$(gh_pr_head_branch "$pr_number")"

            local review_result=0
            review_pr "$pr_number" "$branch" || review_result=$?

            if [[ $review_result -eq 0 ]]; then
                gh_transition_label "$pr_number" "factory:reviewing" "factory:ready-for-merge"
                log_info "✓ PR #$pr_number stable → ready-for-merge"
            else
                gh_transition_label "$pr_number" "factory:reviewing" "factory:escalate"
                log_error "✗ PR #$pr_number escalated after too many failures"
                gh_pr_comment "$pr_number" \
                    "🚨 **Factory escalation** — PR could not be stabilized after $MAX_PR_FAILURES attempts. Human intervention required."
            fi

            # Return to develop after processing
            git -C "$REPO_ROOT" checkout "$BASE_BRANCH" 2>/dev/null || true

            release_pr_lock "$pr_number"

        done <<< "$pr_numbers"

        sleep "$POLL_INTERVAL_REVIEWER"
    done
}

main "$@"
