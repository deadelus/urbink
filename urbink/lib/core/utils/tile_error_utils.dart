/// Retourne true si [error] est un `CancelledException` issu du chargement
/// des tuiles vector (vector_map_tiles / executor), false dans tous les autres
/// cas — y compris si un autre package utilise un nom de classe identique.
///
/// On vérifie deux conditions :
/// 1. Le type runtime de l'erreur est `CancelledException` (comparaison par
///    nom de classe, la seule option car le type n'est pas exporté publiquement
///    par le package executor).
/// 2. Le stack trace contient au moins une frame provenant de `vector_map_tiles`
///    ou du sous-package `executor`, ce qui scopte le filtre aux seules erreurs
///    de tuiles et évite de silencer des `CancelledException` non liées.
bool isCancelledTileError(Object error, StackTrace stack) {
  if (error.runtimeType.toString() != 'CancelledException') return false;
  final frames = stack.toString();
  return frames.contains('vector_map_tiles') || frames.contains('/executor/');
}
