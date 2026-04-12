import 'package:latlong2/latlong.dart';

abstract final class MapConstants {
  /// Centre initial de la carte : Paris.
  static const LatLng initialCenter = LatLng(48.8566, 2.3522);

  /// Zoom initial affiché au démarrage.
  static const double initialZoom = 13.0;

  /// Zoom minimum autorisé (vue grande région).
  static const double minZoom = 10.0;

  /// Zoom maximum autorisé (vue rue très détaillée).
  static const double maxZoom = 18.0;

  /// Clé MapTiler injectée via `--dart-define=MAPTILER_KEY=valeur`.
  static const String _mapTilerKey =
      String.fromEnvironment('MAPTILER_KEY');

  /// ID de la map MapTiler.
  static const String _mapTilerId =
      '019d8380-71b7-7e7b-9a8e-db45546c20e5';

  /// URL style.json MapTiler (vector tiles).
  static String get mapTilerStyleUrl =>
      'https://api.maptiler.com/maps/$_mapTilerId/style.json?key=$_mapTilerKey';

  /// User-Agent envoyé aux serveurs de tuiles (conformité politique OSM).
  static const String userAgent = 'com.urbink.app';
}
