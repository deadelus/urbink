import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:urbink/core/firebase/firebase_service.dart';
import 'package:urbink/core/firebase/startup_auth.dart';
import 'package:urbink/core/router/app_router.dart';
import 'package:urbink/core/utils/tile_error_utils.dart';
import 'package:urbink/shared/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await FirebaseService.initialize();

  // Politique de confidentialité — vérification au démarrage (FR45)
  final prefs = await SharedPreferences.getInstance();
  final privacyAccepted = prefs.getBool(kPrivacyAcceptedKey) ?? false;

  // Auth anonyme si politique acceptée et pas encore connecté (FR32)
  if (privacyAccepted) {
    try {
      await ensureAnonymousAuth(
        isSignedIn: () => FirebaseAuth.instance.currentUser != null,
        signInAnonymously: FirebaseAuth.instance.signInAnonymously,
      );
    } catch (error, stackTrace) {
      debugPrint('Anonymous sign-in failed during app startup: $error\n$stackTrace');
    }
  }

  // Synchroniser le notifier GoRouter avec l'état persisté
  if (privacyAccepted) privacyNotifier.setAccepted();

  // Filtre posé APRÈS Firebase pour wrapper le handler Crashlytics.
  // Crashlytics appelle FlutterError.presentError avant de chaîner,
  // donc notre filtre doit être le dernier maillon de la chaîne.
  final previousFlutterHandler = FlutterError.onError;
  FlutterError.onError = (details) {
    if (isCancelledTileError(details.exception, details.stack ?? StackTrace.empty)) return;
    previousFlutterHandler?.call(details);
  };

  final previousPlatformHandler = PlatformDispatcher.instance.onError;
  PlatformDispatcher.instance.onError = (error, stack) {
    if (isCancelledTileError(error, stack)) return true;
    return previousPlatformHandler?.call(error, stack) ?? false;
  };

  runApp(const ProviderScope(child: UrbinkApp()));
}

class UrbinkApp extends StatelessWidget {
  const UrbinkApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp.router(
        title: 'Urbink',
        debugShowCheckedModeBanner: false,
        routerConfig: appRouter,
        theme: AppTheme.light(),
      );
}
