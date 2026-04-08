import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:urbink/shared/constants/colors.dart';
import 'package:urbink/shared/constants/spacing.dart';
import 'package:urbink/shared/constants/typography.dart';
import 'package:urbink/shared/theme/app_theme.dart';

void main() {
  late ThemeData theme;

  setUpAll(() {
    theme = AppTheme.light();
  });

  group('AppTheme.light() — Material 3', () {
    test('useMaterial3 est actif', () {
      expect(theme.useMaterial3, isTrue);
    });

    test('brightness = light', () {
      expect(theme.brightness, Brightness.light);
    });
  });

  group('AppTheme.light() — ColorScheme (AC-1)', () {
    test('primary = Ocre #B8832E', () {
      expect(theme.colorScheme.primary, UrbinkColors.primary);
    });

    test('secondary = Vert Sauge #5A7A5A', () {
      expect(theme.colorScheme.secondary, UrbinkColors.secondary);
    });

    test('surface = Fond chaud #FAFAF7', () {
      expect(theme.colorScheme.surface, UrbinkColors.surface);
    });

    test('onSurface = Brun Profond #1E1610', () {
      expect(theme.colorScheme.onSurface, UrbinkColors.onSurface);
    });
  });

  group('AppTheme.light() — TextTheme (AC-2)', () {
    test('displayLarge utilise CrimsonPro', () {
      expect(
        theme.textTheme.displayLarge!.fontFamily,
        UrbinkTypography.displayFamily,
      );
    });

    test('bodyLarge utilise Inter', () {
      expect(
        theme.textTheme.bodyLarge!.fontFamily,
        UrbinkTypography.bodyFamily,
      );
    });
  });

  group('AppTheme.light() — Border radius (AC-4)', () {
    test('FilledButton — radius 12px', () {
      final shape = theme.filledButtonTheme.style!.shape!
          .resolve({}) as RoundedRectangleBorder;
      final radius = (shape.borderRadius as BorderRadius).topLeft.x;
      expect(radius, UrbinkSpacing.radiusButton);
    });

    test('Card — radius 16px', () {
      final shape = theme.cardTheme.shape as RoundedRectangleBorder;
      final radius = (shape.borderRadius as BorderRadius).topLeft.x;
      expect(radius, UrbinkSpacing.radiusCard);
    });

    test('Chip — radius 8px', () {
      final shape = theme.chipTheme.shape as RoundedRectangleBorder;
      final radius = (shape.borderRadius as BorderRadius).topLeft.x;
      expect(radius, UrbinkSpacing.radiusChip);
    });
  });

  group('AppTheme.light() — FilledButton (AC-4)', () {
    test('backgroundColor = Ocre', () {
      final bg = theme.filledButtonTheme.style!.backgroundColor!
          .resolve({}) as Color;
      expect(bg, UrbinkColors.primary);
    });

    test('foregroundColor = blanc', () {
      final fg = theme.filledButtonTheme.style!.foregroundColor!
          .resolve({}) as Color;
      expect(fg, Colors.white);
    });

    test('minimumSize height >= 52 (44 + 8)', () {
      final size = theme.filledButtonTheme.style!.minimumSize!.resolve({})!;
      expect(size.height, greaterThanOrEqualTo(52.0));
    });
  });

  group('AppTheme.light() — NavigationBar', () {
    test('icône sélectionnée = Ocre', () {
      final selected = theme.navigationBarTheme.iconTheme!
          .resolve({WidgetState.selected})!;
      expect(selected.color, UrbinkColors.primary);
    });

    test('icône inactive = navInactive', () {
      final inactive =
          theme.navigationBarTheme.iconTheme!.resolve({})!;
      expect(inactive.color, UrbinkColors.navInactive);
    });
  });

  group('AppTheme.light() — rendu widget (golden properties)', () {
    testWidgets('theme injecté dans le widget tree', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: Builder(
            builder: (context) {
              final cs = Theme.of(context).colorScheme;
              // Vérification en contexte widget (AC-1 end-to-end)
              expect(cs.primary, UrbinkColors.primary);
              expect(cs.secondary, UrbinkColors.secondary);
              expect(cs.surface, UrbinkColors.surface);
              expect(cs.onSurface, UrbinkColors.onSurface);

              final tt = Theme.of(context).textTheme;
              // Vérification typography en contexte widget (AC-2 end-to-end)
              expect(tt.displayLarge!.fontFamily,
                  UrbinkTypography.displayFamily);
              expect(tt.bodyLarge!.fontFamily, UrbinkTypography.bodyFamily);

              return const SizedBox.shrink();
            },
          ),
        ),
      );
    });
  });
}
