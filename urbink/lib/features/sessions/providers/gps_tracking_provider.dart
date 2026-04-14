import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:urbink/features/sessions/services/gps_tracking_service.dart';
import 'package:urbink/features/sessions/services/snap_to_road_service.dart';
import 'package:urbink/features/sessions/session_state_provider.dart';
import 'package:urbink/shared/utils/nominatim_client.dart';

/// Provider du service GPS (singleton pour toute la session app).
final gpsTrackingServiceProvider = Provider<GpsTrackingService>(
  (ref) => GpsTrackingService(),
);

/// Provider du client Nominatim.
/// Propriétaire du cycle de vie du client : le ferme à la destruction du provider.
final nominatimClientProvider = Provider<NominatimClient>((ref) {
  final client = NominatimClient();
  ref.onDispose(client.dispose); // seul responsable du dispose du client
  return client;
});

/// Provider du service snap-to-road.
/// Le client est injecté depuis [nominatimClientProvider] : SnapToRoadService
/// n'en est pas propriétaire (_ownsClient = false) et n'appellera pas
/// client.dispose() — évite un double-close sur la même instance.
final snapToRoadServiceProvider = Provider<SnapToRoadService>((ref) {
  final nominatimClient = ref.watch(nominatimClientProvider);
  final service = SnapToRoadService(nominatimClient: nominatimClient);
  ref.onDispose(service.dispose); // dispose le service uniquement, pas le client
  return service;
});

/// Stream de positions GPS passif — toujours actif quand la permission GPS est accordée.
///
/// Ne dépend pas de l'état de session — émet des positions dès que l'utilisateur
/// se déplace, indépendamment de toute session enregistrée (FR0, tracking passif).
/// Utilisé par [mapStreetOverlayProvider] pour colorier les rues en continu.
///
/// Chaque appel à [GpsTrackingService.positionStream] crée un stream indépendant
/// avec son propre état de filtrage — pas d'interférence avec [gpsPositionStreamProvider].
final passiveGpsStreamProvider = StreamProvider<Position>((ref) async* {
  final gpsService = ref.watch(gpsTrackingServiceProvider);
  // Utilise locationPermissionProvider (overrideable en test) plutôt qu'un
  // appel direct à Geolocator.checkPermission() pour faciliter les tests.
  final permission = await ref.watch(locationPermissionProvider.future);
  if (permission == LocationPermission.denied ||
      permission == LocationPermission.deniedForever) {
    return;
  }
  yield* gpsService.positionStream();
});

/// Stream de positions GPS — actif uniquement quand la session est active.
///
/// Émet les positions filtrées (déplacement ≥ 10 m).
/// Se coupe automatiquement quand [SessionState] passe à `paused` ou `idle`.
/// Utilisé par [sessionMetricsProvider] pour distance/mode — stream indépendant
/// du passif (état de filtrage propre via closure dans [GpsTrackingService]).
final gpsPositionStreamProvider = StreamProvider<Position>((ref) async* {
  final sessionState = ref.watch(sessionStateProvider);
  if (sessionState != SessionState.active) return;
  final gpsService = ref.watch(gpsTrackingServiceProvider);
  yield* gpsService.positionStream();
});

/// Permission GPS actuelle (null = pas encore vérifié).
final locationPermissionProvider = FutureProvider<LocationPermission>(
  (ref) => Geolocator.checkPermission(),
);
