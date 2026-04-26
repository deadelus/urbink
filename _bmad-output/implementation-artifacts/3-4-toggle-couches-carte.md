# Story 3.4 — Toggle couches carte (monuments, pins, quartiers)
## Implementation Artifact

**Branch :** `epic-3/story-3.4-toggle-couches-carte`
**Epic :** Epic 3 — Historique & Filtrage

---

## Ce qui a été implémenté

### 1. Monument model

**Fichier :** `lib/features/map/models/monument.dart`

```dart
class Monument {
  final String id;
  final String name;
  final String category;
  final String categoryIcon;
  final String subtype;   // sous-type Mérimée (ex: "Fontaine", "Station de métro")
  final LatLng position;
}
```

`Monument.fromGeoJsonFeature` : parse un feature GeoJSON (`[lng, lat]` → `LatLng(lat, lng)`). Fallback `'📍'` si `category_icon` absent. `subtype` vaut `''` si absent du JSON.

### 2. currentCityProvider (refacto multi-ville)

**Fichier :** `lib/core/providers/city_provider.dart`

```dart
final currentCityProvider = StateProvider<String>((ref) => 'paris');
```

Point d'entrée unique pour le slug de la ville active. Tous les providers geo (`monuments`, `arrondissements`, `quartiers`) consomment ce provider — changer `'paris'` en `'lyon'` rechargera automatiquement tous les assets.

### 3. CityConfig + citiesRegistry

**Fichier :** `lib/core/config/city_config.dart`

`CityConfig` : `id`, `center`, `initialZoom`, `zoneLevels`. `activeLevelFor(zoom)` retourne le `ZoneLevelConfig` actif au zoom donné.

`ZoneLevelConfig` : `assetKey`, `minZoom`, `maxZoom?`, `strokeWidth`, `labelSize`, `dynamicWidth`, `labelBuilder?`. Paris : arrondissements (0–13.5) + quartiers (13.5+).

`citiesRegistry` : `Map<String, CityConfig>` — source of truth pour toutes les villes supportées.

### 4. MapStyleConfig

**Fichier :** `lib/core/config/map_style_config.dart`

```dart
const mapStylesRegistry = <MapStyleConfig>[
  MapStyleConfig(id: 'urbink_default', name: 'Urbink', tileId: '019d8380-...'),
];
```

`activeMapStyleProvider` : `StateProvider<MapStyleConfig>` — hot-swap du style via `ref.listenManual` dans `map_screen.dart`.

### 5. monumentsProvider + zonesProviderFamily

**Fichier :** `lib/features/map/providers/monuments_provider.dart`  
**Fichier :** `lib/features/map/providers/zones_provider.dart`

Chargement des assets GeoJSON depuis `assets/geo/{city}/` — city-agnostic grâce à `currentCityProvider`.

### 6. mapLayersProvider

**Fichier :** `lib/features/map/providers/map_layers_provider.dart`

```dart
final mapLayersProvider = StateProvider<Map<String, bool>>((ref) {
  return const {'monuments': true, 'quartiers': false, 'photos': false};
});
```

Remplace le `_layerValues` local dans `_SelectModeBodyState`. Allows overlays to observe toggles independently.

### 7. monumentVisibilityPredicateProvider

**Fichier :** `lib/features/map/providers/monument_category_filter_provider.dart`

Prédicat `bool Function(Monument)` dérivé des filtres actifs. Remplace l'approche catégorie-set par une logique catégorie + sous-type :

- `'monuments'` → toutes les grandes catégories patrimoniales (Palais, Statues, Édifices religieux, Petit patrimoine, Transports, Patrimoine industriel)
- `'statues'` → `category == 'Statues & sculptures urbaines'`
- `'fontaines'` → `subtype == 'Fontaine'`
- `'ponts'` → `subtype ∈ {Pont, Passerelle, Aqueduc}`
- `'eglises'` → `category == 'Édifices religieux'`
- `'palais'` → `category == 'Palais & Monuments emblématiques'`
- `'metro_histo'` → `subtype == 'Station de métro'`
- `'musees'`, `'theatres'`/`'cinemas'`, `'cafes'`/`'restaurants'`, `'parcs'`/`'jardins'` → catégories correspondantes

`hasActiveMonumentFiltersProvider` : `bool` — early-exit dans l'overlay si aucun filtre actif.

### 8. poi_filters.dart — catégorie monuments_detail

**Fichier :** `lib/shared/constants/poi_filters.dart`

Nouvelle `PoiFilterCategory(id: 'monuments_detail', label: 'Types de monuments')` avec 6 filtres : statues, fontaines, ponts, eglises, palais, metro_histo.

### 9. MapMonumentsOverlay

**Fichier :** `lib/shared/widgets/map_monuments_overlay.dart`

- Masqué si `mapLayersProvider['monuments'] == false`
- Masqué si `zoom < 14.0` (niveau quartier/rue)
- Viewport culling via `MapCamera.of(context).visibleBounds`
- Filtrage via `monumentVisibilityPredicateProvider` (prédicat par monument)
- `CircleLayer` — rendu canvas ; cercles `UrbinkColors.accent` @ 75 % + bordure blanche 1px

Par défaut : `'monuments'` actif → ~874 monuments visibles (1125 de catégories résidentielles masqués).

---

## Tests

| Fichier | Tests |
|---------|-------|
| `test/features/map/models/monument_test.dart` | 3 — parse champs, coordonnées, fallback icon |
| `test/features/map/providers/map_layers_provider_test.dart` | 4 — état initial, toggle monuments/photos, clés présentes |
| `test/features/map/providers/monument_category_filter_provider_test.dart` | 16 — prédicat (catégorie + sous-type), hasActiveFilters |
| `test/core/config/city_config_test.dart` | 11 — citiesRegistry paris, activeLevelFor, labelBuilder |
| `test/core/providers/city_config_provider_test.dart` | 3 — config paris, fallback, changement de ville |

**Total :** 32 tests nouveaux + suite existante ✅ · `flutter analyze --no-pub` 0 erreur ✅

---

## Hors scope

- Clustering des monuments (Story 6.x)
- Affichage des pins communautaires (Story 8.1)
- Détail monument au tap (Story 6.3)
- Géolocalisation automatique de la ville (story multi-ville dédiée)
- SharedPreferences pour mémoriser l'état des toggles (AC4 — reporté)

---

## Status

`done`
