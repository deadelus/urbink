# Story 2.8 : Tracking passif toujours actif — couche 1 (FR0)

Status: done

## Story

En tant qu'**utilisateur** (y compris invité),
Je veux que les rues se colorient automatiquement dès que j'ouvre l'app et que je marche, sans aucune action de ma part,
Afin de voir mon territoire exploré se construire librement, même sans créer de compte ou démarrer une session.

## Acceptance Criteria

- [x] **AC1 — Tracking passif actif** : Given l'app lancée et la permission GPS accordée ; When l'utilisateur se déplace (même sans session démarrée) ; Then `gps_tracking_service.dart` émet des positions et le système snap-to-road colorie les rues via `MapStreetOverlay` — le tracking passif est actif indépendamment de toute session enregistrée (FR0).

- [x] **AC2 — Sauvegarde anonyme** : Given un utilisateur en mode invité (Anonymous Auth) ; When il marche avec l'app ouverte ; Then les rues colorées sont sauvegardées sous son UID anonyme Firestore (`users/{uid}/streets/{streetId}`) — la progression est conservée si l'utilisateur crée un compte ultérieurement via `linkWithCredential()`.

- [x] **AC3 — Toggle Zones ON/OFF** : Given le toggle "Zones ON/OFF" (FR10b) ; When l'utilisateur tape le pill 🟢 Zones bas-gauche ; Then l'affichage des rues colorées est activé/désactivé sur la carte — le tracking passif continue en arrière-plan indépendamment de l'état du toggle.

- [x] **AC4 — Background tracking** : Given l'app mise en arrière-plan ; When l'utilisateur marche téléphone en poche ; Then le tracking passif continue (background location iOS via `UIBackgroundModes = [location]` + `AppleSettings.pauseLocationUpdatesAutomatically = false`) et les rues se colorient au retour au premier plan.

## Tasks / Subtasks

- [x] **T1 — `passiveGpsStreamProvider`** (AC: 1, 4)
  - [x] Ajouter `passiveGpsStreamProvider` dans `gps_tracking_provider.dart` — stream toujours actif si permission accordée, sans gate session
  - [x] Refactoriser `GpsTrackingService.positionStream()` : état `lastPosition` closure-local (pas instance field) → plusieurs streams simultanés indépendants sans interférence d'état
  - [x] `gpsPositionStreamProvider` conservé pour `sessionMetricsProvider` — appel direct à `gpsService.positionStream()` (stream indépendant, état propre)

- [x] **T2 — `PassiveStreetRepository`** (AC: 2)
  - [x] Créer `urbink/lib/features/map/services/passive_street_repository.dart`
  - [x] Interface `PassiveStreetRepository` + impl `FirestorePassiveStreetRepository`
  - [x] `saveStreet(userId, streetId)` → `users/{uid}/streets/{streetId}` avec `{lastExploredAt: Timestamp}` et `SetOptions(merge: true)`
  - [x] `passiveStreetRepositoryProvider` dans le même fichier

- [x] **T3 — Toggle Zones** (AC: 3)
  - [x] Créer `urbink/lib/features/map/providers/streets_visible_provider.dart` — `StateProvider<bool>` initialisé à `true`
  - [x] Créer `urbink/lib/shared/widgets/zones_toggle_pill.dart` — pill bas-gauche avec `AnimatedContainer`, icône `layers_rounded`/`layers_clear_rounded`, fond Vert Sauge / gris selon état

- [x] **T4 — `MapStreetOverlayNotifier`** (AC: 1, 2, 3)
  - [x] Écoute `passiveGpsStreamProvider` au lieu de `gpsPositionStreamProvider`
  - [x] Appel `passiveStreetRepositoryProvider.saveStreet()` via `unawaited()` quand rue nouvelle en mémoire
  - [x] Import `currentUidProvider` (depuis `session_lifecycle_provider.dart`) pour récupérer l'UID

- [x] **T5 — UI** (AC: 3)
  - [x] `MapStreetOverlay` : vérification `streetsVisibleProvider` en tête de `build()` — retourne `SizedBox.shrink()` si masqué
  - [x] `MapScreen` : ajout `Positioned(left: 16, bottom: 16, child: ZonesTogglePill())` dans le Stack

## Dev Notes

### Architecture : deux streams GPS indépendants
`GpsTrackingService.positionStream()` créait un état partagé `_lastPosition` (instance field). Deux appels simultanés auraient interféré. Résolution : `lastPosition` est maintenant closure-local — chaque appel à `positionStream()` a son propre état de filtrage.

Résultat :
- `passiveGpsStreamProvider` — toujours actif, écoute `MapStreetOverlayNotifier`
- `gpsPositionStreamProvider` — actif uniquement si session active, écoute `SessionMetricsNotifier`
- Les deux coexistent sans interférence.

### Pas de `.stream` deprecated
Approche initiale (filtrer le passif via `ref.watch(passiveGpsStreamProvider.stream)`) abandonnée car `.stream` est deprecated depuis Riverpod 3.0. Les deux streams appellent `gpsService.positionStream()` directement avec leur propre état.

### Persistance Firestore passive
`saveStreet` est appelé uniquement quand la rue est absente de `exploredStreets` (état mémoire) — évite un appel Firestore à chaque position GPS sur une rue déjà visitée. En cas d'erreur Firestore, log silencieux via `catchError`.

### Background iOS
Déjà configuré depuis Story 2.2 : `UIBackgroundModes = [location]` dans `Info.plist`, `AppleSettings(pauseLocationUpdatesAutomatically: false, showBackgroundLocationIndicator: true)`. Le tracking passif bénéficie automatiquement de cette configuration.

### Pas de chargement Firestore au démarrage
Les rues explorées précédemment ne sont pas rechargées depuis Firestore au démarrage — `exploredStreets` repart de zéro à chaque lancement. Les rues se colorient à nouveau quand l'utilisateur les reparcourt. Chargement depuis Firestore prévu dans une story ultérieure (Epic 3 — Historique).

## Dev Agent Record

### Agent
Claude Sonnet 4.6

### Completion Notes
- 58/58 tests passent — aucune régression
- `flutter analyze --no-pub` : aucune erreur

## File List

### New Files
- `urbink/lib/features/map/services/passive_street_repository.dart`
- `urbink/lib/features/map/providers/streets_visible_provider.dart`
- `urbink/lib/shared/widgets/zones_toggle_pill.dart`

### Modified Files
- `urbink/lib/features/sessions/services/gps_tracking_service.dart` — `lastPosition` closure-local dans `positionStream()`
- `urbink/lib/features/sessions/providers/gps_tracking_provider.dart` — ajout `passiveGpsStreamProvider`
- `urbink/lib/features/map/providers/map_street_overlay_provider.dart` — écoute passive + persist Firestore
- `urbink/lib/shared/widgets/map_street_overlay.dart` — respect `streetsVisibleProvider`
- `urbink/lib/features/map/screens/map_screen.dart` — ajout `ZonesTogglePill`

## Change Log

| Date | Version | Description | Author |
|------|---------|-------------|--------|
| 2026-04-15 | 1.0 | Implémentation initiale Story 2.8 | Claude Sonnet 4.6 |
