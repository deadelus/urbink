import 'package:latlong2/latlong.dart';

/// Configuration d'un niveau de zones géographiques (ex: arrondissements, quartiers).
///
/// Chaque ville peut avoir N niveaux, affichés selon la plage de zoom courante.
class ZoneLevelConfig {
  final String assetKey;    // clé dans assets/geo/{city}/{assetKey}.json
  final double minZoom;     // zoom minimum pour afficher ce niveau (inclusif)
  final double? maxZoom;    // zoom maximum (exclusif) — null = pas de limite haute
  final double strokeWidth;
  final double labelSize;
  final bool dynamicWidth;

  /// Transforme le nom brut d'une zone en libellé affiché.
  /// null = afficher le nom tel quel.
  final String Function(String name)? labelBuilder;

  const ZoneLevelConfig({
    required this.assetKey,
    required this.minZoom,
    this.maxZoom,
    required this.strokeWidth,
    required this.labelSize,
    required this.dynamicWidth,
    this.labelBuilder,
  });
}

/// Configuration complète d'une ville.
class CityConfig {
  final String id;
  final LatLng center;
  final double initialZoom;
  final List<ZoneLevelConfig> zoneLevels;

  const CityConfig({
    required this.id,
    required this.center,
    required this.initialZoom,
    required this.zoneLevels,
  });

  /// Retourne le niveau de zones actif pour un zoom donné, ou null si aucun.
  ZoneLevelConfig? activeLevelFor(double zoom) {
    for (int i = zoneLevels.length - 1; i >= 0; i--) {
      final level = zoneLevels[i];
      if (zoom >= level.minZoom &&
          (level.maxZoom == null || zoom < level.maxZoom!)) {
        return level;
      }
    }
    return null;
  }
}

// ---------------------------------------------------------------------------
// Registre des villes supportées
// ---------------------------------------------------------------------------

final citiesRegistry = <String, CityConfig>{
  'paris': CityConfig(
    id: 'paris',
    center: const LatLng(48.8566, 2.3522),
    initialZoom: 13.0,
    zoneLevels: [
      ZoneLevelConfig(
        assetKey: 'arrondissements',
        minZoom: 0,
        maxZoom: 13.5,
        strokeWidth: 1.2,
        labelSize: 11.0,
        dynamicWidth: false,
        // "1er" → "1", "2e" → "2", "14e" → "14"
        labelBuilder: (name) => name.replaceAll(RegExp(r'[erème]+$'), ''),
      ),
      ZoneLevelConfig(
        assetKey: 'quartiers',
        minZoom: 13.5,
        strokeWidth: 1.4,
        labelSize: 9.5,
        dynamicWidth: true,
        labelBuilder: (name) => name.toUpperCase(),
      ),
    ],
  ),
};
