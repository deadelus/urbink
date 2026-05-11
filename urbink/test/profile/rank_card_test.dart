import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:urbink/features/profile/data/explorer_rank.dart';
import 'package:urbink/features/profile/widgets/rank_card.dart';
import 'package:urbink/features/profile/widgets/rank_preview_strip.dart';
import 'package:urbink/l10n/app_localizations.dart';

Widget _wrap(Widget child) => ProviderScope(
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: SingleChildScrollView(child: child)),
      ),
    );

void main() {
  group('RankCard', () {
    testWidgets('affiche le nom du rang', (tester) async {
      final rank = kExplorerRanks[2]; // Turquoise
      await tester.pumpWidget(_wrap(RankCard(rank: rank, currentXp: 20)));
      await tester.pump();
      expect(find.text('Turquoise'), findsOneWidget);
    });

    testWidgets('affiche "N monuments découverts"', (tester) async {
      final rank = kExplorerRanks[0]; // Cristal
      await tester.pumpWidget(_wrap(RankCard(rank: rank, currentXp: 3)));
      await tester.pump();
      expect(find.textContaining('3'), findsWidgets);
    });

    testWidgets('affiche "Vers {next}" quand pas au rang max', (tester) async {
      final rank = kExplorerRanks[1]; // Opale → next = Turquoise
      await tester.pumpWidget(_wrap(RankCard(rank: rank, currentXp: 10)));
      await tester.pump();
      expect(find.textContaining('Turquoise'), findsWidgets);
    });

    testWidgets('affiche "Rang maximum atteint" pour Légendaire', (tester) async {
      final rank = kExplorerRanks[10]; // Légendaire
      await tester.pumpWidget(_wrap(RankCard(rank: rank, currentXp: 1200)));
      await tester.pump();
      expect(find.textContaining('maximum'), findsOneWidget);
    });

    testWidgets('affiche une LinearProgressIndicator', (tester) async {
      final rank = kExplorerRanks[3]; // Ambre
      await tester.pumpWidget(_wrap(RankCard(rank: rank, currentXp: 50)));
      await tester.pump();
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('pas de LinearProgressIndicator pour Légendaire', (tester) async {
      final rank = kExplorerRanks[10];
      await tester.pumpWidget(_wrap(RankCard(rank: rank, currentXp: 1200)));
      await tester.pump();
      expect(find.byType(LinearProgressIndicator), findsNothing);
    });
  });

  group('RankPreviewStrip', () {
    testWidgets('affiche 11 noms de rangs', (tester) async {
      final rank = kExplorerRanks[0];
      await tester.pumpWidget(_wrap(RankPreviewStrip(currentRank: rank)));
      await tester.pump();
      for (final r in kExplorerRanks) {
        expect(find.text(r.name), findsOneWidget);
      }
    });

    testWidgets('affiche le label "Les 11 rangs"', (tester) async {
      final rank = kExplorerRanks[4]; // Topaze
      await tester.pumpWidget(_wrap(RankPreviewStrip(currentRank: rank)));
      await tester.pump();
      expect(find.textContaining('11'), findsWidgets);
    });

    testWidgets('affiche la position du rang actuel', (tester) async {
      final rank = kExplorerRanks[4]; // Topaze = rang 5
      await tester.pumpWidget(_wrap(RankPreviewStrip(currentRank: rank)));
      await tester.pump();
      // "5 sur 11"
      expect(find.textContaining('5'), findsWidgets);
    });
  });
}
