#!/usr/bin/env bash
# lib/common.sh — shared constants, logging, retry logic
# Source this file at the top of every worker script.

set -euo pipefail

# ─── Paths (derived from this file's location) ──────────────────────────────
FACTORY_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPO_ROOT="$(cd "$FACTORY_DIR/../.." && pwd)"
FLUTTER_DIR="$REPO_ROOT/urbink"
ARTIFACTS_DIR="$REPO_ROOT/_bmad-output/implementation-artifacts"
EPICS_FILE="$REPO_ROOT/_bmad-output/planning-artifacts/epics.md"
CLAUDE_MD="$FLUTTER_DIR/CLAUDE.md"
ARCH_MD="$REPO_ROOT/_bmad-output/planning-artifacts/architecture.md"

BACKLOG_FILE="$FACTORY_DIR/backlog.json"
STATE_DIR="$FACTORY_DIR/state"
LOCKS_DIR="$STATE_DIR/locks"
LOGS_DIR="$STATE_DIR/logs"

# ─── GitHub config ────────────────────────────────────────────────────────────
GITHUB_REPO="deadelus/urbink"
BASE_BRANCH="develop"

# ─── Tuning ───────────────────────────────────────────────────────────────────
CLAUDE_CMD="${CLAUDE_CMD:-claude --dangerously-skip-permissions -p}"
MAX_RETRIES=5
MAX_PR_FAILURES=10
MAX_STORY_FAILURES=3
POLL_INTERVAL_BUILDER=30
POLL_INTERVAL_REVIEWER=60
POLL_INTERVAL_MERGER=90
CI_TIMEOUT_MIN=25
STALE_BUILDING_SEC=3600   # 1h before a stuck 'building' story is reset

# ─── Colors ───────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# ─── Logging ──────────────────────────────────────────────────────────────────
# Set WORKER_NAME and LOG_FILE before sourcing to customize output.
WORKER_NAME="${WORKER_NAME:-factory}"
LOG_FILE="${LOG_FILE:-/dev/null}"

log() {
    local level="$1"; shift
    local msg="$*"
    local ts
    ts="$(date '+%Y-%m-%d %H:%M:%S')"
    local color
    case "$level" in
        INFO)  color="$GREEN"  ;;
        WARN)  color="$YELLOW" ;;
        ERROR) color="$RED"    ;;
        DEBUG) color="$CYAN"   ;;
        *)     color="$NC"     ;;
    esac
    local line
    line="$(printf "${color}[%s] [%-7s] [%-10s] %s${NC}\n" \
        "$ts" "$level" "$WORKER_NAME" "$msg")"
    echo -e "$line" >&2
    echo -e "[${ts}] [${level}] [${WORKER_NAME}] ${msg}" >> "$LOG_FILE" 2>/dev/null || true
}

log_info()  { log INFO  "$@"; }
log_warn()  { log WARN  "$@"; }
log_error() { log ERROR "$@"; }
log_debug() { log DEBUG "$@"; }

# ─── Retry with exponential backoff ──────────────────────────────────────────
# Usage: retry <max_retries> <cmd> [args...]
retry() {
    local max="$1"; shift
    local attempt=0
    local delay=10
    until "$@"; do
        attempt=$(( attempt + 1 ))
        if [[ $attempt -ge $max ]]; then
            log_error "Command failed after $max attempts: $*"
            return 1
        fi
        log_warn "Attempt $attempt/$max failed for: $*. Retrying in ${delay}s..."
        sleep "$delay"
        delay=$(( delay * 2 ))
        [[ $delay -gt 300 ]] && delay=300
    done
}

# ─── Tool prerequisite check ─────────────────────────────────────────────────
require_tools() {
    local missing=()
    for tool in "$@"; do
        command -v "$tool" &>/dev/null || missing+=("$tool")
    done
    if [[ ${#missing[@]} -gt 0 ]]; then
        log_error "Missing required tools: ${missing[*]}"
        exit 1
    fi
}

# ─── Portable ISO-8601 → epoch ───────────────────────────────────────────────
iso_to_epoch() {
    local iso="$1"
    python3 -c "
from datetime import datetime, timezone
s = '$iso'.replace('Z', '+00:00')
dt = datetime.fromisoformat(s)
print(int(dt.timestamp()))
" 2>/dev/null || echo 0
}

# ─── Story ACs extractor from epics.md ───────────────────────────────────────
# Extracts the story block for a given story ID (e.g. "3.3") from EPICS_FILE.
extract_story_block() {
    local story_id="$1"
    # Match heading like "### Story 3.3" or "#### Story 3.3" and grab until next story/epic heading
    awk "/^#{2,4} Story ${story_id}[^0-9]/{found=1} found{print} /^#{2,4} (Story [0-9]|Epic )/{if(found && !/Story ${story_id}[^0-9]/) exit}" \
        "$EPICS_FILE" 2>/dev/null || echo "(story block not found in epics.md)"
}

# ─── Init dirs ───────────────────────────────────────────────────────────────
init_dirs() {
    mkdir -p "$LOCKS_DIR" "$LOGS_DIR"
}
