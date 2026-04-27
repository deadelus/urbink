# Implementation Artifact — Story 4.4

## Story
Epic 4 · Story 4.4 — Badges monuments — détection proximité GPS

## ACs implémentés

- [x] Given la Cloud Function `on_monument_proximity.go` / When la position GPS d'un utilisateur en session est à ≤ 100m d'un monument configuré / Then la Cloud Function vérifie que le badge n'est pas déjà débloqué, puis le crée dans `/users/{userId}/badges/` et déclenche FCM (FR18)
- [x] Given un badge monument créé dans Firestore / When `monumentBadgesStreamProvider` reçoit la mise à jour / Then `CelebrationOverlay` est déclenché côté app en état `badge` — le feedback haptique fort est émis
- [x] Given un monument dont le badge est déjà débloqué / When l'utilisateur repasse à proximité / Then aucun déclenchement — déduplication via `_triggeredMonuments` (Set local) + `monumentBadgeIdsProvider` + idempotence CF

## Tasks / Subtasks

- [x] Créer `MonumentBadge` model (`lib/features/gamification/models/monument_badge.dart`)
- [x] Créer `monument_badges_provider.dart` — stream Firestore `/badges/monument_*` + `monumentBadgeIdsProvider` + `writeMonumentProximityEvent`
- [x] Créer `monument_proximity_provider.dart` — `monumentProximityStreamProvider` (≤ 100m, session active uniquement)
- [x] Brancher `MapScreen` — listener proximité → écriture event Firestore + listener badge → CelebrationQueue + `HapticFeedback.heavyImpact()`
- [x] Créer Cloud Function `functions/on_monument_proximity/main.go` (Go)
- [x] Tests Flutter : 12 nouveaux tests (model, providers, proximity stream)
- [x] Tests Go : 9 tests (parseEventResource, process, buildFCMMessage)
- [x] `flutter analyze --no-pub` → 0 issue ✅
- [x] `flutter test` → 361/361 ✅

## Dev Notes

**Architecture flux** : Flutter détecte la proximité via `monumentProximityStreamProvider` (watch `gpsTrackingServiceProvider.positionStream()` + session active guard). Quand un monument est dans le rayon, `MapScreen` écrit un document dans `/users/{userId}/monument_proximity_events/monument_{id}`. La Cloud Function `on_monument_proximity` est un trigger Firestore onCreate sur cette collection — elle vérifie l'idempotence, crée le badge dans `/users/{userId}/badges/monument_{id}`, envoie FCM.

**Idempotence multi-niveau** :
1. `_triggeredMonuments` (Set local MapScreen) — évite les rééecritures event en mémoire vive
2. `monumentBadgeIdsProvider` — vérifie les badges Firestore déjà présents au démarrage
3. Cloud Function `badgeExists()` — vérification Firestore avant toute écriture de badge

**CelebrationOverlay** : déclenché dans `MapScreen` via `ref.listenManual(monumentBadgesStreamProvider)` — compare `prev` vs `next` pour détecter les nouveaux badges et push dans `celebrationQueueProvider`.

**Haptics** : `HapticFeedback.heavyImpact()` appelé à chaque nouveau badge monument dans le listener `_closeMonumentBadgeSub`.

**Monuments existants** : les 1 999 monuments de `assets/geo/paris/monuments.json` sont utilisés sans modification — tous ont un champ `id` et `categoryIcon` qui servent respectivement de `monumentId` et `emoji` du badge.

**rayon de détection** : `kMonumentProximityRadiusMeters = 100.0` (constante exportée pour les tests).

## File List

**Nouveaux :**
- `urbink/lib/features/gamification/models/monument_badge.dart`
- `urbink/lib/features/gamification/providers/monument_badges_provider.dart`
- `urbink/lib/features/map/providers/monument_proximity_provider.dart`
- `functions/on_monument_proximity/main.go`
- `functions/on_monument_proximity/main_test.go`
- `urbink/test/features/gamification/models/monument_badge_test.dart`
- `urbink/test/features/gamification/providers/monument_badges_provider_test.dart`
- `urbink/test/features/map/providers/monument_proximity_provider_test.dart`

**Modifiés :**
- `urbink/lib/features/map/screens/map_screen.dart`

## Dev Agent Record

- Tests baseline : 349 → final : 361 (+12 Flutter, +9 Go)
- `flutter analyze --no-pub` : 0 issue ✅
- `flutter test` : 361/361 ✅
- `go test ./on_monument_proximity/...` : 9/9 ✅

## Change Log

- feat(epic-4/story-4.4): badges monuments détection proximité GPS ≤ 100m + CF idempotente + CelebrationOverlay + haptics (2026-04-27)

## Status

`review`
