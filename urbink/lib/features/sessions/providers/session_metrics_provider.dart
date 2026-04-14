import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:urbink/features/sessions/models/session_metrics.dart';
import 'package:urbink/features/sessions/models/transport_mode.dart';
import 'package:urbink/features/sessions/providers/gps_tracking_provider.dart';
import 'package:urbink/features/sessions/services/transport_mode_detector.dart';
import 'package:urbink/features/sessions/session_state_provider.dart';

class SessionMetricsNotifier extends Notifier<SessionMetrics> {
  var _disposed = false;
  Position? _lastPosition;
  // Incrémenté à chaque reset session — invalide les réponses snap-to-road
  // arrivées après un changement d'état (active→idle).
  int _sessionToken = 0;
  late TransportModeDetector _detector;

  @override
  SessionMetrics build() {
    _disposed = false;
    _lastPosition = null;
    _sessionToken++;
    _detector = TransportModeDetector();
    ref.onDispose(() => _disposed = true);

    ref.listen(sessionStateProvider, (previous, next) {
      if (previous == SessionState.idle && next == SessionState.active) {
        // Nouvelle session — réinitialiser avec un nouveau startTime
        _lastPosition = null;
        _sessionToken++;
        state = SessionMetrics(sessionStartTime: DateTime.now());
      } else if (next == SessionState.idle) {
        // Session terminée — remettre à zéro
        _lastPosition = null;
        _sessionToken++;
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
    // Capture le token avant l'appel réseau
    final token = _sessionToken;

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

    // Auto-détection du mode de déplacement (fenêtre glissante 30s)
    final newMode = _detector.update(position.speed, DateTime.now());

    // Snap to road pour compter les rues uniques
    final snapService = ref.read(snapToRoadServiceProvider);
    final streetId = await snapService.snapToRoad(position);

    // Réponse obsolète : session réinitialisée entre-temps
    if (_disposed || token != _sessionToken) return;

    final current = state;
    final updatedStreets = {...current.exploredStreetIds};
    if (streetId != null) updatedStreets.add(streetId);

    final updatedTicks = Map<TransportMode, int>.from(current.modeTicks);
    updatedTicks[newMode] = (updatedTicks[newMode] ?? 0) + 1;

    state = current.copyWith(
      distanceMeters: current.distanceMeters + additionalDistance,
      exploredStreetIds: updatedStreets,
      detectedMode: newMode,
      modeTicks: updatedTicks,
    );
  }
}

final sessionMetricsProvider =
    NotifierProvider<SessionMetricsNotifier, SessionMetrics>(
  SessionMetricsNotifier.new,
);

/// Mode de déplacement auto-détecté en temps réel (fenêtre GPS 30s).
///
/// Utilisé par [SessionStatusBar] pour afficher l'icône de mode.
final autoDetectedModeProvider = Provider<TransportMode>(
  (ref) => ref.watch(sessionMetricsProvider).detectedMode,
);
