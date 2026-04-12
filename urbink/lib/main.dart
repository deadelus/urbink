import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urbink/core/firebase/firebase_service.dart';
import 'package:urbink/core/router/app_router.dart';
import 'package:urbink/shared/theme/app_theme.dart';

bool _isCancelled(Object error) => error.toString() == 'Cancelled';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await FirebaseService.initialize();

  // Filtre posé APRÈS Firebase pour wrapper le handler Crashlytics.
  // Crashlytics appelle FlutterError.presentError avant de chaîner,
  // donc notre filtre doit être le dernier maillon de la chaîne.
  final previousFlutterHandler = FlutterError.onError;
  FlutterError.onError = (details) {
    if (_isCancelled(details.exception)) return;
    previousFlutterHandler?.call(details);
  };

  final previousPlatformHandler = PlatformDispatcher.instance.onError;
  PlatformDispatcher.instance.onError = (error, stack) {
    if (_isCancelled(error)) return true;
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
