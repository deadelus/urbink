import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:urbink/features/sessions/models/session_metrics.dart';
import 'package:urbink/features/sessions/providers/gps_tracking_provider.dart';
import 'package:urbink/features/sessions/session_state_provider.dart';

class SessionMetricsNotifier extends Notifier<SessionMetrics> {
  var _disposed = false;
  Position? _lastPosition;

  @override
  SessionMetrics build() {
    _disposed = false;
    _lastPosition = null;
    ref.onDispose(() => _disposed = true);

    ref.listen(sessionStateProvider, (previous, next) {
      if (previous == SessionState.idle && next == SessionState.active) {
        // Nouvelle session — réinitialiser avec un nouveau startTime
        _lastPosition = null;
        state = SessionMetrics(sessionStartTime: DateTime.now());
      } else if (next == SessionState.idle) {
        // Session terminée — remettre à zéro
        _lastPosition = null;
        state = const SessionMetrics();
      }
      // paused → active (reprise) : on conserve startTime et les métriques
    });

    ref.listen(gpsPositionStreamProvider, (_, next) {
      next.whenData(_onPosition);
    });

    return const SessionMetrics();
  }

  Future<void> _onPosition(Position position) async {
    // Calcul de la distance depuis la dernière position connue
    final last = _lastPosition;
    final additionalDistance = last != null
        ? Geolocator.distanceBetween(
            last.latitude,
            last.longitude,
            position.latitude,
            position.longitude,
          )
        : 0.0;
    _lastPosition = position;

    // Snap to road pour compter les rues uniques
    final snapService = ref.read(snapToRoadServiceProvider);
    final streetId = await snapService.snapToRoad(position);

    if (_disposed) return;

    final current = state;
    final updatedStreets = {...current.exploredStreetIds};
    if (streetId != null) updatedStreets.add(streetId);

    state = current.copyWith(
      distanceMeters: current.distanceMeters + additionalDistance,
      exploredStreetIds: updatedStreets,
    );
  }
}

final sessionMetricsProvider =
    NotifierProvider<SessionMetricsNotifier, SessionMetrics>(
  SessionMetricsNotifier.new,
);
