import 'package:flutter/material.dart';
import 'package:urbink/shared/constants/colors.dart';
import 'package:urbink/shared/constants/spacing.dart';
import 'package:urbink/shared/constants/typography.dart';

/// Thème Material 3 Urbink.
///
/// Usage : `theme: AppTheme.light()` dans MaterialApp.
abstract final class AppTheme {
  static ThemeData light() => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: UrbinkColors.primary,
          brightness: Brightness.light,
        ).copyWith(
          primary: UrbinkColors.primary,
          secondary: UrbinkColors.secondary,
          surface: UrbinkColors.surface,
          onSurface: UrbinkColors.onSurface,
        ),
        textTheme: UrbinkTypography.textTheme,
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: UrbinkColors.primary,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(
              UrbinkSpacing.minTapTarget + 8,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(UrbinkSpacing.radiusButton),
            ),
          ),
        ),
        cardTheme: CardThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(UrbinkSpacing.radiusCard),
          ),
        ),
        chipTheme: ChipThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(UrbinkSpacing.radiusChip),
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          indicatorColor: UrbinkColors.primary.withValues(alpha: 0.15),
          iconTheme: WidgetStateProperty.resolveWith(
            (states) => IconThemeData(
              color: states.contains(WidgetState.selected)
                  ? UrbinkColors.primary
                  : UrbinkColors.navInactive,
            ),
          ),
          labelTextStyle: WidgetStateProperty.resolveWith(
            (states) => TextStyle(
              fontFamily: UrbinkTypography.bodyFamily,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: states.contains(WidgetState.selected)
                  ? UrbinkColors.primary
                  : UrbinkColors.navInactive,
            ),
          ),
        ),
      );
}
