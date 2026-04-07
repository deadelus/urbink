import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urbink/core/firebase/firebase_service.dart';
import 'package:urbink/core/router/app_router.dart';
import 'package:urbink/shared/constants/colors.dart';
import 'package:urbink/shared/constants/spacing.dart';
import 'package:urbink/shared/constants/typography.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseService.initialize();
  runApp(const ProviderScope(child: UrbinkApp()));
}

class UrbinkApp extends StatelessWidget {
  const UrbinkApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp.router(
        title: 'Urbink',
        debugShowCheckedModeBanner: false,
        routerConfig: appRouter,
        theme: _buildTheme(),
      );

  ThemeData _buildTheme() => ThemeData(
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
            minimumSize: const Size.fromHeight(UrbinkSpacing.minTapTarget + 8),
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(UrbinkSpacing.radiusButton),
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
