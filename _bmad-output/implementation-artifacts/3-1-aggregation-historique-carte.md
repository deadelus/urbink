# Story 3.1 — Moteur d'agrégation des sessions + affichage carte historique
## Implementation Artifact

**Branch :** `story-3.1-aggregation-historique-carte`
**Epic :** Epic 3 — Historique & Filtrage Temporel

---

## Ce qui a été implémenté

### 1. PassiveStreetRepository — persistance géométrie GPS

**Fichier :** `lib/features/map/services/passive_street_repository.dart`

- Nouvelle méthode `appendStreetPoint(userId, streetId, GeoPoint)` — utilise `FieldValue.arrayUnion` pour n'écrire que le delta (idempotent)
- Schéma Firestore `/users/{uid}/streets/{streetId}` enrichi : `{lastExploredAt, points: [GeoPoint]}`
- `_streetRef()` helper privé pour éviter la duplication du chemin de collection

### 2. MapStreetOverlayProvider — persistance par point GPS

**Fichier :** `lib/features/map/providers/map_street_overlay_provider.dart`

- `_onPosition()` appelle désormais `appendStreetPoint()` à **chaque** position GPS (plus uniquement à la première visite d'une rue)
- Fréquence réelle : ≈ 1 write/30s par rue explorée (GPS filtré à ≥ 10m de déplacement)
- Import `cloud_firestore` ajouté pour `GeoPoint`

### 3. aggregation_provider.dart (nouveau)

**Fichier :** `lib/features/map/providers/aggregation_provider.dart`

```dart
// Stream injectable — peut être surchargé en test sans Firebase
final sessionsStreetIdsStreamProvider =
    Provider.family<Stream<List<List<String>>>, String>(...);

// Union réactive de tous les streetIds
final aggregationProvider = StreamProvider<Set<String>>((ref) { ... });
```

- `sessionsStreetIdsStreamProvider` (Provider.family) : stream brut injectable, évite la dépendance Firebase en test
- `aggregationProvider` (StreamProvider) : watch sur `currentUidProvider` → retourne `Set.empty()` si non authentifié
- Mise à jour automatique via Firestore `onSnapshot` (AC3)

### 4. historical_streets_provider.dart (nouveau)

**Fichier :** `lib/features/map/providers/historical_streets_provider.dart`

```dart
final historicalStreetsProvider = StreamProvider<Map<String, List<LatLng>>>((ref) { ... });
```

- Stream `/users/{uid}/streets/` → `Map<streetId, List<LatLng>>`
- Conversion `GeoPoint → LatLng` à la volée
- Retourne map vide si non authentifié

### 5. MapStreetOverlay — double couche (FR7)

**Fichier :** `lib/shared/widgets/map_street_overlay.dart`

Deux couches `PolylineLayer` superposées :

| Couche | Source | Couleur | Alpha | Condition |
|--------|--------|---------|-------|-----------|
| Historique | `historicalStreetsProvider` | `streetExplored` | 0.4 | Rues absentes de l'état live, ≥ 2 points |
| Live | `mapStreetOverlayProvider` | `streetExplored` / `streetRecording` | 0.75 / 1.0 | ≥ 2 points |

- Les rues live (session courante) masquent leurs homologues historiques (rendu sur le dessus)
- `SizedBox.shrink()` si les deux sources sont vides — pas de rebuild inutile

---

## Flux complet de données (état idle)

```
Firestore /users/{uid}/sessions/
    └─ sessionsStreetIdsStreamProvider (injectable)
        └─ aggregationProvider → Set<String> (streetIds historiques)

Firestore /users/{uid}/streets/
    └─ historicalStreetsProvider → Map<streetId, List<LatLng>>

MapStreetOverlay
    ├─ historicalStreetsProvider → couche fond (alpha 0.4)
    └─ mapStreetOverlayProvider → couche live (alpha 0.75)
```

---

## Tests

**Fichier :** `test/features/map/providers/aggregation_provider_test.dart`

6 cas couverts :
- uid null → Set vide
- Aucune session → Set vide
- Union de streetIds depuis plusieurs sessions
- Déduplication des streetIds partagés
- Mise à jour réactive sur nouvelle émission du stream
- Tolérance session avec `streetIds: []`

**Stratégie :** `sessionsStreetIdsStreamProvider` surchargé avec `StreamController<List<List<String>>>` — zéro dépendance Firebase en test.

**Suite complète :** 203 tests ✅ — `flutter analyze` 0 issue ✅

---

## Points d'attention pour Story 3.2

- `aggregationProvider` dépend actuellement de **toutes** les sessions (pas de filtre date)
- Pour Story 3.2 : filtrer côté client dans `sessionsStreetIdsStreamProvider` via `sessionStart` avant de calculer l'union
- `historicalStreetsProvider` reste inchangé — seul `aggregationProvider` est filtré (les géométries sont dans la streets collection)
- Le filtre actif (SharedPreferences) sera exposé via un nouveau `timeFilterProvider`
