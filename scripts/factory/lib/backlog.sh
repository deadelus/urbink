#!/usr/bin/env bash
# lib/backlog.sh — atomic backlog CRUD via JSON + mutex
# Story status lifecycle: pending → building → built → done | escalated

[[ -z "${FACTORY_DIR:-}" ]] && source "$(dirname "${BASH_SOURCE[0]}")/common.sh"
[[ "$(type -t acquire_backlog_mutex)" != "function" ]] && \
    source "$(dirname "${BASH_SOURCE[0]}")/locks.sh"

# ─── Internal: atomic JSON update ─────────────────────────────────────────────
_backlog_write() {
    local filter="$1"
    local tmp
    tmp="$(mktemp "$BACKLOG_FILE.XXXXXX")"
    if jq "$filter" "$BACKLOG_FILE" > "$tmp"; then
        mv "$tmp" "$BACKLOG_FILE"
    else
        rm -f "$tmp"
        log_error "jq filter failed: $filter"
        return 1
    fi
}

_now_iso() { date -u '+%Y-%m-%dT%H:%M:%SZ'; }

# ─── Stale building recovery ──────────────────────────────────────────────────
# Call on builder startup: reset stories stuck in 'building' longer than STALE_BUILDING_SEC.
recover_stale_building_stories() {
    local now_epoch
    now_epoch="$(date +%s)"
    local stale_threshold="${STALE_BUILDING_SEC:-3600}"

    local story_ids
    story_ids="$(jq -r '.[] | select(.status == "building") | .id' "$BACKLOG_FILE" 2>/dev/null || true)"

    while IFS= read -r sid; do
        [[ -z "$sid" ]] && continue
        local started_at
        started_at="$(jq -r ".[] | select(.id == \"$sid\") | .started_at // \"\"" "$BACKLOG_FILE")"
        if [[ -z "$started_at" ]]; then
            log_warn "Story $sid stuck in 'building' with no started_at — resetting"
            mark_story_failed "$sid" "stale-building-no-timestamp" > /dev/null
            continue
        fi
        local started_epoch
        started_epoch="$(iso_to_epoch "$started_at")"
        local age=$(( now_epoch - started_epoch ))
        if [[ $age -gt $stale_threshold ]]; then
            log_warn "Story $sid stuck in 'building' for ${age}s > ${stale_threshold}s — resetting"
            mark_story_failed "$sid" "stale-building-timeout" > /dev/null
        fi
    done <<< "$story_ids"
}

# ─── Backlog reads ────────────────────────────────────────────────────────────

# Get the full JSON object for a story by ID
get_story() {
    local story_id="$1"
    jq -r ".[] | select(.id == \"$story_id\")" "$BACKLOG_FILE"
}

# Get count of pending stories
pending_count() {
    jq '[.[] | select(.status == "pending")] | length' "$BACKLOG_FILE" 2>/dev/null || echo 0
}

# ─── Backlog writes (all mutexed) ─────────────────────────────────────────────

# Dequeue next pending story, atomically mark as building.
# Prints the story JSON object. Returns 1 if no pending stories.
next_pending_story() {
    acquire_backlog_mutex 30 || return 1

    local story
    story="$(jq 'first(.[] | select(.status == "pending"))' "$BACKLOG_FILE" 2>/dev/null || echo "null")"

    if [[ -z "$story" || "$story" == "null" ]]; then
        release_backlog_mutex
        return 1
    fi

    local story_id
    story_id="$(echo "$story" | jq -r '.id')"
    local now
    now="$(_now_iso)"

    _backlog_write "
        (.[] | select(.id == \"$story_id\") | .status)     |= \"building\" |
        (.[] | select(.id == \"$story_id\") | .started_at) |= \"$now\"
    " || { release_backlog_mutex; return 1; }

    release_backlog_mutex

    # Return the story with updated status so caller has the latest
    jq ".[] | select(.id == \"$story_id\")" "$BACKLOG_FILE"
}

# Mark a story as successfully built (PR created)
mark_story_built() {
    local story_id="$1"
    local pr_number="$2"
    local now
    now="$(_now_iso)"
    acquire_backlog_mutex 30 || return 1
    _backlog_write "
        (.[] | select(.id == \"$story_id\") | .status)    |= \"built\" |
        (.[] | select(.id == \"$story_id\") | .pr_number) |= $pr_number |
        (.[] | select(.id == \"$story_id\") | .built_at)  |= \"$now\"
    "
    release_backlog_mutex
    log_info "Story $story_id → built (PR #$pr_number)"
}

# Mark a story as fully merged and done
mark_story_done() {
    local story_id="$1"
    local now
    now="$(_now_iso)"
    acquire_backlog_mutex 30 || return 1
    _backlog_write "
        (.[] | select(.id == \"$story_id\") | .status)  |= \"done\" |
        (.[] | select(.id == \"$story_id\") | .done_at) |= \"$now\"
    "
    release_backlog_mutex
    log_info "Story $story_id → done"
}

# Increment error count and reset to pending so it can be retried.
# Prints the new error_count to stdout.
mark_story_failed() {
    local story_id="$1"
    local reason="$2"
    local now
    now="$(_now_iso)"
    acquire_backlog_mutex 30 || return 1

    _backlog_write "
        (.[] | select(.id == \"$story_id\") | .status)      |= \"pending\" |
        (.[] | select(.id == \"$story_id\") | .error_count) |= (. + 1) |
        (.[] | select(.id == \"$story_id\") | .last_error)  |= \"$reason\" |
        (.[] | select(.id == \"$story_id\") | .last_error_at) |= \"$now\"
    "

    local error_count
    error_count="$(jq -r ".[] | select(.id == \"$story_id\") | .error_count" "$BACKLOG_FILE")"

    release_backlog_mutex
    log_warn "Story $story_id → failed (attempt $error_count): $reason"
    echo "$error_count"
}

# Mark a story as escalated (requires human attention)
mark_story_escalated() {
    local story_id="$1"
    acquire_backlog_mutex 30 || return 1
    _backlog_write "(.[] | select(.id == \"$story_id\") | .status) |= \"escalated\""
    release_backlog_mutex
    log_error "Story $story_id → ESCALATED — human intervention required"
}

# Print a summary table
backlog_status() {
    echo ""
    echo -e "${BOLD}═══ BACKLOG STATUS ══════════════════════════════════════${NC}"
    jq -r '.[] | "[\(.status | ascii_upcase | .[0:10])] Story \(.id) — \(.title // "no title") \(if .pr_number then "(PR #\(.pr_number))" else "" end)"' \
        "$BACKLOG_FILE" 2>/dev/null | while IFS= read -r line; do
        if   echo "$line" | grep -q "PENDING";   then echo -e "${CYAN}$line${NC}"
        elif echo "$line" | grep -q "BUILDING";  then echo -e "${YELLOW}$line${NC}"
        elif echo "$line" | grep -q "BUILT";     then echo -e "${BLUE}$line${NC}"
        elif echo "$line" | grep -q "DONE";      then echo -e "${GREEN}$line${NC}"
        elif echo "$line" | grep -q "ESCALATED"; then echo -e "${RED}$line${NC}"
        else echo "$line"; fi
    done
    echo -e "${BOLD}════════════════════════════════════════════════════════${NC}"
    echo ""
}
