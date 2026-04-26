import 'package:flutter_test/flutter_test.dart';
import 'package:urbink/features/gamification/models/quartier_progression.dart';

void main() {
  group('QuartierProgression', () {
    test('completionPercent — calcul standard', () {
      const q = QuartierProgression(
        id: 'arrond_1',
        name: '1er',
        totalStreets: 100,
        exploredStreets: 25,
      );
      expect(q.completionPercent, 25.0);
    });

    test('completionPercent — 0 exploré', () {
      const q = QuartierProgression(
        id: 'arrond_1',
        name: '1er',
        totalStreets: 500,
        exploredStreets: 0,
      );
      expect(q.completionPercent, 0.0);
    });

    test('completionPercent — 100% complété', () {
      const q = QuartierProgression(
        id: 'arrond_1',
        name: '1er',
        totalStreets: 623,
        exploredStreets: 623,
      );
      expect(q.completionPercent, 100.0);
    });

    test('completionPercent — totalStreets = 0 retourne 0 (pas de division par zéro)', () {
      const q = QuartierProgression(
        id: 'arrond_x',
        name: 'Inconnu',
        totalStreets: 0,
        exploredStreets: 0,
      );
      expect(q.completionPercent, 0.0);
    });

    test('completionPercent — valeur intermédiaire précise', () {
      const q = QuartierProgression(
        id: 'arrond_2',
        name: '2e',
        totalStreets: 392,
        exploredStreets: 196,
      );
      expect(q.completionPercent, closeTo(50.0, 0.001));
    });
  });
}
