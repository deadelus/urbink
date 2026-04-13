import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:urbink/features/map/models/map_street_overlay_state.dart';
import 'package:urbink/features/sessions/providers/gps_tracking_provider.dart';
import 'package:urbink/features/sessions/session_state_provider.dart';

class MapStreetOverlayNotifier extends Notifier<MapStreetOverlayState> {
  var _disposed = false;
  // Séquence pour ignorer les réponses réseau arrivées hors ordre
  int _callSeq = 0;

  @override
  MapStreetOverlayState build() {
    _disposed = false;
    _callSeq = 0;
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
    // Capture la séquence avant l'appel réseau pour détecter les réponses tardives
    final seq = ++_callSeq;
    final snapService = ref.read(snapToRoadServiceProvider);
    final streetId = await snapService.snapToRoad(position);

    // Réponse obsolète : une position plus récente a déjà été traitée
    if (_disposed || seq != _callSeq) return;

    // Pas de snap disponible : conserver l'état courant sans rebuild inutile
    if (streetId == null) return;

    final point = LatLng(position.latitude, position.longitude);
    final current = state;

    // Copie superficielle du Map + copie profonde uniquement de la rue concernée
    final updated = Map<String, List<LatLng>>.of(current.exploredStreets);
    updated[streetId] = List<LatLng>.from(updated[streetId] ?? [])..add(point);

    state = MapStreetOverlayState(
      exploredStreets: updated,
      currentStreetId: streetId,
    );
  }

  /// Réinitialise l'overlay (ex: nouvelle session).
  void clear() {
    _callSeq++; // invalide tout appel réseau en cours
    state = const MapStreetOverlayState();
  }
}

final mapStreetOverlayProvider =
    NotifierProvider<MapStreetOverlayNotifier, MapStreetOverlayState>(
  MapStreetOverlayNotifier.new,
);
