abstract final class MapConstants {
  /// Zoom initial affiché au démarrage (commun à toutes les villes).
  /// Le centre initial est défini par [CityConfig.center] dans le registre des villes.
  static const double initialZoom = 13.0;

  /// Zoom minimum autorisé (vue grande région).
  static const double minZoom = 10.0;

  /// Zoom maximum autorisé (vue rue très détaillée).
  static const double maxZoom = 18.0;

  /// Clé MapTiler injectée via `--dart-define=MAPTILER_KEY=valeur`.
  static const String _mapTilerKey =
      String.fromEnvironment('MAPTILER_KEY');

  /// URL style.json pour un ID de style MapTiler donné.
  /// Le style actif est fourni par [activeMapStyleProvider].
  static String styleUrl(String tileId) =>
      'https://api.maptiler.com/maps/$tileId/style.json?key=$_mapTilerKey';

  /// User-Agent envoyé aux serveurs de tuiles (conformité politique OSM).
  static const String userAgent = 'com.urbink.app';
}
