import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:urbink/firebase_options_dev.dart';

// Environnement injecté via --dart-define=FLUTTER_ENV=<env>
// Valeurs possibles : dev (défaut) | staging | prod
const String _env = String.fromEnvironment('FLUTTER_ENV', defaultValue: 'dev');

abstract final class FirebaseService {
  static Future<void> initialize() async {
    await Firebase.initializeApp(options: _firebaseOptions());
  }

  static FirebaseOptions _firebaseOptions() {
    switch (_env) {
      case 'prod':
        // ignore: only_throw_errors
        throw StateError(
          'firebase_options_prod.dart non configuré. '
          'Exécuter : flutterfire configure --project=urbink-prod',
        );
      case 'staging':
        // ignore: only_throw_errors
        throw StateError(
          'firebase_options_staging.dart non configuré. '
          'Exécuter : flutterfire configure --project=urbink-staging',
        );
      default:
        return DefaultFirebaseOptions.currentPlatform;
    }
  }

  static FirebaseAuth get auth => FirebaseAuth.instance;

  static String get currentEnv => _env;
}
