# Implementation Artifact — Story 5.1

## Story
Epic 5 · Story 5.1 — Composant RouteMapPreview + modèle de données parcours Firestore

## ACs implémentés

- [x] Given la collection `/users/{userId}/parcours/{parcoursId}` dans Firestore / When un parcours est créé / Then il contient : `name`, `points[]` (lat/lng), `estimatedDistance`, `estimatedDuration`, `mode`, `type` (auto/custom), `createdAt` (FR21, FR22)
- [x] Given le widget `RouteMapPreview` / When il reçoit une liste de points GPS / Then il affiche un fond schématique warm-off-white avec une polyline Vert Sauge (sorties) ou Ocre (itinéraires planifiés), point de départ vert, point d'arrivée ocre (UX-DR8)
- [x] Given `RouteMapPreview` en variante `small` (176×85px) / When il est utilisé dans un `ListTile` ou `FeedActivityItem` / Then il s'affiche correctement sans overflow — variante `medium` full-width 16:9 dans l'écran détail parcours, `thumbnail` 48×48px dans les listes compactes

## Tasks / Subtasks

- [x] Créer `lib/features/parcours/data/parcours_model.dart` — `Parcours` model + `ParcoursType` enum + Firestore serialization (to/fromFirestore)
- [x] Créer `lib/features/parcours/data/parcours_repository.dart` — `ParcoursRepository` (create, streamByUser, delete)
- [x] Créer `lib/features/parcours/providers/parcours_provider.dart` — `parcoursListProvider` (StreamProvider) + `parcoursRepositoryProvider`
- [x] Ajouter `UrbinkColors.ocre` dans `lib/shared/constants/colors.dart`
- [x] Créer `lib/features/parcours/widgets/route_map_preview.dart` — `RouteMapPreview` widget + `RouteMapVariant` enum + `_RouteMapPainter` CustomPainter (3 variants : small/medium/thumbnail)
- [x] Écrire `test/parcours/parcours_model_test.dart` (unit tests: sérialisation Firestore, ParcoursType, TransportMode)
- [x] Écrire `test/parcours/route_map_preview_test.dart` (widget tests: 3 variants, empty state, couleurs session vs itinéraire)
- [x] `flutter analyze --no-pub` → 0 issue ✅
- [x] `flutter test` → 459/459 tests passent ✅

## Dev Notes

### Architecture
- `Parcours` réutilise `TransportMode` de `lib/features/sessions/models/transport_mode.dart`
- `ParcoursRepository` suit le pattern `firestoreProvider` + `currentUidProvider` de `quartier_badges_provider.dart`
- `RouteMapPreview` : `CustomPainter` autonome, aucune dépendance flutter_map
- Points GPS normalisés dans le widget bounds par le painter (min/max lat/lng → pixel space)
- `firestoreProvider` défini dans `features/gamification/providers/quartier_badges_provider.dart`

### Modèle Firestore `/users/{userId}/parcours/{parcoursId}`
```
name: string
points: [{lat: double, lng: double}]   ← liste de maps (pas GeoPoint)
estimatedDistance: double              ← mètres
estimatedDuration: int                 ← secondes
mode: 'walk' | 'bike' | 'car'
type: 'auto' | 'custom'
createdAt: Timestamp
```

### RouteMapPreview Design (UX-DR8)
- Fond : `Color(0xFFFAF9F7)` warm-off-white, borderRadius 8
- Polyline session/sortie : `UrbinkColors.streetExplored` (Vert Sauge #256F4C)
- Polyline itinéraire planifié : `UrbinkColors.ocre` (#B8832E)
- Point départ : cercle `UrbinkColors.sessionGreen` (#4ADE80), r=4
- Point arrivée : cercle `UrbinkColors.ocre`, r=4
- Stroke : 2.5px, StrokeCap.round, StrokeJoin.round
- Variantes :
  - `small` : 176×85px
  - `medium` : AspectRatio 16:9, width double.infinity
  - `thumbnail` : 48×48px, borderRadius 6
- État vide (0 ou 1 point) : fond seul, aucune polyline

### Normalisation GPS → pixels
- Padding interne : 6px (small/thumbnail), 12px (medium)
- Flip vertical : lat augmente vers le haut, mais pixel Y vers le bas

## Dev Agent Record

### Debug Log

### Completion Notes
- `Parcours` : model avec sérialisation Firestore complète — `points` → `[{lat, lng}]`, `TransportMode.firestoreValue`, `ParcoursType.firestoreValue`
- `ParcoursRepository` : create / streamByUser (orderBy createdAt desc) / delete — pattern identique à `quartier_badges_provider`
- `parcoursListProvider` : StreamProvider, uid null → Stream.value([])
- `UrbinkColors.ocre` : `Color(0xFFB8832E)` ajouté au design system
- `RouteMapPreview` : CustomPainter autonome (sans flutter_map), normalisation GPS → pixels avec padding variant-aware, aspect ratio préservé, flip Y lat/pixel
- 3 variants : small 176×85, medium AspectRatio(16/9), thumbnail 48×48 — ClipRRect border-radius 8/6
- État vide (0 ou 1 point) : fond seul, aucune polyline ni endpoint
- `latlong2.Path` masqué via `hide Path` pour éviter le conflit avec `dart:ui.Path`
- 21 nouveaux tests (7 unitaires model + 14 widget) + 438 existants = 459/459 ✅

## File List

- `_bmad-output/implementation-artifacts/5-1-route-map-preview.md`
- `urbink/lib/features/parcours/data/parcours_model.dart` (nouveau)
- `urbink/lib/features/parcours/data/parcours_repository.dart` (nouveau)
- `urbink/lib/features/parcours/providers/parcours_provider.dart` (nouveau)
- `urbink/lib/features/parcours/widgets/route_map_preview.dart` (nouveau)
- `urbink/lib/shared/constants/colors.dart` (modifié)
- `urbink/test/parcours/parcours_model_test.dart` (nouveau)
- `urbink/test/parcours/route_map_preview_test.dart` (nouveau)

## Change Log

- Ajout Story 5.1 — RouteMapPreview + modèle Parcours Firestore (Date: 2026-05-11)

## Status

done
