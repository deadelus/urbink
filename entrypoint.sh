#!/usr/bin/env bash
# entrypoint.sh — Urbink dev tools (navigation flèches ↑↓ + Entrée)
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS="$SCRIPT_DIR/scripts"
APP_DIR="$SCRIPT_DIR/urbink"

# ── Couleurs ──────────────────────────────────────────────────────────────────
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

log()         { echo -e "${CYAN}▶${NC} $*"; }
ok()          { echo -e "${GREEN}✅${NC} $*"; }
err()         { echo -e "${RED}❌${NC} $*"; }
warn()        { echo -e "${YELLOW}⚠️ ${NC} $*"; }
title()       { echo -e "\n${BOLD}── $* ──────────────────────────────${NC}"; }
press_enter() { echo ""; read -r -p "  Appuyer sur Entrée pour continuer…" || true; }

# ── Menu flèches (bash 3.x compatible) ───────────────────────────────────────
MENU_ITEMS=()
MENU_RESULT=0

_draw_menu() {
  local cur=$1 i
  for i in "${!MENU_ITEMS[@]}"; do
    tput el
    if [[ $i -eq $cur ]]; then
      echo -e "  ${CYAN}${BOLD}▸${NC} ${BOLD}${MENU_ITEMS[$i]}${NC}"
    else
      echo -e "    ${MENU_ITEMS[$i]}"
    fi
  done
}

menu_select() {
  local cur=0 len=${#MENU_ITEMS[@]} key a b
  tput civis 2>/dev/null || true
  echo ""
  _draw_menu "$cur"

  while true; do
    IFS= read -rsn1 key </dev/tty 2>/dev/null || true
    case "$key" in
      $'\x1b')
        IFS= read -rsn1 -t 1 a </dev/tty 2>/dev/null || a=""
        IFS= read -rsn1 -t 1 b </dev/tty 2>/dev/null || b=""
        case "${a}${b}" in
          '[A'|'OA') cur=$(( (cur - 1 + len) % len )) ;;  # ↑ normal + application mode
          '[B'|'OB') cur=$(( (cur + 1) % len )) ;;         # ↓ normal + application mode
        esac ;;
      '') break ;;
    esac
    printf "\033[%dA" "$len"   # remonter de len lignes (ANSI, plus fiable que tput)
    _draw_menu "$cur"
  done

  echo ""
  tput cnorm 2>/dev/null || true
  MENU_RESULT=$cur
}

# ── Helpers partagés ─────────────────────────────────────────────────────────
PICKED_ENV=""
PICKED_UID=""
PICKED_TOKEN=""

# Retourne 0 si env sélectionné, 1 si ← Retour
pick_env() {
  MENU_ITEMS=(
    "local    ${DIM}émulateur Firebase${NC}"
    "dev      ${DIM}urbink-dev${NC}"
    "← Retour"
  )
  echo -e "\n  ${BOLD}Environnement :${NC}"
  menu_select
  case $MENU_RESULT in
    0) PICKED_ENV="local"; return 0 ;;
    1) PICKED_ENV="dev";   return 0 ;;
    2) return 1 ;;
  esac
}

pick_credentials() {
  echo ""
  read -r -p "  UID utilisateur : " PICKED_UID
  echo -e "  ${DIM}(await FirebaseAuth.instance.currentUser?.getIdToken())${NC}"
  read -r -p "  ID token        : " PICKED_TOKEN
}

_not_implemented() {
  warn "Pas encore implémenté — contribue dans scripts/${1}"
}

# ── 1 — Run ───────────────────────────────────────────────────────────────────
action_run() {
  local configs=() labels=() name
  for f in "$APP_DIR"/config/*.json; do
    [[ "$f" == *".example"* ]] && continue
    name="$(basename "$f" .json)"
    configs+=("$name")
    [[ "$name" == "dev" ]] \
      && labels+=("$name   ${DIM}(défaut)${NC}") \
      || labels+=("$name")
  done
  labels+=("← Retour")

  while true; do
    clear
    title "Run"
    echo -e "\n  ${BOLD}Configuration :${NC}"
    MENU_ITEMS=("${labels[@]}")
    menu_select

    [[ $MENU_RESULT -eq ${#configs[@]} ]] && break   # ← Retour

    local chosen="${configs[$MENU_RESULT]}"
    log "flutter run --dart-define-from-file=config/${chosen}.json"
    echo ""
    cd "$APP_DIR"
    flutter run --dart-define-from-file="config/${chosen}.json" || true
    break
  done
}

# ── 2 — Deploy ────────────────────────────────────────────────────────────────
action_deploy() {
  while true; do
    clear
    title "Deploy"
    MENU_ITEMS=(
      "Tout"
      "Firestore      ${DIM}rules + indexes${NC}"
      "Functions      ${DIM}(bientôt)${NC}"
      "Storage        ${DIM}(bientôt)${NC}"
      "Hosting        ${DIM}(bientôt)${NC}"
      "← Retour"
    )
    menu_select

    case $MENU_RESULT in
      0)
        bash "$SCRIPTS/deploy_firestore.sh" || true
        _not_implemented "deploy_functions.sh"
        _not_implemented "deploy_storage.sh"
        _not_implemented "deploy_hosting.sh"
        press_enter ;;
      1) bash "$SCRIPTS/deploy_firestore.sh" || true; press_enter ;;
      2) _not_implemented "deploy_functions.sh"; press_enter ;;
      3) _not_implemented "deploy_storage.sh";   press_enter ;;
      4) _not_implemented "deploy_hosting.sh";   press_enter ;;
      5) break ;;
    esac
  done
}

# ── 3 — Seed ──────────────────────────────────────────────────────────────────
_seed_sessions() {
  local extra_args=()
  if [[ "$PICKED_ENV" != "local" ]]; then
    pick_credentials
    extra_args=("--uid" "$PICKED_UID" "--token" "$PICKED_TOKEN")
  fi
  log "populate_test_sessions.py --env $PICKED_ENV ${extra_args[*]+"${extra_args[*]}"}"
  echo ""
  python3 "$SCRIPTS/populate_test_sessions.py" \
    --env "$PICKED_ENV" "${extra_args[@]+"${extra_args[@]}"}" || true
}

action_seed() {
  while true; do
    clear
    title "Seed"
    MENU_ITEMS=(
      "Tout"
      "Sessions"
      "Users       ${DIM}(bientôt)${NC}"
      "Social      ${DIM}(bientôt)${NC}"
      "Badges      ${DIM}(bientôt)${NC}"
      "← Retour"
    )
    menu_select

    case $MENU_RESULT in
      0)
        pick_env || continue
        _seed_sessions
        _not_implemented "populate_users.py"
        _not_implemented "populate_social.py"
        _not_implemented "populate_badges.py"
        press_enter ;;
      1) pick_env || continue; _seed_sessions; press_enter ;;
      2) _not_implemented "populate_users.py";  press_enter ;;
      3) _not_implemented "populate_social.py"; press_enter ;;
      4) _not_implemented "populate_badges.py"; press_enter ;;
      5) break ;;
    esac
  done
}

# ── 4 — Test ──────────────────────────────────────────────────────────────────
action_test() {
  while true; do
    clear
    title "Test"
    MENU_ITEMS=(
      "Unitaires      ${DIM}flutter test${NC}"
      "Intégration"
      "← Retour"
    )
    menu_select

    case $MENU_RESULT in
      0)
        log "flutter test"
        echo ""
        cd "$APP_DIR"
        flutter test || true
        press_enter ;;
      1)
        while true; do
          clear
          title "Test — Intégration"
          MENU_ITEMS=(
            "Règles Firestore"
            "← Retour"
          )
          menu_select
          case $MENU_RESULT in
            0)
              log "test_firestore_rules.sh"
              echo ""
              bash "$SCRIPTS/test_firestore_rules.sh" || true
              press_enter ;;
            1) break ;;
          esac
        done ;;
      2) break ;;
    esac
  done
}

# ── 5 — Reset ─────────────────────────────────────────────────────────────────
action_reset() {
  while true; do
    clear
    title "Reset"
    pick_env || break

    echo ""
    warn "Toutes les données Firestore de ${BOLD}$PICKED_ENV${NC} vont être supprimées."
    MENU_ITEMS=("Confirmer — effacer" "Annuler")
    menu_select
    [[ $MENU_RESULT -ne 0 ]] && break

    if [[ "$PICKED_ENV" == "local" ]]; then
      log "Suppression données émulateur..."
      local status
      status=$(curl -s -o /dev/null -w "%{http_code}" -X DELETE \
        "http://localhost:8080/emulator/v1/projects/demo-no-project/databases/(default)/documents")
      [[ "$status" == "200" ]] && ok "Données effacées." || err "HTTP $status — émulateur actif ?"
    else
      pick_credentials
      local project_id
      case "$PICKED_ENV" in
        dev)     project_id="urbink-dev" ;;
        staging) project_id="urbink-staging" ;;
        *)       project_id="urbink-dev" ;;
      esac
      log "Suppression users/${PICKED_UID}/sessions + streets..."
      firebase firestore:delete --project "$project_id" --recursive \
        "users/${PICKED_UID}/sessions" 2>/dev/null || true
      firebase firestore:delete --project "$project_id" --recursive \
        "users/${PICKED_UID}/streets" 2>/dev/null || true
      ok "Collections supprimées."
    fi

    press_enter
    break
  done
}

# ── Menu principal ────────────────────────────────────────────────────────────
main_menu() {
  while true; do
    clear
    echo -e "\n${BOLD}  🏙  Urbink — Dev Tools${NC}\n"
    MENU_ITEMS=(
      "run      ${DIM}flutter run${NC}"
      "deploy   ${DIM}Firestore rules & indexes${NC}"
      "seed     ${DIM}Populate test data${NC}"
      "test     ${DIM}flutter test${NC}"
      "reset    ${DIM}Effacer toutes les données${NC}"
      "quitter"
    )
    menu_select

    case $MENU_RESULT in
      0) action_run ;;
      1) action_deploy ;;
      2) action_seed ;;
      3) action_test ;;
      4) action_reset ;;
      5) echo ""; exit 0 ;;
    esac
  done
}

main_menu
