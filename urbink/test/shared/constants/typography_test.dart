import 'package:flutter_test/flutter_test.dart';
import 'package:urbink/shared/constants/typography.dart';

void main() {
  group('UrbinkTypography — family names', () {
    test('displayFamily = "CrimsonPro"', () {
      expect(UrbinkTypography.displayFamily, 'CrimsonPro');
    });

    test('bodyFamily = "Inter"', () {
      expect(UrbinkTypography.bodyFamily, 'Inter');
    });
  });

  group('UrbinkTypography — display / heading (CrimsonPro)', () {
    final theme = UrbinkTypography.textTheme;

    test('displayLarge — CrimsonPro, 57px', () {
      expect(theme.displayLarge!.fontFamily, 'CrimsonPro');
      expect(theme.displayLarge!.fontSize, 57.0);
    });

    test('displayMedium — CrimsonPro, 45px', () {
      expect(theme.displayMedium!.fontFamily, 'CrimsonPro');
      expect(theme.displayMedium!.fontSize, 45.0);
    });

    test('displaySmall — CrimsonPro, 36px', () {
      expect(theme.displaySmall!.fontFamily, 'CrimsonPro');
      expect(theme.displaySmall!.fontSize, 36.0);
    });

    test('headlineLarge — CrimsonPro, 32px, w600', () {
      expect(theme.headlineLarge!.fontFamily, 'CrimsonPro');
      expect(theme.headlineLarge!.fontSize, 32.0);
    });

    test('headlineMedium — CrimsonPro, 28px', () {
      expect(theme.headlineMedium!.fontFamily, 'CrimsonPro');
      expect(theme.headlineMedium!.fontSize, 28.0);
    });

    test('headlineSmall — CrimsonPro, 24px', () {
      expect(theme.headlineSmall!.fontFamily, 'CrimsonPro');
      expect(theme.headlineSmall!.fontSize, 24.0);
    });
  });

  group('UrbinkTypography — body (Inter)', () {
    final theme = UrbinkTypography.textTheme;

    test('bodyLarge — Inter, 16px', () {
      expect(theme.bodyLarge!.fontFamily, 'Inter');
      expect(theme.bodyLarge!.fontSize, 16.0);
    });

    test('bodyMedium — Inter, 14px', () {
      expect(theme.bodyMedium!.fontFamily, 'Inter');
      expect(theme.bodyMedium!.fontSize, 14.0);
    });

    test('bodySmall — Inter, 12px', () {
      expect(theme.bodySmall!.fontFamily, 'Inter');
      expect(theme.bodySmall!.fontSize, 12.0);
    });

    test('labelLarge — Inter, 14px, w600', () {
      expect(theme.labelLarge!.fontFamily, 'Inter');
      expect(theme.labelLarge!.fontSize, 14.0);
    });

    test('labelMedium — Inter, 12px', () {
      expect(theme.labelMedium!.fontFamily, 'Inter');
      expect(theme.labelMedium!.fontSize, 12.0);
    });

    test('labelSmall — Inter, 11px', () {
      expect(theme.labelSmall!.fontFamily, 'Inter');
      expect(theme.labelSmall!.fontSize, 11.0);
    });
  });
}
