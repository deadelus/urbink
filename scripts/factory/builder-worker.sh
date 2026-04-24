#!/usr/bin/env bash
# builder-worker.sh — Agent 1: consumes backlog stories, produces PRs
#
# Loop: pick story → branch → Claude implements → test+lint → commit → push → PR → label
# Never waits for CI or review. Produces continuously.

set -euo pipefail

WORKER_NAME="builder"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"
source "$SCRIPT_DIR/lib/locks.sh"
source "$SCRIPT_DIR/lib/backlog.sh"
source "$SCRIPT_DIR/lib/github.sh"

LOG_FILE="$LOGS_DIR/builder-$(date '+%Y%m%d').log"
init_dirs

# ─── Preflight ────────────────────────────────────────────────────────────────
preflight() {
    require_tools claude gh git flutter jq python3
    gh_check_auth
    gh_ensure_labels
    acquire_worker_lock "builder" || {
        log_error "Another builder is already running. Exiting."
        exit 1
    }
    trap 'release_worker_lock builder; log_warn "Builder shut down"' EXIT INT TERM
    recover_stale_building_stories
    log_info "Builder started. REPO_ROOT=$REPO_ROOT"
}

# ─── Claude implementation ────────────────────────────────────────────────────
# Claude uses file tools (Read/Edit/Write/Bash) — changes happen as side effects.
# Git operations are performed by THIS script after Claude returns.
run_claude_implementation() {
    local story_id="$1"
    local story_title="$2"
    local branch="$3"
    local artifact_name="$4"

    local story_block
    story_block="$(extract_story_block "$story_id")"

    local prompt_file
    prompt_file="$(mktemp /tmp/claude-prompt-XXXXXX.txt)"

    cat > "$prompt_file" <<PROMPT
You are implementing Story ${story_id} for the Urbink Flutter project.

ABSOLUTE SOURCE OF TRUTH — read these files NOW before doing anything else:
- ${CLAUDE_MD}
- ${ARCH_MD}
- ${EPICS_FILE}

STORY TO IMPLEMENT:
Story ID  : ${story_id}
Title     : ${story_title}
Branch    : ${branch}
Artifact  : ${ARTIFACTS_DIR}/${artifact_name}.md

STORY CONTENT FROM EPICS:
${story_block}

MANDATORY ROLE SEQUENCE — execute each role fully before moving to the next:

[ARCHITECT]
Read the story ACs from ${EPICS_FILE}.
Plan implementation in 5 bullets max.
No code yet.

[DEVELOPER]
Implement minimal scope satisfying every AC.
Conventions from CLAUDE.md (camelCase vars, snake_case files, PascalCase classes, providers = camelCase + Provider).
Feature-first structure: lib/features/{domain}/ — never organise by type.
Never call Firestore directly in widgets — always via Riverpod provider.
No API keys in Flutter code.

[REVIEWER]
Review every file you created or modified.
Fix each issue. Add a short comment explaining each fix.

[OPTIMIZER]
Simplify. Remove duplication. No over-engineering.

[TESTER]
Run ALL tests from ${FLUTTER_DIR}:
  cd ${FLUTTER_DIR} && flutter test --reporter=compact
Run static analysis (MUST be zero errors):
  cd ${FLUTTER_DIR} && flutter analyze --no-pub
If tests fail or analyze reports errors: fix them and re-run until clean.

PRE-COMMIT CHECKLIST — mandatory before you finish:
1. Create implementation artifact at: ${ARTIFACTS_DIR}/${artifact_name}.md
   Copy structure from: ${ARTIFACTS_DIR}/1-3-bottom-nav-bottom-sheets.md
   Fill all sections: Story, ACs, Tasks/Subtasks (with [x]), Dev Notes, Dev Agent Record, File List, Change Log, Status: done

2. Confirm flutter test passes (run it).
3. Confirm flutter analyze --no-pub shows zero errors.

DO NOT run any git commands (branch, add, commit, push, pr). Git is managed externally.
DO NOT create files outside lib/, test/, ${ARTIFACTS_DIR}/, docs/.
PROMPT

    log_info "Invoking Claude for Story $story_id..."
    local exit_code=0
    (cd "$REPO_ROOT" && $CLAUDE_CMD "$(cat "$prompt_file")") || exit_code=$?
    rm -f "$prompt_file"

    if [[ $exit_code -ne 0 ]]; then
        log_error "Claude invocation failed (exit $exit_code) for Story $story_id"
        return 1
    fi
    log_info "Claude completed Story $story_id"
}

# ─── Quality gate ─────────────────────────────────────────────────────────────
# Run flutter test + analyze. On failure, ask Claude to fix, then retry.
quality_gate() {
    local story_id="$1"
    local max_fix_attempts=3
    local attempt=0

    while [[ $attempt -lt $max_fix_attempts ]]; do
        local test_output=""
        local analyze_output=""
        local ok=true

        log_info "Quality gate attempt $(( attempt + 1 ))/$max_fix_attempts..."

        if ! test_output="$(cd "$FLUTTER_DIR" && flutter test --reporter=compact 2>&1)"; then
            log_warn "flutter test failed"
            ok=false
        fi

        if ! analyze_output="$(cd "$FLUTTER_DIR" && flutter analyze --no-pub 2>&1)"; then
            if echo "$analyze_output" | grep -q "^error"; then
                log_warn "flutter analyze has errors"
                ok=false
            fi
        fi

        if $ok; then
            log_info "Quality gate passed"
            return 0
        fi

        attempt=$(( attempt + 1 ))
        [[ $attempt -ge $max_fix_attempts ]] && break

        # Write fix prompt to temp file to avoid quoting issues
        local fix_file
        fix_file="$(mktemp /tmp/claude-fix-XXXXXX.txt)"

        printf '%s\n' \
            "Tests or analysis failed for Story $story_id in ${FLUTTER_DIR}." \
            "" \
            "flutter test output (tail):" \
            "$(echo "$test_output" | tail -80)" \
            "" \
            "flutter analyze --no-pub output:" \
            "$(echo "$analyze_output" | tail -50)" \
            "" \
            "Fix all failures. Re-run both commands after fixing." \
            "Zero errors required in flutter analyze --no-pub." \
            "All tests must pass." \
            "DO NOT run git commands." \
            > "$fix_file"

        log_info "Claude fixing quality issues (attempt $attempt)..."
        (cd "$REPO_ROOT" && $CLAUDE_CMD "$(cat "$fix_file")") || true
        rm -f "$fix_file"
    done

    log_error "Quality gate failed after $max_fix_attempts fix attempts"
    return 1
}

# ─── Implementation artifact guard ───────────────────────────────────────────
ensure_artifact() {
    local artifact_path="$1"
    local story_id="$2"
    local story_title="$3"

    if [[ -f "$artifact_path" ]]; then
        log_debug "Artifact already exists: $artifact_path"
        return 0
    fi

    log_warn "Artifact missing — creating minimal stub: $artifact_path"

    local today
    today="$(date -u '+%Y-%m-%d')"

    cat > "$artifact_path" <<ARTIFACT
# Story ${story_id} : ${story_title}

## Story

Story ${story_id} — ${story_title}

## Acceptance Criteria

See epics.md — Story ${story_id}

## Tasks/Subtasks

- [x] Implementation via Claude (ARCHITECT→DEVELOPER→REVIEWER→OPTIMIZER→TESTER)

## Dev Notes

Implemented by Builder Agent.

## Dev Agent Record

- Agent: builder-worker.sh
- Date: ${today}
- Status: done

## File List

(auto-generated stub — update with actual files)

## Change Log

- ${today}: Initial implementation

## Status

done
ARTIFACT
}

# ─── Build a single story ─────────────────────────────────────────────────────
build_story() {
    local story_json="$1"

    local story_id story_title branch pr_title pr_body_story artifact_name epic_num

    story_id="$(echo "$story_json"       | jq -r '.id')"
    story_title="$(echo "$story_json"    | jq -r '.title // empty')"
    branch="$(echo "$story_json"         | jq -r '.branch')"
    pr_title="$(echo "$story_json"       | jq -r '.pr_title')"
    pr_body_story="$(echo "$story_json"  | jq -r '.pr_body_story // .title')"
    artifact_name="$(echo "$story_json"  | jq -r '.artifact_name')"
    epic_num="$(echo "$story_json"       | jq -r '.epic')"

    [[ -z "$story_title" ]] && story_title="Story $story_id"

    log_info "Building Story $story_id: $story_title"

    # ── 1. Git setup ──────────────────────────────────────────────────────────
    log_info "Checking out $BASE_BRANCH and pulling..."
    git -C "$REPO_ROOT" checkout "$BASE_BRANCH"
    retry $MAX_RETRIES git -C "$REPO_ROOT" pull origin "$BASE_BRANCH"

    # Idempotent branch handling
    if git -C "$REPO_ROOT" show-ref --verify --quiet "refs/heads/$branch" 2>/dev/null; then
        log_warn "Branch $branch exists locally — removing and recreating"
        git -C "$REPO_ROOT" checkout "$BASE_BRANCH"
        git -C "$REPO_ROOT" branch -D "$branch"
    fi

    if git -C "$REPO_ROOT" ls-remote --exit-code origin "$branch" &>/dev/null; then
        log_warn "Branch $branch exists on remote (possible crash recovery)"
        git -C "$REPO_ROOT" checkout -b "$branch" "origin/$branch" 2>/dev/null || \
            git -C "$REPO_ROOT" checkout "$branch"
    else
        git -C "$REPO_ROOT" checkout -b "$branch"
    fi

    # ── 2. Claude implements story ────────────────────────────────────────────
    run_claude_implementation "$story_id" "$story_title" "$branch" "$artifact_name"

    # ── 3. Quality gate ───────────────────────────────────────────────────────
    quality_gate "$story_id"

    # ── 4. Ensure implementation artifact ─────────────────────────────────────
    local artifact_path="$ARTIFACTS_DIR/${artifact_name}.md"
    ensure_artifact "$artifact_path" "$story_id" "$story_title"

    # ── 5. Commit ─────────────────────────────────────────────────────────────
    log_info "Committing..."

    git -C "$REPO_ROOT" add "urbink/lib" "urbink/test" \
        "_bmad-output/implementation-artifacts/" "docs/" 2>/dev/null || true
    git -C "$REPO_ROOT" add -u 2>/dev/null || true

    local commit_subject="feat(epic-${epic_num}/story-${story_id}): ${story_title}"
    local commit_body="Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>"

    if ! git -C "$REPO_ROOT" diff --cached --quiet; then
        git -C "$REPO_ROOT" commit -m "${commit_subject}" -m "${commit_body}"
    else
        log_warn "No staged changes — story may already be committed"
    fi

    # ── 6. Push ───────────────────────────────────────────────────────────────
    log_info "Pushing branch $branch..."
    retry $MAX_RETRIES git -C "$REPO_ROOT" push -u origin "$branch"

    # ── 7. Create PR ──────────────────────────────────────────────────────────
    log_info "Creating PR..."

    local story_acs
    story_acs="$(extract_story_block "$story_id" | grep -E "Given|When|Then" | head -10 | \
                 sed 's/^/- [ ] /' || echo "- [ ] Voir epics.md")"

    local pr_body_file
    pr_body_file="$(mktemp /tmp/pr-body-XXXXXX.md)"

    cat > "$pr_body_file" <<PR_BODY
## Story
${pr_body_story}

## ACs implémentés
${story_acs}

## Hors scope
(aucun — implémentation complète)

## Notes techniques
Implémentée par le Builder Agent via Claude Code.
Séquence ARCHITECT → DEVELOPER → REVIEWER → OPTIMIZER → TESTER respectée.
PR_BODY

    local pr_number="" pr_url=""
    pr_url="$(gh pr create \
        --repo "$GITHUB_REPO" \
        --base "$BASE_BRANCH" \
        --head "$branch" \
        --title "$pr_title" \
        --body-file "$pr_body_file" 2>/dev/null)" || true
    pr_number="$(echo "$pr_url" | grep -oE '[0-9]+$')"

    rm -f "$pr_body_file"

    if [[ -z "$pr_number" ]]; then
        pr_number="$(gh_pr_number_for_branch "$branch")"
        if [[ -z "$pr_number" ]]; then
            log_error "Failed to create or find PR for branch $branch"
            return 1
        fi
        log_warn "PR already existed: #$pr_number"
    fi

    log_info "PR #$pr_number: $pr_title"

    # ── 8. Assign Copilot + label ─────────────────────────────────────────────
    gh pr edit "$pr_number" \
        --add-reviewer "Copilot" \
        --repo "$GITHUB_REPO" 2>/dev/null || \
        log_warn "Could not assign Copilot reviewer"

    gh_add_label "$pr_number" "factory:ready-for-review"
    mark_story_built "$story_id" "$pr_number"

    log_info "Story $story_id built → PR #$pr_number ready-for-review"
}

# ─── Main loop ────────────────────────────────────────────────────────────────
main() {
    preflight

    log_info "Builder entering main loop. Polling every ${POLL_INTERVAL_BUILDER}s."
    backlog_status

    while true; do
        cleanup_stale_locks

        local story_json=""
        if ! story_json="$(next_pending_story)"; then
            log_info "No pending stories. Waiting ${POLL_INTERVAL_BUILDER}s..."
            sleep "$POLL_INTERVAL_BUILDER"
            continue
        fi

        local story_id
        local error_count
        story_id="$(echo "$story_json"    | jq -r '.id')"
        error_count="$(echo "$story_json" | jq -r '.error_count // 0')"

        if [[ $error_count -ge $MAX_STORY_FAILURES ]]; then
            log_error "Story $story_id exceeded $MAX_STORY_FAILURES failures — escalating"
            mark_story_escalated "$story_id"
            continue
        fi

        if ! acquire_story_lock "$story_id"; then
            log_debug "Story $story_id locked by another process — skipping"
            sleep 5
            continue
        fi

        local build_result=0
        build_story "$story_json" || build_result=$?

        release_story_lock "$story_id"

        if [[ $build_result -ne 0 ]]; then
            local new_count
            new_count="$(mark_story_failed "$story_id" "build-failed-exit-${build_result}")"
            log_warn "Story $story_id failed (${new_count}/${MAX_STORY_FAILURES}). Will retry."
            git -C "$REPO_ROOT" checkout "$BASE_BRANCH" 2>/dev/null || true
        fi

        sleep "$POLL_INTERVAL_BUILDER"
    done
}

main "$@"
