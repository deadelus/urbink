// Barrel des providers Riverpod globaux.
// Les providers de chaque feature sont définis dans leur feature directory
// et ré-exportés ici si besoin d'un accès cross-feature.
//
// Convention de nommage :
//   camelCase + suffixe : sessionProvider, mapStateProvider, authStateProvider
//
// Règle absolue : jamais d'appel Firestore direct dans un widget — toujours via un provider.

export 'package:flutter_riverpod/flutter_riverpod.dart';
