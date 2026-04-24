import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urbink/features/profile/models/day_stats.dart';
import 'package:urbink/features/sessions/models/session.dart';
import 'package:urbink/features/sessions/providers/session_db_provider.dart';
import 'package:urbink/features/sessions/providers/session_lifecycle_provider.dart';

/// Retourne le lundi (ISO week day 1) de la semaine contenant [date].
DateTime startOfWeek(DateTime date) {
  final daysFromMonday = date.weekday - 1; // weekday: 1=Lun, 7=Dim
  return DateTime(date.year, date.month, date.day - daysFromMonday);
}

/// Agrège les sessions par jour et retourne 7 [DayStats] (Lun → Dim)
/// pour la semaine courante.
class WeekHistogramNotifier extends AsyncNotifier<List<DayStats>> {
  @override
  Future<List<DayStats>> build() async {
    // Watch uid avant tout await pour que Riverpod enregistre la dépendance.
    final uid = ref.watch(currentUidProvider);
    if (uid == null) return _emptyWeek();

    final cache = ref.read(sessionLocalCacheProvider);
    final weekStart = startOfWeek(DateTime.now());
    final sessions = await cache.getSessionsForWeek(uid, weekStart);
    return _aggregateByDay(weekStart, sessions);
  }

  List<DayStats> _emptyWeek() {
    final weekStart = startOfWeek(DateTime.now());
    return List.generate(
      7,
      (i) => DayStats.empty(weekStart.add(Duration(days: i))),
    );
  }

  List<DayStats> _aggregateByDay(DateTime weekStart, List<Session> sessions) {
    return List.generate(7, (i) {
      final day = weekStart.add(Duration(days: i));
      final daySessions = sessions
          .where((s) =>
              s.sessionStart.year == day.year &&
              s.sessionStart.month == day.month &&
              s.sessionStart.day == day.day)
          .toList();

      if (daySessions.isEmpty) return DayStats.empty(day);

      final allStreetIds = <String>{};
      for (final s in daySessions) {
        allStreetIds.addAll(s.streetIds);
      }
      final totalDistanceKm =
          daySessions.fold(0.0, (sum, s) => sum + s.distanceKm);
      final totalDuration =
          daySessions.fold(Duration.zero, (sum, s) => sum + s.duration);

      return DayStats(
        date: day,
        streetCount: max(0, allStreetIds.length),
        distanceKm: totalDistanceKm,
        totalDuration: totalDuration,
        sessions: daySessions,
      );
    });
  }
}

final weekHistogramProvider =
    AsyncNotifierProvider<WeekHistogramNotifier, List<DayStats>>(
  WeekHistogramNotifier.new,
);
