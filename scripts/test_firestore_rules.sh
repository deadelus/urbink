#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
FIRESTORE_URL="http://localhost:8080"
AUTH_URL="http://localhost:9099"
PROJECT_ID="demo-no-project"
PASS=0
FAIL=0

# ---------------------------------------------------------------------------
# Couleurs
# ---------------------------------------------------------------------------
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

log()  { echo -e "${CYAN}▶${NC} $*"; }
ok()   { echo -e "${GREEN}✅ PASS${NC} — $*"; PASS=$(( PASS + 1 )); }
fail() { echo -e "${RED}❌ FAIL${NC} — $*"; FAIL=$(( FAIL + 1 )); }
title(){ echo -e "\n${BOLD}${YELLOW}── $* ──────────────────────────────${NC}"; }

# ---------------------------------------------------------------------------
# Démarrage émulateur
# ---------------------------------------------------------------------------
start_emulators() {
  title "Démarrage des émulateurs Firebase"
  cd "$PROJECT_ROOT"

  if curl -s "$FIRESTORE_URL" > /dev/null 2>&1 && curl -s "$AUTH_URL" > /dev/null 2>&1; then
    log "Émulateurs déjà actifs — skip démarrage"
    return
  fi

  log "Lancement firebase emulators:start --only firestore,auth ..."
  firebase emulators:start --only firestore,auth > /tmp/firebase-emulator.log 2>&1 &
  EMULATOR_PID=$!
  echo "$EMULATOR_PID" > /tmp/firebase-emulator.pid

  log "Attente démarrage (max 30s)..."
  for i in $(seq 1 30); do
    if curl -s "$AUTH_URL" > /dev/null 2>&1 && curl -s "$FIRESTORE_URL" > /dev/null 2>&1; then
      echo -e "${GREEN}✔ Émulateurs prêts${NC} (${i}s)"
      return
    fi
    sleep 1
    echo -n "."
  done
  echo ""
  echo -e "${RED}Timeout — émulateurs non démarrés. Voir /tmp/firebase-emulator.log${NC}"
  exit 1
}

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
get_token() {
  local response
  response=$(curl -s -X POST \
    "${AUTH_URL}/identitytoolkit.googleapis.com/v1/accounts:signUp?key=fake-key" \
    -H "Content-Type: application/json" \
    -d '{"returnSecureToken":true}')
  echo "$response"
}

assert_status() {
  local label="$1"
  local expected="$2"
  local actual="$3"
  if [ "$actual" = "$expected" ]; then
    ok "$label (HTTP $actual)"
  else
    fail "$label — attendu HTTP $expected, reçu HTTP $actual"
  fi
}

firestore_get() {
  local path="$1"
  local token="${2:-}"
  if [ -n "$token" ]; then
    curl -s -o /dev/null -w "%{http_code}" \
      -H "Authorization: Bearer $token" \
      "${FIRESTORE_URL}/v1/projects/${PROJECT_ID}/databases/(default)/documents/${path}"
  else
    curl -s -o /dev/null -w "%{http_code}" \
      "${FIRESTORE_URL}/v1/projects/${PROJECT_ID}/databases/(default)/documents/${path}"
  fi
}

firestore_write() {
  local path="$1"
  local token="${2:-}"
  if [ -n "$token" ]; then
    curl -s -o /dev/null -w "%{http_code}" -X PATCH \
      -H "Authorization: Bearer $token" \
      -H "Content-Type: application/json" \
      -d '{"fields":{"test":{"stringValue":"hello"}}}' \
      "${FIRESTORE_URL}/v1/projects/${PROJECT_ID}/databases/(default)/documents/${path}"
  else
    curl -s -o /dev/null -w "%{http_code}" -X PATCH \
      -H "Content-Type: application/json" \
      -d '{"fields":{"test":{"stringValue":"hello"}}}' \
      "${FIRESTORE_URL}/v1/projects/${PROJECT_ID}/databases/(default)/documents/${path}"
  fi
}

# ---------------------------------------------------------------------------
# Setup auth
# ---------------------------------------------------------------------------
setup_users() {
  title "Setup — création de 2 utilisateurs anonymes"

  local r1 r2
  r1=$(get_token)
  r2=$(get_token)

  FUID_1=$(echo "$r1" | python3 -c "import json,sys; print(json.load(sys.stdin)['localId'])")
  TOKEN_1=$(echo "$r1" | python3 -c "import json,sys; print(json.load(sys.stdin)['idToken'])")
  FUID_2=$(echo "$r2" | python3 -c "import json,sys; print(json.load(sys.stdin)['localId'])")
  TOKEN_2=$(echo "$r2" | python3 -c "import json,sys; print(json.load(sys.stdin)['idToken'])")

  log "Utilisateur 1 : $FUID_1"
  log "Utilisateur 2 : $FUID_2"
}

# ---------------------------------------------------------------------------
# Suite 1 — Accès autorisé (propriétaire)
# ---------------------------------------------------------------------------
suite_authorized() {
  title "Suite 1 — Accès autorisé (AC1)"

  local status

  status=$(firestore_get "users/$FUID_1/sessions" "$TOKEN_1")
  assert_status "GET sessions — propriétaire" "200" "$status"

  status=$(firestore_get "users/$FUID_1/streets" "$TOKEN_1")
  assert_status "GET streets — propriétaire" "200" "$status"

  status=$(firestore_write "users/$FUID_1/sessions/test-session" "$TOKEN_1")
  assert_status "WRITE session — propriétaire" "200" "$status"

  status=$(firestore_write "users/$FUID_1/streets/way:123" "$TOKEN_1")
  assert_status "WRITE street — propriétaire" "200" "$status"
}

# ---------------------------------------------------------------------------
# Suite 2 — Accès refusé (UID différent)
# ---------------------------------------------------------------------------
suite_unauthorized_other_user() {
  title "Suite 2 — Accès refusé UID différent (AC2)"

  local status

  status=$(firestore_get "users/$FUID_1/sessions" "$TOKEN_2")
  assert_status "GET sessions — autre utilisateur" "403" "$status"

  status=$(firestore_get "users/$FUID_1/streets" "$TOKEN_2")
  assert_status "GET streets — autre utilisateur" "403" "$status"

  status=$(firestore_write "users/$FUID_1/sessions/hack-session" "$TOKEN_2")
  assert_status "WRITE session — autre utilisateur" "403" "$status"
}

# ---------------------------------------------------------------------------
# Suite 3 — Accès refusé (non authentifié)
# ---------------------------------------------------------------------------
suite_unauthenticated() {
  title "Suite 3 — Accès refusé non authentifié (AC2)"

  local status

  status=$(firestore_get "users/$FUID_1/sessions")
  assert_status "GET sessions — non authentifié" "403" "$status"

  status=$(firestore_get "users/$FUID_1/streets")
  assert_status "GET streets — non authentifié" "403" "$status"

  status=$(firestore_write "users/$FUID_1/sessions/anon-write")
  assert_status "WRITE session — non authentifié" "403" "$status"
}

# ---------------------------------------------------------------------------
# Résumé
# ---------------------------------------------------------------------------
summary() {
  title "Résumé"
  local total=$((PASS + FAIL))
  echo -e "Tests : ${BOLD}$total${NC} | ${GREEN}$PASS passés${NC} | ${RED}$FAIL échoués${NC}"
  echo ""
  if [ $FAIL -eq 0 ]; then
    echo -e "${GREEN}${BOLD}✅ Toutes les règles Firestore sont correctes.${NC}"
  else
    echo -e "${RED}${BOLD}❌ $FAIL règle(s) en échec — vérifier firestore.rules${NC}"
    exit 1
  fi
}

# ---------------------------------------------------------------------------
# Arrêt émulateur si démarré par ce script
# ---------------------------------------------------------------------------
cleanup() {
  if [ -f /tmp/firebase-emulator.pid ]; then
    local pid
    pid=$(cat /tmp/firebase-emulator.pid)
    if kill -0 "$pid" 2>/dev/null; then
      log "Arrêt émulateur (PID $pid)..."
      kill "$pid" 2>/dev/null || true
    fi
    rm -f /tmp/firebase-emulator.pid
  fi
}
trap cleanup EXIT

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
echo -e "\n${BOLD}🔥 Urbink — Test des règles Firestore${NC}\n"

start_emulators
setup_users
suite_authorized
suite_unauthorized_other_user
suite_unauthenticated
summary
