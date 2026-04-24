import 'dart:math';

import 'package:flutter/material.dart';
import 'package:urbink/features/profile/models/day_stats.dart';
import 'package:urbink/shared/constants/colors.dart';
import 'package:urbink/shared/constants/spacing.dart';

/// Histogramme 7 barres Lun → Dim représentant l'activité de la semaine.
///
/// Chaque barre est proportionnelle au nombre de rues explorées ce jour.
/// Le jour courant est affiché en Ocre [UrbinkColors.histogramOcre].
/// Les jours sans activité affichent une barre fantôme [UrbinkColors.histogramGhost].
/// Une barre tapée sélectionne le filtre du jour (re-taper la déselectionne).
class WeekHistogram extends StatelessWidget {
  const WeekHistogram({
    super.key,
    required this.days,
    required this.selectedDayIndex,
    required this.onDayTapped,
  });

  /// 7 jours Lun → Dim de la semaine courante.
  final List<DayStats> days;

  /// Index du jour sélectionné (null = pas de filtre).
  final int? selectedDayIndex;

  /// Appelé avec l'index du jour tapé, ou null pour désélectionner.
  final ValueChanged<int?> onDayTapped;

  static const _maxBarHeight = 72.0;
  static const _minActiveHeight = 10.0;
  static const _ghostHeight = 6.0;

  static const _dayLabels = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final maxStreets = days.fold(0, (m, d) => max(m, d.streetCount));

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(7, (i) {
        final day = days[i];
        final isToday = day.date.year == now.year &&
            day.date.month == now.month &&
            day.date.day == now.day;
        final isSelected = selectedDayIndex == i;

        final barHeight = _computeBarHeight(day, maxStreets);
        final barColor = _barColor(day, isToday);

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => onDayTapped(isSelected ? null : i),
          child: Semantics(
            label: '${_dayLabels[i]}, ${day.streetCount} rues',
            button: true,
            selected: isSelected,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: UrbinkSpacing.xs),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 28,
                    height: barHeight,
                    decoration: BoxDecoration(
                      color: barColor,
                      borderRadius: BorderRadius.circular(4),
                      border: isSelected
                          ? Border.all(
                              color: UrbinkColors.histogramOcre, width: 2)
                          : null,
                    ),
                  ),
                  const SizedBox(height: UrbinkSpacing.xs),
                  Text(
                    _dayLabels[i],
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight:
                          isToday ? FontWeight.w700 : FontWeight.w400,
                      color: isToday
                          ? UrbinkColors.histogramOcre
                          : UrbinkColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  double _computeBarHeight(DayStats day, int maxStreets) {
    if (day.isEmpty || maxStreets == 0) return _ghostHeight;
    final ratio = day.streetCount / maxStreets;
    return max(_minActiveHeight, ratio * _maxBarHeight);
  }

  Color _barColor(DayStats day, bool isToday) {
    if (day.isEmpty) return UrbinkColors.histogramGhost;
    return isToday ? UrbinkColors.histogramOcre : UrbinkColors.primary;
  }
}
