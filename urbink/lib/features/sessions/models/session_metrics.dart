/// Métriques temps réel d'une session d'exploration.
class SessionMetrics {
  /// Moment de démarrage de la session (`null` quand aucune session active).
  final DateTime? sessionStartTime;

  /// Distance totale parcourue en mètres depuis le début de la session.
  final double distanceMeters;

  /// Identifiants OSM des rues uniques explorées pendant la session.
  final Set<String> exploredStreetIds;

  const SessionMetrics({
    this.sessionStartTime,
    this.distanceMeters = 0.0,
    this.exploredStreetIds = const {},
  });

  /// Nombre de rues uniques explorées.
  int get streetCount => exploredStreetIds.length;

  /// Distance en kilomètres.
  double get distanceKm => distanceMeters / 1000;

  /// Durée écoulée depuis le démarrage de la session.
  Duration get elapsed => sessionStartTime != null
      ? DateTime.now().difference(sessionStartTime!)
      : Duration.zero;

  SessionMetrics copyWith({
    DateTime? sessionStartTime,
    double? distanceMeters,
    Set<String>? exploredStreetIds,
  }) {
    return SessionMetrics(
      sessionStartTime: sessionStartTime ?? this.sessionStartTime,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      exploredStreetIds: exploredStreetIds ?? this.exploredStreetIds,
    );
  }
}
