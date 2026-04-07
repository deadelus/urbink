---
status: Accepté
date: 2026-04
---

# 006 — Cloud Functions en Go

## Contexte

Choisir le langage pour la logique serveur (triggers Firestore, génération de parcours, modération).

## Décision

Cloud Functions Go (pas Node.js/TypeScript).

## Conséquences

**Positif :**
- Cold start significativement plus rapide que Node.js
- Typage fort — moins d'erreurs runtime sur la logique critique (badges, modération)
- Performance meilleure pour les calculs géospatiaux (génération de parcours)

**Négatif :**
- Moins de libs Firebase admin en Go qu'en Node.js
- Écosystème plus petit

## Règle absolue

Toutes les clés API externes sont dans les Cloud Functions Go — jamais dans le code Flutter.
