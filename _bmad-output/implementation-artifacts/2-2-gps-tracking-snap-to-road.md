# Story 2.2 : Tracking GPS temps réel + snap to road Nominatim

Status: done

## Story

En tant qu'**utilisateur**,
Je veux que l'app suive ma position GPS en temps réel et identifie la rue sur laquelle je marche,
Afin que mes rues se colorient avec précision.

## Acceptance Criteria

- [x] **AC1 — Stream GPS actif pendant session** : `gps_tracking_service.dart` émet la position GPS toutes les ~10 mètres via un stream Riverpod — `gpsPositionStreamProvider` actif uniquement quand `SessionState.active`.
- [x] **AC2 — Snap to road Nominatim ≤ 200ms** : `snap_to_road_service.dart` appelle Nominatim et retourne le `streetId` OSM le plus proche (`osm_type:osm_id`). Latence nominale ≤ 200ms en conditions normales.
- [x] **AC3 — Retry x3 backoff exponentiel** : En cas d'erreur réseau, 3 tentatives automatiques avec backoff (1s, 2s, 4s). En cas d'échec persistant, la session continue sans snap to road (`null` retourné silencieusement).
- [x] **AC4 — Background location iOS** : `Info.plist` configuré avec `UIBackgroundModes: [location]`, `NSLocationAlwaysAndWhenInUseUsageDescription`. `AppleSettings(pauseLocationUpdatesAutomatically: false, showBackgroundLocationIndicator: true)`.
- [x] **AC5 — Permission "Toujours autoriser"** : `GpsTrackingService.requestPermission()` demande la permission WhenInUse puis tente l'escalade vers Always sur iOS.

## Tasks / Subtasks

- [x] **T1 — `Info.plist`** (AC4, AC5) : `NSLocationWhenInUseUsageDescription`, `NSLocationAlwaysAndWhenInUseUsageDescription`, `UIBackgroundModes: [location]`
- [x] **T2 — `shared/utils/nominatim_client.dart`** (AC2, AC3) : Client HTTP Nominatim avec rate limit 1 req/s et retry x3 backoff exponentiel. `NominatimResult` avec `streetId` et `displayName`.
- [x] **T3 — `features/sessions/services/gps_tracking_service.dart`** (AC1, AC4, AC5) : Stream filtré ≥ 10m. `AppleSettings` pour iOS, `LocationSettings` générique fallback. `hasMovedEnoughBetween` exposé `@visibleForTesting`.
- [x] **T4 — `features/sessions/services/snap_to_road_service.dart`** (AC2, AC3) : Délègue à `NominatimClient`, retourne `String?`.
- [x] **T5 — `features/sessions/providers/gps_tracking_provider.dart`** (AC1) : `gpsTrackingServiceProvider`, `nominatimClientProvider`, `snapToRoadServiceProvider`, `gpsPositionStreamProvider`, `locationPermissionProvider`.
- [x] **T6 — Tests** : 8 tests unitaires — `NominatimClient` (4 cas), `SnapToRoadService` (2 cas), `GpsTrackingService.hasMovedEnoughBetween` (4 cas).

## Dev Notes

- `NominatimClient` injectable via constructeur (`httpClient` param) → testable sans mock framework (utilise `package:http/testing.dart`).
- Rate limit 1,1s (légèrement > 1s pour absorber les variations réseau).
- `gpsPositionStreamProvider` surveille `sessionStateProvider` : retour immédiat si `!= active`, le provider se réinitialise automatiquement au changement d'état.
- `_hasMovedEnough` filtre à double niveau : `distanceFilter: 5` côté geolocator, puis `>= 10m` dans le stream Dart.
- Background mode iOS : `showBackgroundLocationIndicator: true` affiche la barre bleue iOS — requis pour la transparence utilisateur.

## Dev Agent Record

- Agent: Claude Sonnet 4.6
- Branch: `epic-2/story-2.2-gps-tracking-snap-to-road`
- Date: 2026-04-13

## File List

- `urbink/ios/Runner/Info.plist` — ajout permissions GPS + UIBackgroundModes
- `urbink/lib/shared/utils/nominatim_client.dart` — nouveau
- `urbink/lib/features/sessions/services/gps_tracking_service.dart` — nouveau
- `urbink/lib/features/sessions/services/snap_to_road_service.dart` — nouveau
- `urbink/lib/features/sessions/providers/gps_tracking_provider.dart` — nouveau
- `urbink/test/shared/utils/nominatim_client_test.dart` — nouveau
- `urbink/test/features/sessions/services/snap_to_road_service_test.dart` — nouveau
- `urbink/test/features/sessions/services/gps_tracking_service_test.dart` — nouveau

## Change Log

| Date | Version | Description |
|---|---|---|
| 2026-04-13 | 1.0 | Implémentation initiale Story 2.2 |
