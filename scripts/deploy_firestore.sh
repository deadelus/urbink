#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$(dirname "$SCRIPT_DIR")"

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

ENV="${1:-}"

usage() {
  echo -e "Usage: ${BOLD}./scripts/deploy_firestore.sh [dev|staging]${NC}"
  echo ""
  echo "  dev      → urbink-dev"
  echo "  staging  → urbink-staging"
  exit 1
}

if [[ -z "$ENV" || ( "$ENV" != "dev" && "$ENV" != "staging" ) ]]; then
  usage
fi

echo -e "\n${BOLD}🔥 Deploy Firestore — ${YELLOW}$ENV${NC}\n"
echo -e "  Rules   : firestore.rules"
echo -e "  Indexes : firestore.indexes.json"
echo -e "  Project : $(firebase use "$ENV" --non-interactive 2>/dev/null || echo $ENV)\n"

read -r -p "Confirmer le déploiement sur $ENV ? [y/N] " confirm
if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
  echo "Annulé."
  exit 0
fi

firebase deploy --only firestore -P "$ENV"

echo -e "\n${GREEN}${BOLD}✅ Firestore déployé sur $ENV avec succès.${NC}\n"
