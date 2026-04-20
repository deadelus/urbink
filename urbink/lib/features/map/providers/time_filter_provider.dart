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
  DateTime? get from {
    final now = DateTime.now();
    return switch (this) {
      TimeFilter.allTime => null,
      TimeFilter.today => DateTime(now.year, now.month, now.day),
      TimeFilter.thisWeek => DateTime(now.year, now.month, now.day - 7),
      TimeFilter.thisMonth => DateTime(now.year, now.month, 1),
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
      if (saved != null && mounted) {
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
