import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  TimeFilterNotifier() : super(TimeFilter.today);

  @visibleForTesting
  TimeFilterNotifier.forTest(super.initial);

  void select(TimeFilter filter) {
    if (filter == state) return;
    state = filter;
  }
}

final timeFilterProvider =
    StateNotifierProvider<TimeFilterNotifier, TimeFilter>(
  (ref) => TimeFilterNotifier(),
);
