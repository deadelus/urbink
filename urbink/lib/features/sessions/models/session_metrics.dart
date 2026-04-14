import 'package:urbink/features/sessions/models/transport_mode.dart';

/// Métriques temps réel d'une session d'exploration.
class SessionMetrics {
  /// Moment de démarrage de la session (`null` quand aucune session active).
  final DateTime? sessionStartTime;

  /// Distance totale parcourue en mètres depuis le début de la session.
  final double distanceMeters;

  /// Identifiants OSM des rues uniques explorées pendant la session.
  final Set<String> exploredStreetIds;

  /// Mode de déplacement détecté automatiquement à l'instant courant (fenêtre 30s).
  final TransportMode detectedMode;

  /// Nombre de ticks GPS par mode de déplacement — utilisé pour calculer le mode dominant.
  final Map<TransportMode, int> modeTicks;

  const SessionMetrics({
    this.sessionStartTime,
    this.distanceMeters = 0.0,
    this.exploredStreetIds = const {},
    this.detectedMode = TransportMode.walking,
    this.modeTicks = const {},
  });

  /// Nombre de rues uniques explorées.
  int get streetCount => exploredStreetIds.length;

  /// Distance en kilomètres.
  double get distanceKm => distanceMeters / 1000;

  /// Durée écoulée depuis le démarrage de la session.
  Duration get elapsed => sessionStartTime != null
      ? DateTime.now().difference(sessionStartTime!)
      : Duration.zero;

  /// Mode de déplacement majoritaire sur toute la session.
  ///
  /// Retourne le mode avec le plus de ticks GPS.
  /// Fallback sur [detectedMode] si aucun tick enregistré.
  TransportMode get dominantMode {
    if (modeTicks.isEmpty) return detectedMode;
    return modeTicks.entries
        .reduce((a, b) => a.value >= b.value ? a : b)
        .key;
  }

  SessionMetrics copyWith({
    DateTime? sessionStartTime,
    double? distanceMeters,
    Set<String>? exploredStreetIds,
    TransportMode? detectedMode,
    Map<TransportMode, int>? modeTicks,
  }) {
    return SessionMetrics(
      sessionStartTime: sessionStartTime ?? this.sessionStartTime,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      exploredStreetIds: exploredStreetIds ?? this.exploredStreetIds,
      detectedMode: detectedMode ?? this.detectedMode,
      modeTicks: modeTicks ?? this.modeTicks,
    );
  }
}
