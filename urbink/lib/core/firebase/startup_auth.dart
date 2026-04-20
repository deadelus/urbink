/// Authentifie silencieusement l'utilisateur de façon anonyme si nécessaire.
///
/// Appelé au démarrage de l'app quand la politique de confidentialité a été
/// acceptée. Sans appel, [currentUidProvider] retourne null et toutes les
/// écritures Firestore sont ignorées (FR32).
Future<void> ensureAnonymousAuth({
  required bool Function() isSignedIn,
  required Future<void> Function() signInAnonymously,
}) async {
  if (!isSignedIn()) {
    await signInAnonymously();
  }
}
