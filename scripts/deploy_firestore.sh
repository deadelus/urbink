#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$(dirname "$SCRIPT_DIR")"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

echo -e "\n${BOLD}🔥 Deploy Firestore — ${YELLOW}dev${NC}\n"
echo -e "  Rules   : firestore.rules"
echo -e "  Indexes : firestore.indexes.json"
echo -e "  Project : urbink-dev\n"

read -r -p "Confirmer le déploiement sur dev ? [y/N] " confirm
if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
  echo "Annulé."
  exit 0
fi

firebase deploy --only firestore -P dev

echo -e "\n${GREEN}${BOLD}✅ Firestore déployé sur dev avec succès.${NC}\n"
