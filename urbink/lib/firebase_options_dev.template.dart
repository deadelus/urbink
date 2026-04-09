// ignore_for_file: type=lint
//
// ─── SETUP DEV LOCAL ────────────────────────────────────────────────────────
//
// 1. Copier ce fichier :
//    cp lib/firebase_options_dev.template.dart lib/firebase_options_dev.dart
//
// 2. Remplacer les placeholders ci-dessous par les vraies valeurs du projet
//    Firebase "urbink-dev" (console.firebase.google.com → Paramètres du projet)
//
// 3. Ne jamais committer firebase_options_dev.dart (il est dans .gitignore)
//
// ────────────────────────────────────────────────────────────────────────────

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions: plateforme non supportée. '
          'Urbink cible iOS uniquement (MVP).',
        );
    }
  }

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'PLACEHOLDER_API_KEY',
    appId: 'PLACEHOLDER_APP_ID',
    messagingSenderId: 'PLACEHOLDER_SENDER_ID',
    projectId: 'urbink-dev',
    storageBucket: 'PLACEHOLDER_STORAGE_BUCKET',
    iosBundleId: 'com.urbink.app',
  );
}
