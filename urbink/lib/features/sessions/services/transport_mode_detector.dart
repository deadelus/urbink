import 'package:urbink/features/sessions/models/transport_mode.dart';

/// Détecte automatiquement le mode de déplacement à partir des vitesses GPS.
///
/// Utilise une fenêtre glissante de 30 secondes sur les échantillons de vitesse
/// pour lisser les fluctuations GPS et éviter les oscillations de mode.
///
/// Seuils (FR4) :
/// - < 7 km/h  (< 1.944 m/s) → [TransportMode.walking]
/// - 7–30 km/h (1.944–8.333 m/s) → [TransportMode.cycling]
/// - > 30 km/h (> 8.333 m/s) → [TransportMode.driving]
class TransportModeDetector {
  static const double _walkMaxMps = 7.0 / 3.6; // 1.944 m/s
  static const double _bikeMaxMps = 30.0 / 3.6; // 8.333 m/s
  static const Duration _windowDuration = Duration(seconds: 30);

  final List<_Sample> _samples = [];
  TransportMode _currentMode = TransportMode.walking;

  /// Met à jour la fenêtre glissante avec une nouvelle mesure et retourne
  /// le mode classifié.
  ///
  /// [speedMps] : vitesse en m/s depuis [Position.speed].
  /// Valeurs < 0 (GPS non localisé) sont ignorées — le mode courant est conservé.
  TransportMode update(double speedMps, DateTime at) {
    if (speedMps < 0) return _currentMode;

    // Purge les échantillons hors fenêtre
    final cutoff = at.subtract(_windowDuration);
    _samples.removeWhere((s) => s.at.isBefore(cutoff));

    _samples.add(_Sample(speedMps: speedMps, at: at));

    final avg =
        _samples.map((s) => s.speedMps).reduce((a, b) => a + b) / _samples.length;
    _currentMode = classify(avg);
    return _currentMode;
  }

  /// Classifie une vitesse moyenne en mode de déplacement.
  ///
  /// Méthode statique — exposée pour les tests unitaires.
  static TransportMode classify(double avgSpeedMps) {
    if (avgSpeedMps < _walkMaxMps) return TransportMode.walking;
    if (avgSpeedMps <= _bikeMaxMps) return TransportMode.cycling;
    return TransportMode.driving;
  }
}

class _Sample {
  final double speedMps;
  final DateTime at;
  const _Sample({required this.speedMps, required this.at});
}
