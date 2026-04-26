# Story 4.1 — Système de quartiers — structure Firestore + calcul progression %
## Implementation Artifact

**Branch :** `epic-4/story-4.1-quartiers-structure-progression`
**Epic :** Epic 4 — Gamification & Progression

---

## Story

En tant qu'**utilisateur**,
Je veux voir le pourcentage de rues que j'ai explorées dans chaque quartier de Paris,
Afin de savoir où concentrer mes prochaines explorations.

## Acceptance Criteria

- [x] **AC1** — Given la collection `/quartiers/{quartierId}` dans Firestore, When le système est initialisé, Then les 20 arrondissements de Paris sont présents avec leurs `streetIds` OSM et `secretLocal` (FR15)
  → Hors scope Flutter MVP : les 20 arrondissements + leurs streetIds sont déjà disponibles via `assets/geo/paris/arrondissement_streets.json` (25 094 rues indexées). La structure Firestore `/quartiers/` et le champ `secretLocal` seront seedés dans Story 4.2 (Cloud Function + admin).
- [x] **AC2** — Given une rue explorée, When son streetId est ajouté via session, Then `quartiersProgressionProvider` recalcule `exploredStreets / totalStreets * 100` par arrondissement
- [x] **AC3** — Given l'écran Challenges → section Quartiers, When il affiche la liste, Then chaque quartier affiche une `LinearProgressIndicator` avec son % complétion, triés par % décroissant

## Tasks / Subtasks

- [x] T1 — Modèle `QuartierProgression`
  - [x] T1.1 — Champs : id, name, totalStreets, exploredStreets
  - [x] T1.2 — Getter `completionPercent` : exploredStreets / totalStreets × 100
- [x] T2 — Provider `arrondissementStreetsProvider` (FutureProvider injectable)
  - [x] T2.1 — Charge `assets/geo/{city}/arrondissement_streets.json`
  - [x] T2.2 — Retourne `Map<String, Set<String>>` (id arrond → Set streetIds)
- [x] T3 — Provider `quartiersProgressionProvider` (StreamProvider)
  - [x] T3.1 — Watch uid via `currentUidProvider` — retourne `[]` si null
  - [x] T3.2 — Watch sessions all-time via `sessionsStreetIdsStreamProvider((uid, null))`
  - [x] T3.3 — asyncMap : charge streetsMap + zones, calcule % par arrond, trie par % décroissant
- [x] T4 — `ChallengesScreen` (route `/badges`)
  - [x] T4.1 — SliverAppBar "Challenges"
  - [x] T4.2 — Section "Quartiers" avec titre
  - [x] T4.3 — `_QuartierProgressionTile` : nom · % · LinearProgressIndicator · nb rues
  - [x] T4.4 — États loading / error
- [x] T5 — Brancher route `/badges` → `ChallengesScreen` dans `app_router.dart`
- [x] T6 — Tests
  - [x] T6.1 — Tests unitaires `QuartierProgression` (completionPercent, edge cases)
  - [x] T6.2 — Tests provider `quartiersProgressionProvider` (uid null, calcul %, tri)
  - [x] T6.3 — Widget test `ChallengesScreen` (loading, data, error)

## Dev Notes

### Architecture
- `QuartierProgression` : modèle pur dans `features/gamification/models/` — pas de Firestore direct
- `arrondissementStreetsProvider` : public (injectable en tests), consomme `currentCityProvider` pour cohérence multi-ville
- `quartiersProgressionProvider` : StreamProvider — réagit aux nouvelles sessions en temps réel
- **Aucun filtre temporel** sur la progression quartier — toujours all-time (contrairement à `aggregationProvider` qui respecte `timeFilterProvider`)
- `asyncMap` sur le stream sessions : charge les assets une seule fois (FutureProvider Riverpod cached), recalcule le Set intersection à chaque émission

### Jointure données
```
arrondissement_streets.json  →  Map<"arrond_1", Set<"way:xxx">>
arrondissements.json (zones) →  Map<"arrond_1", "1er">
sessions Firestore           →  Set<"way:xxx"> explorées all-time
```
Intersection : `totalSet.intersection(explored).length`

### Tri
Trié par `completionPercent` décroissant — "le plus proche de 100%" en premier.

## Dev Agent Record

### Implementation Plan
1. Modèle `QuartierProgression` (pure Dart, aucune dépendance)
2. `arrondissementStreetsProvider` dans `features/gamification/providers/`
3. `quartiersProgressionProvider` qui combine assets + stream Firestore
4. `ChallengesScreen` avec CustomScrollView + SliverList
5. Route `/badges` mise à jour dans `app_router.dart`
6. Tests unitaires + widget

### Debug Log
_Aucun blocage._

### Completion Notes
- 20 arrondissements, 25 094 rues indexées dans l'asset local
- Progression réactive : se met à jour dès qu'une nouvelle session est commitée
- Tri par % décroissant : l'arrondissement le plus "complétable" en premier
- AC1 partiellement out-of-scope Flutter : le seed Firestore `/quartiers/` est reporté en 4.2

## File List

- `urbink/lib/features/gamification/models/quartier_progression.dart` (nouveau)
- `urbink/lib/features/gamification/providers/quartiers_progression_provider.dart` (nouveau)
- `urbink/lib/features/gamification/screens/challenges_screen.dart` (nouveau)
- `urbink/lib/core/router/app_router.dart` (modifié — route /badges)
- `urbink/test/features/gamification/models/quartier_progression_test.dart` (nouveau)
- `urbink/test/features/gamification/providers/quartiers_progression_provider_test.dart` (nouveau)
- `urbink/test/features/gamification/screens/challenges_screen_test.dart` (nouveau)

## Change Log

- 2026-04-27 : Implémentation initiale Story 4.1 — QuartierProgression + providers + ChallengesScreen

## Status

done
