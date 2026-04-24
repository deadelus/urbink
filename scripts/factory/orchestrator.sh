#!/usr/bin/env bash
# orchestrator.sh — launches and monitors 3 workers in parallel tmux sessions
#
# Usage:
#   ./orchestrator.sh start   — start the factory
#   ./orchestrator.sh stop    — kill all workers
#   ./orchestrator.sh status  — show worker + backlog status
#   ./orchestrator.sh logs    — tail all worker logs
#   ./orchestrator.sh restart — stop + start

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"
source "$SCRIPT_DIR/lib/locks.sh"
source "$SCRIPT_DIR/lib/backlog.sh"
source "$SCRIPT_DIR/lib/github.sh"

WORKER_NAME="orchestrator"
LOG_FILE="$LOGS_DIR/orchestrator-$(date '+%Y%m%d').log"
init_dirs

TMUX_SESSION="urbink-factory"

# ─── Prerequisites ────────────────────────────────────────────────────────────
preflight_check() {
    log_info "Running preflight checks..."
    require_tools claude gh git flutter jq tmux python3

    gh_check_auth || exit 1

    if [[ ! -f "$BACKLOG_FILE" ]]; then
        log_error "backlog.json not found at $BACKLOG_FILE"
        log_error "Create it with pending stories before starting the factory."
        exit 1
    fi

    local pending
    pending="$(jq '[.[] | select(.status == "pending")] | length' "$BACKLOG_FILE" 2>/dev/null || echo 0)"
    log_info "Pending stories: $pending"

    if ! jq empty "$BACKLOG_FILE" &>/dev/null; then
        log_error "backlog.json is not valid JSON"
        exit 1
    fi

    log_info "Preflight OK"
}

# ─── Start workers in tmux ────────────────────────────────────────────────────
start() {
    preflight_check
    gh_ensure_labels

    if tmux has-session -t "$TMUX_SESSION" 2>/dev/null; then
        log_warn "tmux session '$TMUX_SESSION' already exists. Use 'restart' to reset."
        exit 0
    fi

    log_info "Starting factory workers in tmux session: $TMUX_SESSION"

    # Create session with Builder in window 0
    tmux new-session -d -s "$TMUX_SESSION" -n "builder" \
        "bash -c 'WORKER_NAME=builder LOG_FILE=$LOGS_DIR/builder-\$(date +%Y%m%d).log bash $SCRIPT_DIR/builder-worker.sh 2>&1 | tee -a $LOGS_DIR/builder-\$(date +%Y%m%d).log; echo \"[BUILDER EXITED with code \$?]\"; sleep 3600'"

    # Window 1: Reviewer
    tmux new-window -t "$TMUX_SESSION" -n "reviewer" \
        "bash -c 'sleep 5; WORKER_NAME=reviewer LOG_FILE=$LOGS_DIR/reviewer-\$(date +%Y%m%d).log bash $SCRIPT_DIR/reviewer-worker.sh 2>&1 | tee -a $LOGS_DIR/reviewer-\$(date +%Y%m%d).log; echo \"[REVIEWER EXITED with code \$?]\"; sleep 3600'"

    # Window 2: Merger
    tmux new-window -t "$TMUX_SESSION" -n "merger" \
        "bash -c 'sleep 10; WORKER_NAME=merger LOG_FILE=$LOGS_DIR/merger-\$(date +%Y%m%d).log bash $SCRIPT_DIR/merge-worker.sh 2>&1 | tee -a $LOGS_DIR/merger-\$(date +%Y%m%d).log; echo \"[MERGER EXITED with code \$?]\"; sleep 3600'"

    # Window 3: Monitor dashboard (watch status)
    tmux new-window -t "$TMUX_SESSION" -n "monitor" \
        "bash -c 'while true; do clear; echo \"=== URBINK FACTORY MONITOR $(date) ===\"; echo \"\"; bash $SCRIPT_DIR/orchestrator.sh status 2>/dev/null; echo \"\"; sleep 30; done'"

    # Select builder window
    tmux select-window -t "$TMUX_SESSION:builder"

    log_info "Factory started. Attach with: tmux attach -t $TMUX_SESSION"
    log_info "Windows: builder | reviewer | merger | monitor"

    # Launch watchdog in background
    nohup bash -c "
        while true; do
            sleep 120
            bash '$SCRIPT_DIR/orchestrator.sh' _watchdog 2>>'$LOG_FILE' || true
        done
    " >> "$LOG_FILE" 2>&1 &
    echo $! > "$LOCKS_DIR/watchdog.pid"
    log_info "Watchdog started (PID: $(cat "$LOCKS_DIR/watchdog.pid"))"
}

# ─── Watchdog: restart crashed workers ────────────────────────────────────────
_watchdog() {
    [[ ! -f "$LOCKS_DIR/watchdog.pid" ]] && return
    log_debug "Watchdog check..."

    if ! tmux has-session -t "$TMUX_SESSION" 2>/dev/null; then
        log_warn "tmux session gone — factory stopped"
        return
    fi

    local workers=("builder" "reviewer" "merger")
    for worker in "${workers[@]}"; do
        local lock_file="$LOCKS_DIR/worker-${worker}.lock"
        if [[ -f "$lock_file" ]]; then
            local pid
            pid="$(cat "$lock_file" 2>/dev/null || echo "")"
            if [[ -n "$pid" ]] && ! kill -0 "$pid" 2>/dev/null; then
                log_warn "Worker $worker (PID $pid) died — restarting in tmux..."
                rm -f "$lock_file"
                local delay=5
                [[ "$worker" == "reviewer" ]] && delay=5
                [[ "$worker" == "merger" ]] && delay=10
                tmux send-keys -t "$TMUX_SESSION:$worker" \
                    "sleep $delay; bash $SCRIPT_DIR/${worker}-worker.sh" Enter 2>/dev/null || \
                    log_warn "Could not restart $worker in tmux (window may be gone)"
            fi
        fi
    done
}

# ─── Stop ─────────────────────────────────────────────────────────────────────
stop() {
    log_info "Stopping factory..."

    # Kill watchdog
    if [[ -f "$LOCKS_DIR/watchdog.pid" ]]; then
        local wdog_pid
        wdog_pid="$(cat "$LOCKS_DIR/watchdog.pid")"
        kill "$wdog_pid" 2>/dev/null || true
        rm -f "$LOCKS_DIR/watchdog.pid"
        log_info "Watchdog stopped"
    fi

    # Kill tmux session
    if tmux has-session -t "$TMUX_SESSION" 2>/dev/null; then
        tmux kill-session -t "$TMUX_SESSION"
        log_info "tmux session '$TMUX_SESSION' killed"
    else
        log_info "No active tmux session found"
    fi

    # Clean up worker locks (workers are gone)
    for worker in builder reviewer merger; do
        rm -f "$LOCKS_DIR/worker-${worker}.lock"
    done

    log_info "Factory stopped."
}

# ─── Status ───────────────────────────────────────────────────────────────────
status() {
    echo ""
    echo -e "${BOLD}═══ FACTORY STATUS ═════════════════════════════════════${NC}"

    # tmux status
    if tmux has-session -t "$TMUX_SESSION" 2>/dev/null; then
        echo -e "${GREEN}▶ tmux session '$TMUX_SESSION' is running${NC}"
    else
        echo -e "${RED}■ tmux session '$TMUX_SESSION' is NOT running${NC}"
    fi

    # Worker process status
    echo ""
    echo "Workers:"
    for worker in builder reviewer merger; do
        local lock_file="$LOCKS_DIR/worker-${worker}.lock"
        if [[ -f "$lock_file" ]]; then
            local pid
            pid="$(cat "$lock_file" 2>/dev/null || echo "?")"
            if kill -0 "$pid" 2>/dev/null; then
                echo -e "  ${GREEN}✓ $worker (PID $pid)${NC}"
            else
                echo -e "  ${RED}✗ $worker (dead PID $pid)${NC}"
            fi
        else
            echo -e "  ${YELLOW}○ $worker (not running)${NC}"
        fi
    done

    # GitHub PR status per label
    echo ""
    echo "GitHub PR pipeline:"
    local labels=(
        "factory:building"
        "factory:ready-for-review"
        "factory:reviewing"
        "factory:ci-fixing"
        "factory:ready-for-merge"
        "factory:merging"
        "factory:escalate"
    )
    for label in "${labels[@]}"; do
        local count
        count="$(gh pr list --repo "$GITHUB_REPO" --state open --label "$label" \
                 --json number --jq 'length' 2>/dev/null || echo "?")"
        local pr_list
        pr_list="$(gh pr list --repo "$GITHUB_REPO" --state open --label "$label" \
                  --json number,title --jq '.[].number' 2>/dev/null | \
                  paste -sd "," - || echo "")"
        if [[ "$count" -gt 0 ]] 2>/dev/null; then
            echo -e "  ${CYAN}[$label]${NC} $count PR(s): #${pr_list}"
        fi
    done

    # Backlog summary
    if [[ -f "$BACKLOG_FILE" ]]; then
        backlog_status
    fi

    echo ""
}

# ─── Logs ─────────────────────────────────────────────────────────────────────
logs() {
    local today
    today="$(date '+%Y%m%d')"
    local log_files=()
    for worker in builder reviewer merger orchestrator; do
        local f="$LOGS_DIR/${worker}-${today}.log"
        [[ -f "$f" ]] && log_files+=("$f")
    done
    if [[ ${#log_files[@]} -eq 0 ]]; then
        echo "No log files for today ($today)"
        return
    fi
    log_info "Tailing: ${log_files[*]}"
    tail -f "${log_files[@]}"
}

# ─── Attach to tmux ───────────────────────────────────────────────────────────
attach() {
    if ! tmux has-session -t "$TMUX_SESSION" 2>/dev/null; then
        log_error "Factory is not running. Use: $0 start"
        exit 1
    fi
    tmux attach -t "$TMUX_SESSION"
}

# ─── Help ─────────────────────────────────────────────────────────────────────
usage() {
    cat <<USAGE
Urbink Software Factory Orchestrator

Usage: $(basename "$0") <command>

Commands:
  start    Start all 3 workers in tmux session '$TMUX_SESSION'
  stop     Kill all workers and the tmux session
  restart  stop + start
  status   Show worker and PR pipeline status
  logs     Tail all worker logs (today)
  attach   Attach to tmux session

Workers launched:
  builder-worker.sh  — picks stories, implements, pushes PRs
  reviewer-worker.sh — waits CI, fixes failures, handles Copilot review
  merge-worker.sh    — merges stable PRs, resolves conflicts

Attach window:
  tmux attach -t $TMUX_SESSION
  Switch windows: Ctrl-b + <0|1|2|3>  (builder|reviewer|merger|monitor)
USAGE
}

# ─── Dispatch ─────────────────────────────────────────────────────────────────
case "${1:-}" in
    start)    start    ;;
    stop)     stop     ;;
    restart)  stop; sleep 2; start ;;
    status)   status   ;;
    logs)     logs     ;;
    attach)   attach   ;;
    _watchdog) _watchdog ;;
    *)        usage    ;;
esac
