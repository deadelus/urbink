import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:urbink/core/router/app_router.dart';
import 'package:urbink/features/profile/providers/week_sessions_provider.dart';
import 'package:urbink/shared/constants/colors.dart';
import 'package:urbink/shared/constants/spacing.dart';

// Ocre chaud — jour actuel selon UX-DR6
const _ocre = Color(0xFFB8832E);
// Barre fantôme — jours sans activité
const _ghost = Color(0xFFF0EDE8);
// Hauteur maximale d'une barre (dp)
const _barMaxHeight = 72.0;
// Hauteur minimale d'une barre active (dp)
const _barMinHeight = 6.0;
// Hauteur de la barre fantôme (dp)
const _ghostHeight = 28.0;

/// Histogramme 7 barres L→D représentant l'activité hebdomadaire.
///
/// - Barre du jour courant : Ocre #B8832E
/// - Barre avec activité (pas aujourd'hui) : Vert Sauge primaire
/// - Barre vide : fantôme #F0EDE8
/// - Empty state (aucune session cette semaine) : barres fantômes + message + CTA
/// - Tap barre → filtre la liste via [selectedHistogramDayProvider] (toggle)
class WeekHistogram extends ConsumerWidget {
  const WeekHistogram({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weekAsync = ref.watch(weekSessionsProvider);
    final selectedDay = ref.watch(selectedHistogramDayProvider);

    return weekAsync.when(
      loading: () => _HistogramSkeleton(),
      error: (_, _) => const SizedBox.shrink(),
      data: (dayStreets) {
        final now = DateTime.now();
        final start = weekStart(now);
        final days = List.generate(7, (i) => start.add(Duration(days: i)));
        final hasActivity = dayStreets.values.any((c) => c > 0);

        if (!hasActivity) {
          return _EmptyState(days: days, now: now);
        }

        final maxCount = dayStreets.values.fold(0, (a, b) => a > b ? a : b);

        return _HistogramBars(
          days: days,
          now: now,
          dayStreets: dayStreets,
          maxCount: maxCount,
          selectedDay: selectedDay,
          onDayTap: (day) {
            final current = ref.read(selectedHistogramDayProvider);
            ref.read(selectedHistogramDayProvider.notifier).state =
                (current == day) ? null : day;
          },
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Barres
// ---------------------------------------------------------------------------

class _HistogramBars extends StatelessWidget {
  const _HistogramBars({
    required this.days,
    required this.now,
    required this.dayStreets,
    required this.maxCount,
    required this.selectedDay,
    required this.onDayTap,
  });

  final List<DateTime> days;
  final DateTime now;
  final Map<DateTime, int> dayStreets;
  final int maxCount;
  final DateTime? selectedDay;
  final ValueChanged<DateTime> onDayTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: days.map((day) {
        final count = dayStreets[day] ?? 0;
        final isToday = _isSameDay(day, now);
        final isSelected = selectedDay != null && _isSameDay(day, selectedDay!);
        return _DayBar(
          day: day,
          count: count,
          maxCount: maxCount,
          isToday: isToday,
          isSelected: isSelected,
          onTap: () => onDayTap(day),
        );
      }).toList(),
    );
  }
}

class _DayBar extends StatelessWidget {
  const _DayBar({
    required this.day,
    required this.count,
    required this.maxCount,
    required this.isToday,
    required this.isSelected,
    required this.onTap,
  });

  final DateTime day;
  final int count;
  final int maxCount;
  final bool isToday;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isEmpty = count == 0;
    final barHeight = isEmpty
        ? _ghostHeight
        : _barMinHeight + (_barMaxHeight - _barMinHeight) * (count / maxCount);

    final Color barColor;
    if (isEmpty) {
      barColor = _ghost;
    } else if (isToday) {
      barColor = _ocre;
    } else {
      barColor = UrbinkColors.primary;
    }

    return GestureDetector(
      onTap: isEmpty ? null : onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: UrbinkSpacing.minTapTarget,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              width: 20,
              height: barHeight,
              decoration: BoxDecoration(
                color: barColor,
                borderRadius: BorderRadius.circular(4),
                border: isSelected
                    ? Border.all(
                        color: UrbinkColors.onSurface.withValues(alpha: 0.6),
                        width: 2,
                      )
                    : null,
              ),
            ),
            const SizedBox(height: UrbinkSpacing.xs),
            Text(
              _dayLabel(day),
              style: TextStyle(
                fontSize: 10,
                fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
                color: isToday
                    ? _ocre
                    : UrbinkColors.navInactive,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Empty state
// ---------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.days, required this.now});

  final List<DateTime> days;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: days.map((day) {
            final isToday = _isSameDay(day, now);
            return SizedBox(
              width: UrbinkSpacing.minTapTarget,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 20,
                    height: _ghostHeight,
                    decoration: BoxDecoration(
                      color: _ghost,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: UrbinkSpacing.xs),
                  Text(
                    _dayLabel(day),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
                      color: UrbinkColors.navInactive,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: UrbinkSpacing.md),
        Text(
          "Ta première sortie cette semaine n'attend que toi",
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: UrbinkColors.navInactive,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: UrbinkSpacing.sm),
        TextButton(
          onPressed: () => context.go(AppRoutes.map),
          child: const Text('Démarrer'),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Squelette chargement
// ---------------------------------------------------------------------------

class _HistogramSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(7, (i) {
        return SizedBox(
          width: UrbinkSpacing.minTapTarget,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 20,
                height: _ghostHeight,
                decoration: BoxDecoration(
                  color: _ghost,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: UrbinkSpacing.xs),
              Container(
                width: 12,
                height: 10,
                decoration: BoxDecoration(
                  color: _ghost,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

bool _isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

const _dayLabels = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];

String _dayLabel(DateTime day) => _dayLabels[day.weekday - 1];
