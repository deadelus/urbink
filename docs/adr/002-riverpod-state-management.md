---
status: Accepté
date: 2026-04
---

# 002 — Riverpod pour le state management

## Contexte

Choisir la solution de state management Flutter pour gérer les streams Firestore, le GPS, et les états UI complexes.

## Décision

Riverpod avec `StreamProvider` pour Firestore et `freezed` pour les états immutables.

## Conséquences

**Positif :**
- `StreamProvider` s'intègre naturellement avec les streams Firestore
- `freezed` garantit l'immutabilité des états (évite les bugs de mutation)
- Testable sans BuildContext
- Meilleure DX que Provider ou Bloc pour ce type de projet

**Négatif :**
- Courbe d'apprentissage pour les devs venant de Provider/Bloc
- `build_runner` nécessaire pour `freezed` (génération de code)

## Convention

Tous les providers nommés en camelCase + suffixe : `sessionProvider`, `mapStateProvider`.
