# Story 2.3 : Composant MapStreetOverlay — coloration des rues explorées

Status: done

## Story

En tant qu'**utilisateur**,
Je veux voir mes rues explorées se colorier sur la carte en temps réel,
Afin de visualiser mon territoire personnel d'exploration.

## Acceptance Criteria

- [x] **AC1 — Polyline Vert Sauge** : Les rues explorées s'affichent en `UrbinkColors.streetExplored` (#5A7A5A), opacité 0.75, strokeWidth 4.0, dans le délai de traitement snap to road (~200ms).
- [x] **AC2 — Rue courante signalée** : La rue en cours d'exploration s'affiche en `UrbinkColors.streetRecording` (#6A9A6A), strokeWidth 5.5 — visuellement distinct sans animation complexe.
- [x] **AC3 — Rendu fluide** : `PolylineLayer` flutter_map (rendu canvas natif). Overlay absent du widget tree quand `isEmpty` (`SizedBox.shrink`) — aucun rebuild inutile.
- [x] **AC4 — État idle** : Toutes les rues explorées restent affichées quand la session est idle — seul `currentStreetId` est effacé.

## Tasks / Subtasks

- [x] **T1 — `map_street_overlay_state.dart`** : Modèle d'état avec `exploredStreets: Map<String, List<LatLng>>`, `currentStreetId`, `copyWith`, `isEmpty`.
- [x] **T2 — `map_street_overlay_provider.dart`** : `MapStreetOverlayNotifier` — écoute `gpsPositionStreamProvider`, appelle `snapToRoadServiceProvider`, update state. Guard `_disposed` post-async. `clear()` public.
- [x] **T3 — `shared/widgets/map_street_overlay.dart`** : `ConsumerWidget` → `PolylineLayer` avec couleurs/strokeWidth conditionnels. `SizedBox.shrink` si état vide.
- [x] **T4 — `map_screen.dart`** : `MapStreetOverlay()` ajouté dans les children `FlutterMap` après `VectorTileLayer`.
- [x] **T5 — Tests** : 5 tests `MapStreetOverlayState` + 4 tests `MapStreetOverlayNotifier` avec overrides Riverpod.

## Dev Notes

- `ref.mounted` absent sur `NotifierProviderRef` → pattern `_disposed` flag + `ref.onDispose`.
- `PolylineLayer` filtre les rues avec `< 2` points (pas de polyline avec un seul point).
- `clear()` conservé pour usage futur (Story 2.5 — fin de session).
- Historique des rues non effacé au passage idle — effacement explicite via `clear()` seulement.

## Dev Agent Record

- Agent: Claude Sonnet 4.6
- Branch: `epic-2/story-2.3-map-street-overlay`
- Date: 2026-04-13

## File List

- `urbink/lib/features/map/models/map_street_overlay_state.dart` — nouveau
- `urbink/lib/features/map/providers/map_street_overlay_provider.dart` — nouveau
- `urbink/lib/shared/widgets/map_street_overlay.dart` — nouveau
- `urbink/lib/features/map/screens/map_screen.dart` — ajout MapStreetOverlay
- `urbink/test/features/map/models/map_street_overlay_state_test.dart` — nouveau
- `urbink/test/features/map/providers/map_street_overlay_provider_test.dart` — nouveau

## Change Log

| Date | Version | Description |
|---|---|---|
| 2026-04-13 | 1.0 | Implémentation initiale Story 2.3 |
