import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:urbink/firebase_options.dart';

// Environnement injecté via --dart-define=FLUTTER_ENV=<env>
// Valeurs possibles : dev (défaut) | staging | prod
// En CI, firebase_options.dart est écrit depuis le secret GitHub de l'environment correspondant.
const String _env = String.fromEnvironment('FLUTTER_ENV', defaultValue: 'dev');

abstract final class FirebaseService {
  static Future<void> initialize() async {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    await _setupCrashlytics();
    await _setupAnalytics();
  }

  /// Crashlytics — capture les exceptions Flutter non gérées et les erreurs natives.
  /// Désactivé en debug pour ne pas polluer le tableau de bord prod.
  static Future<void> _setupCrashlytics() async {
    final crashlytics = FirebaseCrashlytics.instance;

    // En debug : désactiver la collection pour éviter le bruit dans le dashboard
    await crashlytics.setCrashlyticsCollectionEnabled(!kDebugMode);

    // Redirige toutes les exceptions Flutter non gérées vers Crashlytics
    FlutterError.onError = crashlytics.recordFlutterFatalError;

    // Capture les erreurs async hors zone Flutter (ex: erreurs Isolate)
    PlatformDispatcher.instance.onError = (error, stack) {
      crashlytics.recordError(error, stack, fatal: true);
      return true;
    };
  }

  /// Analytics — log app_open au démarrage.
  /// Firebase Analytics loggue automatiquement app_open, on s'assure juste
  /// que la collection est activée.
  static Future<void> _setupAnalytics() async {
    final analytics = FirebaseAnalytics.instance;
    // En debug : désactiver la collection pour ne pas biaiser les métriques prod
    await analytics.setAnalyticsCollectionEnabled(!kDebugMode);
    // app_open est loggué automatiquement par le SDK Firebase Analytics
    // Visible dans Firebase Console > Analytics > Events dans les 24h (délai standard)
  }

  static FirebaseAuth get auth => FirebaseAuth.instance;

  static FirebaseAnalytics get analytics => FirebaseAnalytics.instance;

  static String get currentEnv => _env;
}
