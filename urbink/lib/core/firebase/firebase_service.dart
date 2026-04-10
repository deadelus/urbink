import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:urbink/firebase_options.dart';

// Environnement injecté via --dart-define=FLUTTER_ENV=<env>.
// Valeurs possibles : dev (défaut) | staging | prod.
// Cette valeur est exposée via `currentEnv`, mais ne sélectionne pas les
// options Firebase dans cette implémentation.
// L'environnement Firebase effectivement utilisé dépend du contenu de
// `firebase_options.dart` (injecté/généré pour l'environment GitHub visé),
// puis de `DefaultFirebaseOptions.currentPlatform`.
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

    // Chaîne avec le handler Flutter existant (affichage console/overlay en debug)
    // et n'envoie vers Crashlytics qu'en non-debug pour éviter le bruit.
    final previousFlutterOnError = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      previousFlutterOnError?.call(details);
      if (!kDebugMode) {
        crashlytics.recordFlutterFatalError(details);
      }
    };

    // Capture les erreurs async hors zone Flutter (ex: erreurs Isolate).
    // Chaîne avec un handler existant ; retourne false en debug pour ne pas
    // masquer les exceptions (comportement par défaut préservé).
    final previousPlatformOnError = PlatformDispatcher.instance.onError;
    PlatformDispatcher.instance.onError = (error, stack) {
      if (!kDebugMode) {
        crashlytics.recordError(error, stack, fatal: true);
      }
      if (previousPlatformOnError != null) {
        return previousPlatformOnError(error, stack);
      }
      return !kDebugMode;
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
