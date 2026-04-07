// Fichier généré par FlutterFire CLI pour l'environnement staging.
// À générer avec :
//   flutterfire configure --project=urbink-staging --out=lib/firebase_options_staging.dart
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;

class StagingFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'StagingFirebaseOptions non configuré — '
          'relancer : flutterfire configure --project=urbink-staging',
        );
      default:
        throw UnsupportedError(
          'Urbink cible iOS et Android uniquement.',
        );
    }
  }
}
