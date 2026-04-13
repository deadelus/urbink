# Story 2.4 : SessionCounter + TransportModeSelector — UI session active

Status: done

## Story

En tant qu'**utilisateur**,
Je veux voir mes métriques de session en temps réel et choisir mon mode de déplacement,
Afin de suivre ma progression pendant que j'explore.

## Acceptance Criteria

- [x] **AC1 — SessionCounter pill** : Affiché top-center en `SafeArea + 8pt`, fond #1E1610 @ 85%, affiche `N rues · X.Xkm · HH:MM` mis à jour chaque seconde via `Stream.periodic`.
- [x] **AC2 — Indicateur GPS** : Dot vert fixe (#5A7A5A) si `gpsPositionStreamProvider.hasValue`, dot orange pulsant (AnimationController repeat reverse) en acquisition.
- [x] **AC3 — TransportModeSelector** : 3 chips 🚶 · 🚴 · 🚗 segmentés, chip actif fond Ocre + texte blanc, inactifs fond #F4F2ED. Dernier choix persisté via SharedPreferences (`urbink_transport_mode`).
- [x] **AC4 — Variante Extended** : Hors scope — reporté en Story 5.x (itinéraires).

## Tasks / Subtasks

- [x] **T1 — `models/transport_mode.dart`** : enum `TransportMode` avec `emoji` et `label`.
- [x] **T2 — `models/session_metrics.dart`** : `streetCount`, `distanceKm`, `elapsed`, `copyWith`.
- [x] **T3 — `providers/session_metrics_provider.dart`** : Notifier écoute GPS + snap to road, reset idle→active, conserve paused→active.
- [x] **T4 — `providers/transport_mode_provider.dart`** : Notifier avec SharedPreferences, `select()` async.
- [x] **T5 — `shared/widgets/session_counter.dart`** : `ConsumerStatefulWidget` avec `AnimationController` (pulse) + `Stream.periodic` (chrono). `SizedBox.shrink` si idle.
- [x] **T6 — `shared/widgets/transport_mode_selector.dart`** : `ConsumerWidget`, chips `AnimatedContainer`.
- [x] **T7 — `map_screen.dart`** : `FlutterMap` enveloppé dans `Stack`, `SessionCounter` ajouté.
- [x] **T8 — Tests** : `SessionMetrics` (6 cas) + `TransportModeNotifier` (4 cas).

## Dev Notes

- `_loadFromPrefs()` async dans `build()` → état initial = `walking` puis mis à jour. Test nécessite `Future.delayed(50ms)` + `container.read()` pour déclencher l'init avant d'attendre.
- `sessionMetricsProvider` appelle snap to road indépendamment de `mapStreetOverlayProvider` (2.3). Double appel acceptable au rythme GPS (~10m) — à refactoriser si besoin en Story 3.x.
- Reset idle→active uniquement : paused→active conserve startTime et les métriques (reprise de session).
- AC4 (barre de progression itinéraire) hors scope — reporté Story 5.x.

## Dev Agent Record

- Agent: Claude Sonnet 4.6
- Branch: `epic-2/story-2.4-session-counter-transport-selector`
- Date: 2026-04-13

## File List

- `urbink/lib/features/sessions/models/transport_mode.dart` — nouveau
- `urbink/lib/features/sessions/models/session_metrics.dart` — nouveau
- `urbink/lib/features/sessions/providers/session_metrics_provider.dart` — nouveau
- `urbink/lib/features/sessions/providers/transport_mode_provider.dart` — nouveau
- `urbink/lib/shared/widgets/session_counter.dart` — nouveau
- `urbink/lib/shared/widgets/transport_mode_selector.dart` — nouveau
- `urbink/lib/features/map/screens/map_screen.dart` — Stack + SessionCounter
- `urbink/test/features/sessions/models/session_metrics_test.dart` — nouveau
- `urbink/test/features/sessions/providers/transport_mode_provider_test.dart` — nouveau

## Change Log

| Date | Version | Description |
|---|---|---|
| 2026-04-13 | 1.0 | Implémentation initiale Story 2.4 |
