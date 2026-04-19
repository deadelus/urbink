import 'package:flutter_test/flutter_test.dart';
import 'package:urbink/shared/constants/spacing.dart';

void main() {
  group('UrbinkSpacing — grille 8px', () {
    test('xs = 4', () => expect(UrbinkSpacing.xs, 4.0));
    test('sm = 8', () => expect(UrbinkSpacing.sm, 8.0));
    test('md = 16', () => expect(UrbinkSpacing.md, 16.0));
    test('lg = 24', () => expect(UrbinkSpacing.lg, 24.0));
    test('xl = 32', () => expect(UrbinkSpacing.xl, 32.0));
    test('xxl = 48', () => expect(UrbinkSpacing.xxl, 48.0));

    test('chaque valeur est un multiple de 4', () {
      for (final v in [
        UrbinkSpacing.xs,
        UrbinkSpacing.sm,
        UrbinkSpacing.md,
        UrbinkSpacing.lg,
        UrbinkSpacing.xl,
        UrbinkSpacing.xxl,
      ]) {
        expect(v % 4, 0.0, reason: '$v n\'est pas un multiple de 4');
      }
    });
  });

  group('UrbinkSpacing — border radius', () {
    test('radiusButton = 16', () => expect(UrbinkSpacing.radiusButton, 16.0));
    test('radiusCard = 20', () => expect(UrbinkSpacing.radiusCard, 20.0));
    test('radiusChip = 10', () => expect(UrbinkSpacing.radiusChip, 10.0));
    test('radiusSheet = 24', () => expect(UrbinkSpacing.radiusSheet, 24.0));
  });

  group('UrbinkSpacing — zones tactiles', () {
    test('minTapTarget >= 44 (HIG iOS)', () {
      expect(UrbinkSpacing.minTapTarget, greaterThanOrEqualTo(44.0));
    });

    test('bottomNavHeight = 74', () {
      expect(UrbinkSpacing.bottomNavHeight, 74.0);
    });

    test('thumbZone = 120', () {
      expect(UrbinkSpacing.thumbZone, 120.0);
    });
  });
}
