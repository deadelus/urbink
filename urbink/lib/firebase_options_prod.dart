// Fichier généré par FlutterFire CLI pour l'environnement production.
// À générer avec :
//   flutterfire configure --project=urbink-prod --out=lib/firebase_options_prod.dart
// Ce fichier est généré en CI uniquement.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;

class ProdFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'ProdFirebaseOptions non configuré — '
          'relancer : flutterfire configure --project=urbink-prod',
        );
      default:
        throw UnsupportedError(
          'Urbink cible iOS et Android uniquement.',
        );
    }
  }
}
