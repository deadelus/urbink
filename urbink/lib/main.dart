import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urbink/core/firebase/firebase_service.dart';
import 'package:urbink/core/router/app_router.dart';
import 'package:urbink/shared/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
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
        theme: AppTheme.light(),
      );
}
