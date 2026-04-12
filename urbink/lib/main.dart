import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urbink/core/firebase/firebase_service.dart';
import 'package:urbink/core/router/app_router.dart';
import 'package:urbink/shared/theme/app_theme.dart';

// CancelledException is thrown by vector_map_tiles (via the executor package)
// when a tile-loading operation is cancelled. We check both the runtimeType
// (stable class name) and the stack trace origin (vector_map_tiles / executor)
// to avoid silencing unrelated CancelledExceptions from other libraries.
bool _isCancelled(Object error, StackTrace stack) {
  if (error.runtimeType.toString() != 'CancelledException') return false;
  final frames = stack.toString();
  return frames.contains('vector_map_tiles') || frames.contains('/executor/');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await FirebaseService.initialize();

  // Filtre posé APRÈS Firebase pour wrapper le handler Crashlytics.
  // Crashlytics appelle FlutterError.presentError avant de chaîner,
  // donc notre filtre doit être le dernier maillon de la chaîne.
  final previousFlutterHandler = FlutterError.onError;
  FlutterError.onError = (details) {
    if (_isCancelled(details.exception, details.stack ?? StackTrace.empty)) return;
    previousFlutterHandler?.call(details);
  };

  final previousPlatformHandler = PlatformDispatcher.instance.onError;
  PlatformDispatcher.instance.onError = (error, stack) {
    if (_isCancelled(error, stack)) return true;
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
