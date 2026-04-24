#!/usr/bin/env bash
# lib/locks.sh — file-based distributed locking with PID-based stale detection

[[ -z "${FACTORY_DIR:-}" ]] && source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

# ─── Generic lock acquire/release ─────────────────────────────────────────────
# Atomic on POSIX: write PID to temp, mv overwrites atomically.
# Returns 0 if lock acquired, 1 if already held by live process.

_acquire_lock() {
    local lock_file="$1"

    if [[ -f "$lock_file" ]]; then
        local existing_pid
        existing_pid="$(cat "$lock_file" 2>/dev/null || echo "")"
        if [[ -n "$existing_pid" ]] && kill -0 "$existing_pid" 2>/dev/null; then
            log_debug "Lock $(basename "$lock_file") held by live PID $existing_pid"
            return 1
        fi
        log_warn "Removing stale lock $(basename "$lock_file") (dead PID: ${existing_pid:-?})"
        rm -f "$lock_file"
    fi

    local tmp
    tmp="$(mktemp "${lock_file}.XXXXXX")"
    echo "$$" > "$tmp"
    mv "$tmp" "$lock_file"

    # Verify we won any micro-race
    local owner
    owner="$(cat "$lock_file" 2>/dev/null || echo "")"
    if [[ "$owner" != "$$" ]]; then
        log_debug "Lost lock race for $(basename "$lock_file")"
        return 1
    fi

    return 0
}

_release_lock() {
    local lock_file="$1"
    local owner
    owner="$(cat "$lock_file" 2>/dev/null || echo "")"
    if [[ "$owner" == "$$" ]]; then
        rm -f "$lock_file"
        log_debug "Released lock: $(basename "$lock_file")"
    fi
}

# ─── Worker-level locks (one per worker type) ─────────────────────────────────

acquire_worker_lock() {
    local name="$1"
    local lock_file="$LOCKS_DIR/worker-${name}.lock"
    if _acquire_lock "$lock_file"; then
        log_info "Worker lock acquired: $name (PID $$)"
        return 0
    fi
    return 1
}

release_worker_lock() {
    local name="$1"
    _release_lock "$LOCKS_DIR/worker-${name}.lock"
}

# ─── PR-level locks (one per PR number) ───────────────────────────────────────
# Prevents multiple agents acting on the same PR simultaneously.

acquire_pr_lock() {
    local pr_number="$1"
    _acquire_lock "$LOCKS_DIR/pr-${pr_number}.lock"
}

release_pr_lock() {
    local pr_number="$1"
    _release_lock "$LOCKS_DIR/pr-${pr_number}.lock"
}

# ─── Story-level locks (one per story ID) ─────────────────────────────────────
# Prevents the builder from picking the same story twice in parallel.

acquire_story_lock() {
    local story_id="$1"
    local safe_id="${story_id//\//-}"
    _acquire_lock "$LOCKS_DIR/story-${safe_id}.lock"
}

release_story_lock() {
    local story_id="$1"
    local safe_id="${story_id//\//-}"
    _release_lock "$LOCKS_DIR/story-${safe_id}.lock"
}

# ─── Global cleanup ───────────────────────────────────────────────────────────
# Remove all lock files whose owning PID is no longer alive.

cleanup_stale_locks() {
    local count=0
    for lock_file in "$LOCKS_DIR"/*.lock; do
        [[ -f "$lock_file" ]] || continue
        local pid
        pid="$(cat "$lock_file" 2>/dev/null || echo "")"
        if [[ -n "$pid" ]] && ! kill -0 "$pid" 2>/dev/null; then
            log_warn "Cleaning stale lock: $(basename "$lock_file") (dead PID $pid)"
            rm -f "$lock_file"
            count=$(( count + 1 ))
        fi
    done
    [[ $count -gt 0 ]] && log_info "Removed $count stale lock(s)"
    return 0
}

# ─── Backlog file mutex (spin-wait, for short critical sections only) ─────────

BACKLOG_MUTEX="$LOCKS_DIR/backlog.mutex"

acquire_backlog_mutex() {
    local timeout="${1:-30}"
    local elapsed=0
    while [[ $elapsed -lt $timeout ]]; do
        # noclobber is atomic on most POSIX filesystems
        if (set -o noclobber; echo "$$" > "$BACKLOG_MUTEX") 2>/dev/null; then
            return 0
        fi
        local pid
        pid="$(cat "$BACKLOG_MUTEX" 2>/dev/null || echo "")"
        if [[ -n "$pid" ]] && ! kill -0 "$pid" 2>/dev/null; then
            rm -f "$BACKLOG_MUTEX"
            continue
        fi
        sleep 1
        elapsed=$(( elapsed + 1 ))
    done
    log_error "Backlog mutex timeout after ${timeout}s"
    return 1
}

release_backlog_mutex() {
    local pid
    pid="$(cat "$BACKLOG_MUTEX" 2>/dev/null || echo "")"
    [[ "$pid" == "$$" ]] && rm -f "$BACKLOG_MUTEX"
}
