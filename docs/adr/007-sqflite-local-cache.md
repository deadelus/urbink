---
status: Accepté
date: 2026-04
---

# 007 — sqflite pour le cache local

## Contexte

Gérer les données en mode hors-ligne pendant une session GPS et au démarrage avant que Firestore ne réponde.

## Décision

`sqflite` comme couche de cache local uniquement. Firestore reste la source de vérité.

## Conséquences

**Positif :**
- SQL standard — requêtes flexibles pour les données de session
- Persistance des données GPS pendant une session sans réseau
- Sync à la reconnexion vers Firestore

**Négatif :**
- Deux sources de données à maintenir en cohérence
- Migrations de schéma SQL à gérer si le modèle évolue

## Règle

sqflite = cache uniquement. Jamais de logique métier qui dépend de sqflite comme source de vérité.
