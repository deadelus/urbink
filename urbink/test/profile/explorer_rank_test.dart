import 'package:flutter_test/flutter_test.dart';
import 'package:urbink/features/profile/data/explorer_rank.dart';

void main() {
  group('kExplorerRanks', () {
    test('contient exactement 11 rangs', () {
      expect(kExplorerRanks.length, 11);
    });

    test('les index sont consécutifs 0→10', () {
      for (int i = 0; i < kExplorerRanks.length; i++) {
        expect(kExplorerRanks[i].index, i);
      }
    });

    test('les seuils xpMin sont strictement croissants', () {
      for (int i = 1; i < kExplorerRanks.length; i++) {
        expect(kExplorerRanks[i].xpMin, greaterThan(kExplorerRanks[i - 1].xpMin));
      }
    });

    test('xpNext de chaque rang = xpMin du rang suivant', () {
      for (int i = 0; i < kExplorerRanks.length - 1; i++) {
        expect(kExplorerRanks[i].xpNext, kExplorerRanks[i + 1].xpMin);
      }
    });

    test('Légendaire (index 10) a xpNext == null', () {
      expect(kExplorerRanks[10].xpNext, isNull);
    });

    test('Cristal (index 0) a xpMin == 0', () {
      expect(kExplorerRanks[0].xpMin, 0);
    });
  });

  group('rankForXp', () {
    test('xp=0 → Cristal', () {
      expect(rankForXp(0).id, 'cristal');
    });

    test('xp=4 → Cristal (sous le seuil Opale)', () {
      expect(rankForXp(4).id, 'cristal');
    });

    test('xp=5 → Opale (seuil exact)', () {
      expect(rankForXp(5).id, 'opale');
    });

    test('xp=14 → Opale', () {
      expect(rankForXp(14).id, 'opale');
    });

    test('xp=15 → Turquoise', () {
      expect(rankForXp(15).id, 'turquoise');
    });

    test('xp=35 → Ambre', () {
      expect(rankForXp(35).id, 'ambre');
    });

    test('xp=75 → Topaze', () {
      expect(rankForXp(75).id, 'topaze');
    });

    test('xp=140 → Jade', () {
      expect(rankForXp(140).id, 'jade');
    });

    test('xp=240 → Saphir', () {
      expect(rankForXp(240).id, 'saphir');
    });

    test('xp=380 → Rubis', () {
      expect(rankForXp(380).id, 'rubis');
    });

    test('xp=560 → Émeraude', () {
      expect(rankForXp(560).id, 'emeraude');
    });

    test('xp=800 → Diamant', () {
      expect(rankForXp(800).id, 'diamant');
    });

    test('xp=1100 → Légendaire', () {
      expect(rankForXp(1100).id, 'legendaire');
    });

    test('xp très élevé → Légendaire', () {
      expect(rankForXp(9999).id, 'legendaire');
    });
  });

  group('ExplorerRank.progressTo', () {
    test('Cristal à xp=0 → 0.0', () {
      final rank = rankForXp(0);
      expect(rank.progressTo(0), 0.0);
    });

    test('Opale à xp=10 sur 5→15 → 0.5', () {
      final rank = rankForXp(10); // Opale
      expect(rank.progressTo(10), 0.5);
    });

    test('Légendaire → toujours 1.0', () {
      final rank = rankForXp(1100);
      expect(rank.progressTo(1100), 1.0);
      expect(rank.progressTo(9999), 1.0);
    });

    test('progressTo ne dépasse pas 1.0', () {
      final rank = rankForXp(5); // Opale xpMin=5 xpNext=15
      expect(rank.progressTo(100), 1.0);
    });
  });

  group('ExplorerRank.xpInRank', () {
    test('Cristal xp=3 → 3 XP dans le rang', () {
      final rank = rankForXp(3);
      expect(rank.xpInRank(3), 3);
    });

    test('Opale xp=12 → 7 XP dans le rang (12-5)', () {
      final rank = rankForXp(12);
      expect(rank.xpInRank(12), 7);
    });
  });

  group('ExplorerRank equality', () {
    test('deux rangs avec le même index sont égaux', () {
      expect(kExplorerRanks[0], kExplorerRanks[0]);
    });

    test('deux rangs différents ne sont pas égaux', () {
      expect(kExplorerRanks[0] == kExplorerRanks[1], isFalse);
    });
  });
}
