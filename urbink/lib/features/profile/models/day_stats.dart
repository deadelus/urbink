import 'package:urbink/features/sessions/models/session.dart';

/// Statistiques agrégées d'un jour pour le WeekHistogram.
class DayStats {
  const DayStats({
    required this.date,
    required this.streetCount,
    required this.distanceKm,
    required this.totalDuration,
    required this.sessions,
  });

  /// Date du jour (minuit heure locale).
  final DateTime date;

  /// Nombre de rues uniques explorées ce jour (union de tous les streetIds).
  final int streetCount;

  final double distanceKm;
  final Duration totalDuration;

  /// Sessions individuelles du jour, triées par début décroissant.
  final List<Session> sessions;

  bool get isEmpty => sessions.isEmpty;

  static DayStats empty(DateTime date) => DayStats(
        date: date,
        streetCount: 0,
        distanceKm: 0,
        totalDuration: Duration.zero,
        sessions: const [],
      );
}
