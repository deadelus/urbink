#!/usr/bin/env bash
# lib/github.sh — gh CLI wrappers for labels, CI, reviews, comments

[[ -z "${FACTORY_DIR:-}" ]] && source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

# ─── Label management ─────────────────────────────────────────────────────────

gh_add_label() {
    local pr_number="$1"
    local label="$2"
    gh pr edit "$pr_number" --add-label "$label" --repo "$GITHUB_REPO" 2>/dev/null || \
        log_warn "Could not add label '$label' to PR #$pr_number (may not exist yet)"
}

gh_remove_label() {
    local pr_number="$1"
    local label="$2"
    gh pr edit "$pr_number" --remove-label "$label" --repo "$GITHUB_REPO" 2>/dev/null || true
}

gh_has_label() {
    local pr_number="$1"
    local label="$2"
    gh pr view "$pr_number" --repo "$GITHUB_REPO" --json labels \
        --jq '.labels[].name' 2>/dev/null | grep -qxF "$label"
}

# Atomic: remove from_label, add to_label in one gh call (best-effort)
gh_transition_label() {
    local pr_number="$1"
    local from_label="$2"
    local to_label="$3"
    gh_remove_label "$pr_number" "$from_label"
    gh_add_label    "$pr_number" "$to_label"
    log_info "PR #$pr_number label: $from_label → $to_label"
}

# Create all factory labels if they don't exist (idempotent)
gh_ensure_labels() {
    log_info "Ensuring GitHub labels exist..."
    local specs=(
        "factory:building:0075ca:Builder est en train d'implémenter"
        "factory:ready-for-review:e4e669:PR prête pour review"
        "factory:reviewing:d4c5f9:Reviewer en cours"
        "factory:ci-fixing:f9d0c4:CI en échec — Reviewer en train de corriger"
        "factory:ready-for-merge:0e8a16:Stable — prête à merger"
        "factory:merging:006b75:Merger en cours"
        "factory:escalate:ee0701:Échec trop fréquent — intervention humaine requise"
    )
    for spec in "${specs[@]}"; do
        IFS=: read -r name color desc <<< "$spec"
        gh label create "$name" \
            --color "$color" \
            --description "$desc" \
            --repo "$GITHUB_REPO" 2>/dev/null || true
    done
    log_info "Labels ready."
}

# ─── PR queries ───────────────────────────────────────────────────────────────

# List open PRs with a given factory label. Outputs JSON array.
gh_list_prs_with_label() {
    local label="$1"
    gh pr list \
        --repo "$GITHUB_REPO" \
        --state open \
        --label "$label" \
        --json number,headRefName,title,labels \
        2>/dev/null || echo "[]"
}

# Get PR number for a branch (first open PR)
gh_pr_number_for_branch() {
    local branch="$1"
    gh pr list \
        --repo "$GITHUB_REPO" \
        --state open \
        --head "$branch" \
        --json number \
        --jq '.[0].number // empty' 2>/dev/null || echo ""
}

# Get PR's current merge state: MERGEABLE | CONFLICTING | UNKNOWN
gh_pr_mergeable() {
    local pr_number="$1"
    gh pr view "$pr_number" \
        --repo "$GITHUB_REPO" \
        --json mergeable \
        --jq '.mergeable' 2>/dev/null || echo "UNKNOWN"
}

# Get PR's head commit SHA
gh_pr_head_sha() {
    local pr_number="$1"
    gh pr view "$pr_number" \
        --repo "$GITHUB_REPO" \
        --json headRefOid \
        --jq '.headRefOid' 2>/dev/null || echo ""
}

# Get PR's head branch name
gh_pr_head_branch() {
    local pr_number="$1"
    gh pr view "$pr_number" \
        --repo "$GITHUB_REPO" \
        --json headRefName \
        --jq '.headRefName' 2>/dev/null || echo ""
}

# ─── CI status ────────────────────────────────────────────────────────────────

# Returns: success | failure | pending | unknown
gh_ci_status() {
    local pr_number="$1"
    local sha
    sha="$(gh_pr_head_sha "$pr_number")"
    [[ -z "$sha" ]] && { echo "unknown"; return; }

    gh api "repos/$GITHUB_REPO/commits/$sha/check-runs" \
        --jq '
          .check_runs |
          if length == 0 then "pending"
          elif all(.status == "completed") then
            if all(.conclusion == "success" or .conclusion == "skipped" or .conclusion == "neutral") then "success"
            else "failure"
            end
          else "pending"
          end
        ' 2>/dev/null || echo "unknown"
}

# Poll CI until done or timeout. Exit 0 = success, 1 = failure/timeout.
gh_wait_for_ci() {
    local pr_number="$1"
    local timeout_min="${2:-$CI_TIMEOUT_MIN}"
    local poll_sec=30
    local elapsed=0
    local max_elapsed=$(( timeout_min * 60 ))

    log_info "Waiting for CI — PR #$pr_number (timeout: ${timeout_min}min)"

    while [[ $elapsed -lt $max_elapsed ]]; do
        local status
        status="$(gh_ci_status "$pr_number")"
        case "$status" in
            success)
                log_info "CI ✓ PR #$pr_number"
                return 0 ;;
            failure)
                log_warn "CI ✗ PR #$pr_number"
                return 1 ;;
            pending|unknown)
                log_debug "CI pending (${elapsed}s / ${max_elapsed}s)..."
                sleep $poll_sec
                elapsed=$(( elapsed + poll_sec )) ;;
        esac
    done

    log_error "CI timeout (${timeout_min}min) — PR #$pr_number"
    return 1
}

# Get logs of the latest failed CI run for a PR (last 250 lines)
gh_ci_failure_logs() {
    local pr_number="$1"
    local sha
    sha="$(gh_pr_head_sha "$pr_number")"
    [[ -z "$sha" ]] && { echo "No SHA found for PR #$pr_number"; return; }

    local run_id
    run_id="$(gh api "repos/$GITHUB_REPO/commits/$sha/check-runs" \
        --jq '[.check_runs[] | select(.conclusion == "failure")] | .[0].id // empty' \
        2>/dev/null || echo "")"
    [[ -z "$run_id" ]] && { echo "No failed check-run found for SHA $sha"; return; }

    local failed_job_ids
    failed_job_ids="$(gh api "repos/$GITHUB_REPO/actions/runs/$run_id/jobs" \
        --jq '[.jobs[] | select(.conclusion == "failure") | .id] | .[]' \
        2>/dev/null || echo "")"

    local logs=""
    while IFS= read -r job_id; do
        [[ -z "$job_id" ]] && continue
        local job_log
        job_log="$(gh api "repos/$GITHUB_REPO/actions/jobs/$job_id/logs" 2>/dev/null | \
                   tail -100 || echo "(log unavailable)")"
        logs+="=== CI job $job_id ===\n${job_log}\n\n"
    done <<< "$failed_job_ids"

    echo -e "${logs}" | tail -250
}

# ─── Copilot review ───────────────────────────────────────────────────────────

# Returns: APPROVED | CHANGES_REQUESTED | COMMENTED | NONE
gh_copilot_review_state() {
    local pr_number="$1"
    gh api "repos/$GITHUB_REPO/pulls/$pr_number/reviews" \
        --jq '
          [.[] | select(.user.login | test("copilot"; "i"))] |
          if length == 0 then "NONE"
          else last | .state
          end
        ' 2>/dev/null || echo "NONE"
}

# Wait for Copilot to post any review (timeout in minutes). Exit 0 when review appears.
gh_wait_for_copilot_review() {
    local pr_number="$1"
    local timeout_min="${2:-30}"
    local poll_sec=60
    local elapsed=0
    local max_elapsed=$(( timeout_min * 60 ))

    log_info "Waiting for Copilot review — PR #$pr_number (timeout: ${timeout_min}min)"

    while [[ $elapsed -lt $max_elapsed ]]; do
        local state
        state="$(gh_copilot_review_state "$pr_number")"
        if [[ "$state" != "NONE" ]]; then
            log_info "Copilot review received ($state) — PR #$pr_number"
            return 0
        fi
        log_debug "No Copilot review yet (${elapsed}s elapsed)..."
        sleep $poll_sec
        elapsed=$(( elapsed + poll_sec ))
    done

    log_warn "Copilot review timeout (${timeout_min}min) — PR #$pr_number. Continuing anyway."
    return 0  # Non-fatal: continue without Copilot if it never reviews
}

# Get unresolved Copilot inline comments (not yet replied to).
# Outputs one JSON object per line: {id, path, line, body}
gh_copilot_unresolved_comments() {
    local pr_number="$1"
    gh api "repos/$GITHUB_REPO/pulls/$pr_number/comments" \
        --jq '
          .[] |
          select(
            (.user.login | test("copilot"; "i")) and
            (.in_reply_to_id == null)
          ) |
          {id: .id, path: .path, line: (.original_line // .line), body: .body}
        ' 2>/dev/null || echo ""
}

# Reply to a specific PR review comment
gh_reply_comment() {
    local pr_number="$1"
    local comment_id="$2"
    local body="$3"
    gh api "repos/$GITHUB_REPO/pulls/comments/$comment_id/replies" \
        -f body="$body" \
        --silent 2>/dev/null || \
        log_warn "Could not reply to comment $comment_id on PR #$pr_number"
}

# Post a general PR comment
gh_pr_comment() {
    local pr_number="$1"
    local body="$2"
    gh pr comment "$pr_number" --repo "$GITHUB_REPO" --body "$body" 2>/dev/null || \
        log_warn "Could not post comment on PR #$pr_number"
}

# ─── Auth check ───────────────────────────────────────────────────────────────
gh_check_auth() {
    if ! gh auth status --hostname github.com &>/dev/null; then
        log_error "Not authenticated to GitHub. Run: gh auth login"
        return 1
    fi
    log_info "GitHub auth OK"
}
