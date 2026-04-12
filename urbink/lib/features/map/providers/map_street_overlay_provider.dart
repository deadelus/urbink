import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:urbink/features/map/models/map_street_overlay_state.dart';
import 'package:urbink/features/sessions/providers/gps_tracking_provider.dart';
import 'package:urbink/features/sessions/session_state_provider.dart';

class MapStreetOverlayNotifier extends Notifier<MapStreetOverlayState> {
  var _disposed = false;

  @override
  MapStreetOverlayState build() {
    _disposed = false;
    ref.onDispose(() => _disposed = true);

    // Écoute le stream GPS — chaque nouvelle position déclenche snap to road
    ref.listen(gpsPositionStreamProvider, (_, next) {
      next.whenData(_onPosition);
    });

    // Quand la session repasse idle, effacer la rue courante
    ref.listen(sessionStateProvider, (_, sessionState) {
      if (sessionState == SessionState.idle) {
        state = state.copyWith(clearCurrentStreetId: true);
      }
    });

    return const MapStreetOverlayState();
  }

  Future<void> _onPosition(Position position) async {
    final snapService = ref.read(snapToRoadServiceProvider);
    final streetId = await snapService.snapToRoad(position);

    if (_disposed) return;

    final point = LatLng(position.latitude, position.longitude);
    final current = state;

    // Copie profonde pour immutabilité
    final updated = {
      for (final e in current.exploredStreets.entries)
        e.key: List<LatLng>.from(e.value),
    };

    if (streetId != null) {
      (updated[streetId] ??= []).add(point);
    }

    state = MapStreetOverlayState(
      exploredStreets: updated,
      currentStreetId: streetId,
    );
  }

  /// Réinitialise l'overlay (ex: nouvelle session).
  void clear() => state = const MapStreetOverlayState();
}

final mapStreetOverlayProvider =
    NotifierProvider<MapStreetOverlayNotifier, MapStreetOverlayState>(
  MapStreetOverlayNotifier.new,
);
