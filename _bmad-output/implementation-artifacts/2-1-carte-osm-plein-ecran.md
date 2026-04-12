# Story 2.1 : Affichage carte plein écran (flutter_map + MapTiler)

Status: done

## Story

En tant qu'**utilisateur**,
Je veux voir la carte complète de Paris dès l'ouverture de l'app,
Afin de me situer et de commencer à explorer immédiatement.

## Acceptance Criteria

- [x] **AC1 — Carte plein écran** : Onglet Carte (`/map`) affiche la carte remplissant 100% de la surface disponible (body au-dessus de la bottom nav). Centre initial : Paris (48.8566°N, 2.3522°E), zoom 13.
- [x] **AC2 — Interactions fluides** : Pinch-to-zoom et pan répondent sans saccade — zoom min/max configurés dans `shared/constants/map_constants.dart`.
- [x] **AC3 — Crédits carte** : Le texte "© MapTiler © OSM" est visible en permanence en bas à droite de la carte.
- [x] **AC4 — Fallback hors-ligne** : Quand le réseau est absent, un `UrbinkSnackBar` de type `info` informe l'utilisateur sans bloquer la carte.

## Tasks / Subtasks

- [x] **T1 — `map_constants.dart`** (AC1, AC2)
  - [x] `MapConstants.initialCenter`, `initialZoom`, `minZoom`, `maxZoom`
  - [x] `MapConstants.mapTilerStyleUrl` — URL style.json via `--dart-define=MAPTILER_KEY`
  - [x] `MapConstants.userAgent`

- [x] **T2 — `map_state_provider.dart`** (AC1)
  - [x] `mapControllerProvider` : `Provider<MapController>`

- [x] **T3 — `MapScreen`** (AC1, AC2, AC3, AC4)
  - [x] Chargement async du style MapTiler via `StyleReader`
  - [x] `VectorTileLayer` avec `tileProviders`, `theme`, `sprites`
  - [x] Attribution custom `© MapTiler © OSM` (9px, bas droite)
  - [x] Listener `connectivity_plus` → `showUrbinkSnackBar` info si hors ligne
  - [x] États : loading (CircularProgressIndicator) / erreur / carte

- [x] **T4 — Route `/map`** (AC1)
  - [x] `app_router.dart` : remplacement placeholder par `MapScreen()`

- [x] **T5 — `map_feature.dart`**
  - [x] Export `MapScreen` et `map_state_provider`

- [x] **T6 — Config clé MapTiler**
  - [x] `config/dev.json` (gitignored) + `config/dev.json.example`
  - [x] `.gitignore` mis à jour
  - [x] Lancement : `flutter run --dart-define-from-file=config/dev.json`

- [x] **T7 — Fix `main.dart`**
  - [x] Filtre `CancellationException` posé après `FirebaseService.initialize()` (Crashlytics override)

- [x] **T8 — Tests widget `MapScreen`**
  - [x] Smoke test : pas de crash
  - [x] Test : état loading ou erreur affiché (MAPTILER_KEY vide en test)

## Dev Notes

### Décision : MapTiler vector tiles vs OSM raster

Décision R&D : utilisation de MapTiler (style custom) à la place d'OSM tuiles raster.
- Package : `vector_map_tiles: ^8.0.0`
- Style vectoriel via `style.json` — tuiles raster PNG retournent 403 pour les maps custom MapTiler
- Map ID : `019d8380-71b7-7e7b-9a8e-db45546c20e5`
- Clé injectée via `--dart-define-from-file=config/dev.json` (jamais dans le code)

### Attribution

`SimpleAttributionWidget` et `RichAttributionWidget` ajoutent des logos flutter_map non désirés. Solution : widget `Align` + `DecoratedBox` custom avec `Text('© MapTiler © OSM', style: TextStyle(fontSize: 9))`.

### Fix CancellationException

`vector_map_tiles` annule les requêtes de tuiles lors des zooms → logs parasites.
Fix dans `main.dart` : filtre posé **après** `FirebaseService.initialize()` car `_setupCrashlytics()` override `FlutterError.onError` et appelle `presentError` avant de chaîner.

```dart
final previousFlutterHandler = FlutterError.onError;
FlutterError.onError = (details) {
  if (details.exception.toString() == 'Cancelled') return;
  previousFlutterHandler?.call(details);
};
```

### Config clé par environnement

```
config/dev.json          ← gitignored, clé réelle dev
config/dev.json.example  ← commité, template
```

CI staging/prod : génère `config/staging.json` depuis GitHub Secrets avant le build.

## Dev Agent Record

### Agent Model Used

Claude Sonnet 4.6

### Completion Notes

- ✅ AC1 : `MapScreen` affiche la carte MapTiler vector via `VectorTileLayer`, centrée Paris, zoom 13.
- ✅ AC2 : Zoom min/max (10–18) configurés via `MapOptions`.
- ✅ AC3 : Attribution `© MapTiler © OSM` visible en bas à droite (widget custom).
- ✅ AC4 : Listener `connectivity_plus` → snackbar info hors ligne.
- 104/104 tests passent — `flutter analyze` 0 issue.

### File List

- `urbink/pubspec.yaml` — ajout `vector_map_tiles: ^8.0.0`
- `urbink/lib/shared/constants/map_constants.dart` — créé + mis à jour (MapTiler, dart-define)
- `urbink/lib/features/map/providers/map_state_provider.dart` — créé
- `urbink/lib/features/map/screens/map_screen.dart` — créé (VectorTileLayer, attribution custom)
- `urbink/lib/features/map/map_feature.dart` — modifié (exports)
- `urbink/lib/core/router/app_router.dart` — modifié (route `/map`)
- `urbink/lib/main.dart` — modifié (filtre CancellationException)
- `urbink/config/dev.json` — créé (gitignored)
- `urbink/config/dev.json.example` — créé
- `urbink/.gitignore` — mis à jour
- `urbink/test/features/map/map_screen_test.dart` — créé (2 tests)

## Change Log

| Version | Date | Auteur | Description |
|---------|------|--------|-------------|
| 1.0 | 2026-04-11 | Claude Sonnet 4.6 | Implémentation initiale Story 2.1 (OSM raster) |
| 2.0 | 2026-04-13 | Claude Sonnet 4.6 | R&D + migration MapTiler vector tiles, config dart-define-from-file |
