import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum TimeFilter { allTime, today, thisWeek, thisMonth }

extension TimeFilterX on TimeFilter {
  String get label => switch (this) {
        TimeFilter.allTime => 'Tout',
        TimeFilter.today => "Aujourd'hui",
        TimeFilter.thisWeek => 'Cette semaine',
        TimeFilter.thisMonth => 'Ce mois',
      };

  /// Borne inférieure de la période filtrée, null = pas de filtre (tout l'historique).
  /// [now] injectable pour les tests — utilise [DateTime.now] si omis.
  DateTime? from([DateTime? now]) {
    final n = now ?? DateTime.now();
    return switch (this) {
      TimeFilter.allTime => null,
      TimeFilter.today => DateTime(n.year, n.month, n.day),
      TimeFilter.thisWeek => DateTime(n.year, n.month, n.day - 7),
      TimeFilter.thisMonth => DateTime(n.year, n.month, 1),
    };
  }
}

class TimeFilterNotifier extends StateNotifier<TimeFilter> {
  TimeFilterNotifier() : super(TimeFilter.allTime) {
    _load();
  }

  @visibleForTesting
  TimeFilterNotifier.forTest(super.initial);

  static const _prefKey = 'time_filter';

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_prefKey);
      // Guard: discard persisted value if the user already made a selection
      // before _load() completed (avoids overwriting a recent interaction).
      if (saved != null && mounted && state == TimeFilter.allTime) {
        state = TimeFilter.values.firstWhere(
          (f) => f.name == saved,
          orElse: () => TimeFilter.allTime,
        );
      }
    } catch (_) {
      // SharedPreferences indisponible (env test) — conserver allTime
    }
  }

  Future<void> select(TimeFilter filter) async {
    if (filter == state) return;
    state = filter;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, filter.name);
    } catch (_) {}
  }
}

final timeFilterProvider =
    StateNotifierProvider<TimeFilterNotifier, TimeFilter>(
  (ref) => TimeFilterNotifier(),
);
