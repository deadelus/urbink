#!/usr/bin/env bash
# merge-worker.sh — Agent 3: merges stable PRs into develop
#
# Loop: find factory:ready-for-merge PRs → verify state → merge →
#       handle conflicts (Claude resolves) → cleanup → sync develop

set -euo pipefail

WORKER_NAME="merger"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"
source "$SCRIPT_DIR/lib/locks.sh"
source "$SCRIPT_DIR/lib/backlog.sh"
source "$SCRIPT_DIR/lib/github.sh"

LOG_FILE="$LOGS_DIR/merger-$(date '+%Y%m%d').log"
init_dirs

# ─── Preflight ────────────────────────────────────────────────────────────────
preflight() {
    require_tools claude gh git jq python3
    gh_check_auth
    acquire_worker_lock "merger" || {
        log_error "Another merger is already running. Exiting."
        exit 1
    }
    trap 'release_worker_lock merger; log_warn "Merger shut down"' EXIT INT TERM
    log_info "Merger started."
}

# ─── Conflict resolution via Claude ──────────────────────────────────────────
resolve_conflicts_with_claude() {
    local pr_number="$1"
    local branch="$2"

    # List conflicted files
    local conflicted_files
    conflicted_files="$(git -C "$REPO_ROOT" diff --name-only --diff-filter=U 2>/dev/null || echo "")"

    if [[ -z "$conflicted_files" ]]; then
        log_warn "No conflicted files found despite merge conflict"
        return 1
    fi

    log_info "Conflicted files:\n$conflicted_files"

    local prompt
    prompt="$(cat <<PROMPT
Merge conflict on branch ${branch} (PR #${pr_number}) while merging ${BASE_BRANCH} into it.

Read ${CLAUDE_MD} for conventions. Read ${ARCH_MD} for architecture.

Conflicted files:
${conflicted_files}

For each conflicted file:
1. Read the file — it will have conflict markers (<<<<<<<, =======, >>>>>>>).
2. Resolve the conflict by keeping the semantically correct code from both sides.
3. Respect all CLAUDE.md conventions.
4. Ensure the file is syntactically valid Dart after resolution.

After resolving ALL conflicts:
- Run: cd ${FLUTTER_DIR} && flutter test --reporter=compact
- Run: cd ${FLUTTER_DIR} && flutter analyze --no-pub
- Fix any remaining issues.

DO NOT run git commands.
PROMPT
)"

    log_info "Claude resolving merge conflicts on PR #$pr_number..."
    (cd "$REPO_ROOT" && $CLAUDE_CMD "$prompt") || {
        log_error "Claude conflict-resolution failed"
        return 1
    }

    # Verify no conflict markers remain
    if git -C "$REPO_ROOT" diff --name-only --diff-filter=U 2>/dev/null | grep -q .; then
        log_error "Conflict markers still present after Claude resolution"
        return 1
    fi
}

# ─── Attempt to merge a PR ────────────────────────────────────────────────────
# Returns 0 on successful merge, 1 on permanent failure.
merge_pr() {
    local pr_number="$1"
    local branch="$2"
    local attempt=0
    local max_merge_attempts=3

    while [[ $attempt -lt $max_merge_attempts ]]; do
        attempt=$(( attempt + 1 ))
        log_info "Merge attempt $attempt/$max_merge_attempts for PR #$pr_number..."

        # ── 1. Final CI check ─────────────────────────────────────────────────
        local ci_status
        ci_status="$(gh_ci_status "$pr_number")"
        if [[ "$ci_status" != "success" ]]; then
            log_warn "CI not green ($ci_status) — waiting before merge..."
            if ! gh_wait_for_ci "$pr_number" "$CI_TIMEOUT_MIN"; then
                log_error "CI still failing at merge time for PR #$pr_number — sending back to reviewer"
                gh_transition_label "$pr_number" "factory:merging" "factory:ready-for-review"
                return 1
            fi
        fi

        # ── 2. Mergeability check ─────────────────────────────────────────────
        local mergeable
        mergeable="$(gh_pr_mergeable "$pr_number")"
        log_info "PR #$pr_number mergeable: $mergeable"

        case "$mergeable" in
            MERGEABLE)
                # ── 3a. Direct merge ──────────────────────────────────────────
                if gh pr merge "$pr_number" \
                        --repo "$GITHUB_REPO" \
                        --squash \
                        --delete-branch \
                        --subject "$(gh pr view "$pr_number" --repo "$GITHUB_REPO" --json title --jq '.title') (#${pr_number})" \
                        2>/dev/null; then
                    log_info "✓ PR #$pr_number merged successfully"

                    # Sync local develop
                    git -C "$REPO_ROOT" checkout "$BASE_BRANCH" 2>/dev/null || true
                    retry $MAX_RETRIES git -C "$REPO_ROOT" pull origin "$BASE_BRANCH"
                    log_info "develop synced after merge"
                    return 0
                else
                    log_warn "gh pr merge failed — retrying after 10s"
                    sleep 10
                    continue
                fi
                ;;

            CONFLICTING)
                # ── 3b. Conflict resolution ───────────────────────────────────
                log_warn "PR #$pr_number has conflicts — resolving locally..."

                # Checkout branch and merge develop into it
                git -C "$REPO_ROOT" fetch origin "$branch" "$BASE_BRANCH"
                git -C "$REPO_ROOT" checkout "$branch" 2>/dev/null || \
                    git -C "$REPO_ROOT" checkout -b "$branch" "origin/$branch"
                git -C "$REPO_ROOT" pull origin "$branch"

                # This will produce conflict markers
                git -C "$REPO_ROOT" merge "origin/$BASE_BRANCH" --no-commit 2>/dev/null || true

                # Ask Claude to resolve
                if ! resolve_conflicts_with_claude "$pr_number" "$branch"; then
                    log_error "Claude could not resolve conflicts for PR #$pr_number"
                    git -C "$REPO_ROOT" merge --abort 2>/dev/null || true
                    git -C "$REPO_ROOT" checkout "$BASE_BRANCH" 2>/dev/null || true
                    return 1
                fi

                # Stage resolved files and commit
                git -C "$REPO_ROOT" add -u
                local resolve_msg
                resolve_msg="$(cat <<MSG
chore: résolution conflits merge PR #${pr_number} avec ${BASE_BRANCH}

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>
MSG
)"
                git -C "$REPO_ROOT" commit -m "$resolve_msg" || {
                    # Nothing left to commit after resolution (conflict was only whitespace etc.)
                    git -C "$REPO_ROOT" merge --abort 2>/dev/null || true
                }

                retry $MAX_RETRIES git -C "$REPO_ROOT" push origin "$branch"
                log_info "Conflict resolution pushed — PR #$pr_number now rebasing into $BASE_BRANCH"

                # Let GitHub re-evaluate mergeability before next loop
                sleep 15
                ;;

            UNKNOWN)
                log_warn "Mergeability unknown for PR #$pr_number — waiting 30s..."
                sleep 30
                ;;

            *)
                log_error "Unexpected mergeable state '$mergeable' for PR #$pr_number"
                sleep 15
                ;;
        esac
    done

    log_error "PR #$pr_number could not be merged after $max_merge_attempts attempts"
    return 1
}

# ─── Find story ID for a PR (by PR number in backlog) ─────────────────────────
story_id_for_pr() {
    local pr_number="$1"
    jq -r ".[] | select(.pr_number == $pr_number) | .id" "$BACKLOG_FILE" 2>/dev/null || echo ""
}

# ─── Main loop ────────────────────────────────────────────────────────────────
main() {
    preflight

    log_info "Merger entering main loop. Polling every ${POLL_INTERVAL_MERGER}s."

    while true; do
        cleanup_stale_locks

        local prs_json
        prs_json="$(gh_list_prs_with_label "factory:ready-for-merge")"
        local pr_count
        pr_count="$(echo "$prs_json" | jq 'length' 2>/dev/null || echo 0)"

        if [[ $pr_count -eq 0 ]]; then
            log_debug "No PRs ready to merge. Waiting ${POLL_INTERVAL_MERGER}s..."
            sleep "$POLL_INTERVAL_MERGER"
            continue
        fi

        log_info "$pr_count PR(s) ready to merge"

        local pr_numbers
        pr_numbers="$(echo "$prs_json" | jq -r '.[].number')"

        while IFS= read -r pr_number; do
            [[ -z "$pr_number" ]] && continue

            if ! acquire_pr_lock "$pr_number"; then
                log_debug "PR #$pr_number locked — skipping"
                continue
            fi

            gh_transition_label "$pr_number" "factory:ready-for-merge" "factory:merging"

            local branch
            branch="$(gh_pr_head_branch "$pr_number")"
            if [[ -z "$branch" ]]; then
                log_error "Could not determine branch for PR #$pr_number"
                gh_add_label "$pr_number" "factory:escalate"
                release_pr_lock "$pr_number"
                continue
            fi

            local merge_result=0
            merge_pr "$pr_number" "$branch" || merge_result=$?

            if [[ $merge_result -eq 0 ]]; then
                log_info "✓ PR #$pr_number merged"

                # Update backlog: mark story done
                local story_id
                story_id="$(story_id_for_pr "$pr_number")"
                if [[ -n "$story_id" ]]; then
                    mark_story_done "$story_id"
                fi

                backlog_status
            else
                log_error "✗ PR #$pr_number could not be merged — escalating"
                gh_transition_label "$pr_number" "factory:merging" "factory:escalate"
                gh_pr_comment "$pr_number" \
                    "🚨 **Factory escalation (Merge Agent)** — automatic merge failed after retries. Human intervention required."
            fi

            git -C "$REPO_ROOT" checkout "$BASE_BRANCH" 2>/dev/null || true
            release_pr_lock "$pr_number"

        done <<< "$pr_numbers"

        sleep "$POLL_INTERVAL_MERGER"
    done
}

main "$@"
