import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:urbink/features/profile/models/day_stats.dart';
import 'package:urbink/features/profile/widgets/week_histogram.dart';
import 'package:urbink/features/sessions/models/session.dart';
import 'package:urbink/features/sessions/models/transport_mode.dart';
import 'package:urbink/shared/constants/colors.dart';

void main() {
  final monday = DateTime(2026, 4, 20);

  List<DayStats> emptyWeek() => List.generate(
        7,
        (i) => DayStats.empty(monday.add(Duration(days: i))),
      );

  Session makeSession(DateTime date) => Session(
        sessionId: 'id_$date',
        userId: 'uid',
        sessionStart: date,
        sessionEnd: date.add(const Duration(minutes: 20)),
        mode: TransportMode.walking,
        streetIds: const ['s1', 's2', 's3'],
        distanceMeters: 500,
      );

  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  group('WeekHistogram', () {
    testWidgets('affiche 7 labels L M M J V S D', (tester) async {
      await tester.pumpWidget(wrap(
        WeekHistogram(
          days: emptyWeek(),
          selectedDayIndex: null,
          onDayTapped: (_) {},
        ),
      ));
      // Trois 'M' dans la semaine (lundi, mardi, mercredi → L M M)
      expect(find.text('L'), findsOneWidget);
      expect(find.text('M'), findsNWidgets(2));
      expect(find.text('J'), findsOneWidget);
      expect(find.text('V'), findsOneWidget);
      expect(find.text('S'), findsOneWidget);
      expect(find.text('D'), findsOneWidget);
    });

    testWidgets('appelle onDayTapped avec l\'index du jour tapé',
        (tester) async {
      int? tappedIndex;
      await tester.pumpWidget(wrap(
        WeekHistogram(
          days: emptyWeek(),
          selectedDayIndex: null,
          onDayTapped: (i) => tappedIndex = i,
        ),
      ));
      // Tap le premier GestureDetector (lundi)
      await tester.tap(find.byType(GestureDetector).first);
      expect(tappedIndex, 0);
    });

    testWidgets('déselectionne si on re-tape le jour déjà sélectionné',
        (tester) async {
      int? tappedIndex = 0;
      await tester.pumpWidget(wrap(
        WeekHistogram(
          days: emptyWeek(),
          selectedDayIndex: 0,
          onDayTapped: (i) => tappedIndex = i,
        ),
      ));
      await tester.tap(find.byType(GestureDetector).first);
      expect(tappedIndex, isNull);
    });

    testWidgets('barre aujourd\'hui affiche la couleur histogramOcre',
        (tester) async {
      final today = DateTime.now();
      final todayMidnight =
          DateTime(today.year, today.month, today.day);
      final monday = todayMidnight
          .subtract(Duration(days: todayMidnight.weekday - 1));

      final session = makeSession(todayMidnight);
      final days = List.generate(7, (i) {
        final day = monday.add(Duration(days: i));
        final isToday = day.year == today.year &&
            day.month == today.month &&
            day.day == today.day;
        if (isToday) {
          return DayStats(
            date: day,
            streetCount: 3,
            distanceKm: 0.5,
            totalDuration: const Duration(minutes: 20),
            sessions: [session],
          );
        }
        return DayStats.empty(day);
      });

      await tester.pumpWidget(wrap(
        WeekHistogram(
          days: days,
          selectedDayIndex: null,
          onDayTapped: (_) {},
        ),
      ));

      final containers = tester.widgetList<AnimatedContainer>(
        find.byType(AnimatedContainer),
      );
      final ocreBars = containers.where((c) {
        final decoration = c.decoration as BoxDecoration?;
        return decoration?.color == UrbinkColors.histogramOcre;
      });
      expect(ocreBars.length, greaterThanOrEqualTo(1));
    });

    testWidgets('état empty — toutes les barres sont fantômes', (tester) async {
      await tester.pumpWidget(wrap(
        WeekHistogram(
          days: emptyWeek(),
          selectedDayIndex: null,
          onDayTapped: (_) {},
        ),
      ));
      final containers = tester.widgetList<AnimatedContainer>(
        find.byType(AnimatedContainer),
      );
      final ghostBars = containers.where((c) {
        final d = c.decoration as BoxDecoration?;
        return d?.color == UrbinkColors.histogramGhost;
      });
      // 7 barres au total — 6 fantômes (today peut être ocre si la semaine
      // en cours, mais si les données sont toutes vides, toutes sont ghost)
      expect(ghostBars.length, 7);
    });
  });
}
