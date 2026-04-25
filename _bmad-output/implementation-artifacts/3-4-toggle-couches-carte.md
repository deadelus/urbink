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
  final LatLng position;
}
```

`Monument.fromGeoJsonFeature` : parse un feature GeoJSON (coordonnées `[lng, lat]` → `LatLng(lat, lng)`). Fallback `'📍'` si `category_icon` absent.

### 2. currentCityProvider (refacto multi-ville)

**Fichier :** `lib/core/providers/city_provider.dart`

```dart
final currentCityProvider = StateProvider<String>((ref) => 'paris');
```

Point d'entrée unique pour le slug de la ville active. Tous les providers geo (`monuments`, `arrondissements`, `quartiers`) consomment ce provider — changer `'paris'` en `'lyon'` rechargera automatiquement tous les assets. La géolocalisation automatique et la sélection manuelle se brancheront ici dans une story multi-ville dédiée.

### 3. monumentsProvider

**Fichier :** `lib/features/map/providers/monuments_provider.dart`

```dart
final monumentsProvider = FutureProvider<List<Monument>>((ref) async {
  final city = ref.watch(currentCityProvider);
  final raw = await rootBundle.loadString('assets/geo/$city/monuments.json');
  ...
});
```

Charge les 1 999 monuments depuis `assets/geo/{city}/monuments.json` (base Mérimée enrichie, GeoJSON FeatureCollection). `arrondissementsProvider` et `quartiersProvider` ont été mis à jour de la même façon (pattern `assets/geo/$city/`).

### 4. mapLayersProvider

**Fichier :** `lib/features/map/providers/map_layers_provider.dart`

```dart
final mapLayersProvider = StateProvider<Map<String, bool>>((ref) {
  return const {'monuments': true, 'quartiers': false, 'photos': false};
});
```

Remplace le `Map<String,bool>` local (`_layerValues`) dans `_SelectModeBodyState`. Permet aux overlays carte d'observer les toggles sans passer par le widget tree.

`quartiers` n'est pas géré ici (reste sous `zonesLayerVisibleProvider` — source of truth) : le bottom sheet fusionne les deux lors du rendu.

### 5. MapMonumentsOverlay

**Fichier :** `lib/shared/widgets/map_monuments_overlay.dart`

ConsumerWidget placé dans les `children` de `FlutterMap` (après `MapZonesOverlay`).

- Masqué si `mapLayersProvider['monuments'] == false`
- Masqué si `zoom < 12.0` (évite le clutter à vue d'ensemble)
- Utilise `CircleLayer` (rendu canvas — efficace pour ~2000 points)
- Cercles amber (`UrbinkColors.accent` @ 75 %) + bordure blanche, rayon 5px

### 6. Modifications

**`map_screen.dart`** — `MapMonumentsOverlay()` ajouté dans les children FlutterMap après `MapZonesOverlay`.

**`sorties_bottom_sheet.dart` — `_SelectModeBodyState`**
- Suppression du champ `_layerValues` et de `initState`
- `build` observe `mapLayersProvider` + `zonesLayerVisibleProvider` et fusionne (`{...layers, 'quartiers': quartiersVisible}`)
- `onChanged` met à jour `mapLayersProvider` (monuments + photos) et `zonesLayerVisibleProvider` (quartiers) séparément

---

## Tests

| Fichier | Tests |
|---------|-------|
| `test/features/map/models/monument_test.dart` | 3 — parse champs, coordonnées GeoJSON, fallback icon |
| `test/features/map/providers/map_layers_provider_test.dart` | 4 — état initial, toggle monuments, toggle photos, clés présentes |

**Total :** 272 tests ✅ · `flutter analyze --no-pub` 0 issue ✅

---

## Hors scope

- Clustering des monuments (Story 6.x — badges monuments)
- Affichage des pins communautaires (Story 8.1 — structure Firestore pins)
- Détail monument au tap (Story 6.3 — description Wikidata)
- Géolocalisation automatique de la ville (story multi-ville dédiée)

---

## Status

`done`
