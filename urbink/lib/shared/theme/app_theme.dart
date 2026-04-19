import 'package:flutter/material.dart';
import 'package:urbink/shared/constants/colors.dart';
import 'package:urbink/shared/constants/spacing.dart';
import 'package:urbink/shared/constants/typography.dart';

/// Thème Material 3 Urbink — direction UI iOS-inspired (deep green + amber).
abstract final class AppTheme {
  static ThemeData light() => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: UrbinkColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: UrbinkColors.primary,
          brightness: Brightness.light,
        ).copyWith(
          primary: UrbinkColors.primary,
          secondary: UrbinkColors.accent,
          surface: UrbinkColors.surface,
          onSurface: UrbinkColors.onSurface,
          surfaceContainerHighest: UrbinkColors.surfaceVariant,
        ),
        textTheme: UrbinkTypography.textTheme,
        // Cards blanches avec ombre légère
        cardTheme: const CardThemeData(
          color: UrbinkColors.surface,
          elevation: 0,
          shadowColor: Color(0x14000000),
        ),
        // Boutons ronds avec ombre douce
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: UrbinkColors.primary,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(
              UrbinkSpacing.minTapTarget + 8,
            ),
            elevation: 2,
            shadowColor: UrbinkColors.primary.withValues(alpha: 0.35),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(UrbinkSpacing.radiusButton),
            ),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: UrbinkColors.primary,
            foregroundColor: Colors.white,
            elevation: 2,
            shadowColor: UrbinkColors.primary.withValues(alpha: 0.30),
            minimumSize: const Size.fromHeight(
              UrbinkSpacing.minTapTarget + 8,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(UrbinkSpacing.radiusButton),
            ),
          ),
        ),
        chipTheme: const ChipThemeData(
          backgroundColor: UrbinkColors.surfaceVariant,
          side: BorderSide.none,
          labelStyle: TextStyle(
            fontFamily: UrbinkTypography.bodyFamily,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: UrbinkColors.surface,
          contentPadding: EdgeInsets.symmetric(
            horizontal: UrbinkSpacing.md,
            vertical: UrbinkSpacing.sm + 2,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(UrbinkSpacing.radiusButton)),
            borderSide: BorderSide(color: UrbinkColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(UrbinkSpacing.radiusButton)),
            borderSide: BorderSide(color: UrbinkColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(UrbinkSpacing.radiusButton)),
            borderSide: BorderSide(color: UrbinkColors.primary, width: 1.5),
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: UrbinkColors.surface,
          indicatorColor: UrbinkColors.primary.withValues(alpha: 0.10),
          iconTheme: WidgetStateProperty.resolveWith(
            (states) => IconThemeData(
              color: states.contains(WidgetState.selected)
                  ? UrbinkColors.primary
                  : UrbinkColors.navInactive,
              size: 22,
            ),
          ),
          labelTextStyle: WidgetStateProperty.resolveWith(
            (states) => TextStyle(
              fontFamily: UrbinkTypography.bodyFamily,
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: states.contains(WidgetState.selected)
                  ? UrbinkColors.primary
                  : UrbinkColors.navInactive,
            ),
          ),
        ),
        dividerColor: UrbinkColors.border,
        dividerTheme: const DividerThemeData(
          color: UrbinkColors.border,
          thickness: 1,
          space: 1,
        ),
      );
}
