# Implementation Artifact — Story 4.5

## Story
Epic 4 · Story 4.5 — Grille badges monuments dans l'écran Challenges

## ACs implémentés

- [x] Given l'écran Challenges est ouvert / When les badges monuments sont chargés / Then une grille 4 colonnes affiche tous les monuments gamifiables (~197) avec l'état débloqué (emoji couleur + date) ou verrouillé (opacité 40% + 🔒)
- [x] Given un badge monument est débloqué pendant la session / When `BadgeGrid.didUpdateWidget` détecte le nouveau badge / Then une animation scale-in et un chip "Nouveau !" apparaissent pendant 3 secondes
- [x] Given un badge verrouillé est tapé / When l'utilisateur appuie dessus / Then une bottom sheet s'affiche avec le nom, un hint "Passe à 100m" et un bouton "Voir sur carte"
- [x] Given le bouton "Voir sur carte" est appuyé / When `mapFocusProvider` est mis à jour / Then `MapScreen` centre la carte sur le monument à zoom 17 et reset le provider à null

## Tasks / Subtasks

- [x] Créer `map_focus_provider.dart` — `StateProvider<LatLng?>`
- [x] Créer `badgeable_monuments_provider.dart` — filtre `monumentsProvider` aux catégories "Palais & Monuments emblématiques" + "Musées & Bibliothèques"
- [x] Créer `badge_grid.dart` — `BadgeGrid` (ConsumerStatefulWidget) avec `_UnlockedBadgeCell` (scale-in + chip "Nouveau !") et `_LockedBadgeCell` (bottom sheet + "Voir sur carte")
- [x] Intégrer `BadgeGrid` dans `ChallengesScreen` (section "Monuments" entre Badges Quartiers et Quartiers Progression)
- [x] Brancher `MapScreen` sur `mapFocusProvider` — `_closeMapFocusSub` listener → `_mapController.move(pos, 17.0)` → reset null
- [x] Tests Flutter : 6 nouveaux tests (badge_grid_test × 4, challenges_screen_test +1 "Monuments" +1 spinner avec overrides)
- [x] `flutter analyze --no-pub` → 0 issue ✅
- [x] `flutter test` → 367/367 ✅

## Dev Notes

**Filtre monuments gamifiables** : seules 2 catégories sur ~15 sont retenues (`_kBadgeableCategories` dans `badgeable_monuments_provider.dart`) pour garder une grille lisible (~197 entrées au lieu de 1 999).

**mapFocusProvider** : `StateProvider<LatLng?>` — découple `ChallengesScreen` de `MapScreen` sans passer de callback. `MapScreen` lit la valeur via `ref.listenManual` dans `initState` et remet à null après `_mapController.move(...)` pour éviter les re-centerings intempestifs.

**Animation "Nouveau !"** : `BadgeGrid` maintient deux `Set<String>` — `_knownBadgeIds` (initialisé au premier build sans animation) et `_newBadgeIds` (ajouté dans `didUpdateWidget` + Timer 3s pour retirer). `_UnlockedBadgeCell` porte son propre `AnimationController` via `SingleTickerProviderStateMixin`.

**Bottom sheet verrouillé** : `_LockedBadgeCell` est un `ConsumerWidget` uniquement pour accéder à `ref` dans `_showLockedSheet`. Le `ref` n'est pas lu pendant le build, évitant tout overhead.

## File List

**Nouveaux :**
- `urbink/lib/features/map/providers/map_focus_provider.dart`
- `urbink/lib/features/gamification/providers/badgeable_monuments_provider.dart`
- `urbink/lib/features/gamification/widgets/badge_grid.dart`
- `urbink/test/features/gamification/widgets/badge_grid_test.dart`

**Modifiés :**
- `urbink/lib/features/gamification/screens/challenges_screen.dart`
- `urbink/lib/features/map/screens/map_screen.dart`
- `urbink/test/features/gamification/screens/challenges_screen_test.dart`

## Dev Agent Record

- Tests baseline : 361 → final : 367 (+6 Flutter)
- `flutter analyze --no-pub` : 0 issue ✅
- `flutter test` : 367/367 ✅

## Change Log

- feat(epic-4/story-4.5): grille badges monuments dans Challenges + mapFocusProvider (2026-04-27)

## Status

`done`
