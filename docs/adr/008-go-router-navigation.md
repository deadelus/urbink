---
status: Accepté
date: 2026-04
---

# 008 — go_router pour la navigation

## Contexte

Choisir la solution de navigation Flutter pour une app avec deep links, authentification, et bottom nav.

## Décision

`go_router` avec configuration centralisée dans `core/router/app_router.dart`.

## Conséquences

**Positif :**
- Support natif des deep links (partage de pins, parcours)
- Guards d'authentification déclaratifs
- Compatible avec bottom navigation et nested routing
- Package officiel Flutter team

**Négatif :**
- API plus complexe que Navigator 1.0 pour les cas simples
