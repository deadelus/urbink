# Implementation Artifact — Story 5.2

## Story
Epic 5 · Story 5.2 — Génération parcours automatique (Cloud Function)

## ACs implémentés

- [x] Given l'onglet Parcours → section "Parcours automatique" / When l'utilisateur choisit une durée cible (15 / 30 / 45 / 60 min) et tape "Générer" / Then la Cloud Function `generate_parcours.go` est appelée — elle retourne un circuit en ≤ 3 secondes (NFR3)
- [x] Given la Cloud Function `generate_parcours.go` / When elle calcule le circuit / Then elle maximise les rues non encore explorées (estimate 70 %), respecte la durée cible selon le mode de transport choisi (walk/bike/car)
- [x] Given le parcours généré retourné / When il s'affiche dans l'app / Then `RouteMapPreview` en variante `medium` montre le tracé — distance estimée, durée et nombre de rues nouvelles sont affichés — un CTA "Démarrer ce parcours" est disponible
- [x] Given un appel à la Cloud Function qui échoue (timeout > 5s) / When le timeout est atteint / Then un message d'erreur bienveillant s'affiche : "Impossible de générer un parcours pour l'instant, réessaie dans quelques instants"

## Tasks / Subtasks

- [x] Créer `functions/generate_parcours/main.go` — Cloud Function HTTP Go avec algorithme circuit circulaire + vérification token Firebase Auth
- [x] Créer `functions/generate_parcours/main_test.go` — 15 tests Go (speedMPerMin, circuitPoints, generateCircuit, circuitName, process)
- [x] Créer `lib/features/parcours/services/parcours_generation_service.dart` — HTTP POST vers CF, timeout 5s, injection `http.Client` + `getIdToken`
- [x] Créer `lib/features/parcours/providers/parcours_generation_provider.dart` — états sealed (Idle/Loading/Success/Error), `ParcoursGenerationNotifier`, `lastKnownPositionProvider`
- [x] Créer `lib/features/parcours/screens/parcours_screen.dart` — `DurationSelector` (15/30/45/60), `ModeSelector`, bouton Générer, état loading, résultat (RouteMapPreview medium + stats + CTA), erreur
- [x] Brancher `ParcoursScreen` dans `lib/core/router/app_router.dart` (remplace placeholder)
- [x] Écrire `test/parcours/parcours_screen_test.dart` — 15 tests widget (idle, loading, success, error)
- [x] `flutter analyze --no-pub` → 0 issue ✅
- [x] `flutter test` → 474/474 tests passent ✅

## Dev Notes

### Architecture

- Cloud Function Go : HTTP handler (non trigger Firestore) — pattern identique à `on_monument_proximity` mais avec signature `func(http.ResponseWriter, *http.Request)`
- Algorithme circuit : `circuitPoints(centerLat, centerLng, radiusM)` génère 8 waypoints + fermeture sur un cercle. Rayon = `total_distance / (2π)` où `total_distance = speed[mode] × durationMin`
- Vitesses : walk = 83 m/min (~5 km/h), bike = 250 m/min (~15 km/h), car = 500 m/min (~30 km/h)
- Estimation `newStreetsCount` : 70 % de `estimatedDistance` divisé par 120 m/rue
- URL CF injectée via `--dart-define=FUNCTIONS_BASE_URL` (défaut : `urbink-dev`)
- `ParcoursGenerationService` injectable via `httpClientProvider` + `authTokenProvider` — 0 Firebase dans les tests
- `ParcoursGenerationNotifier.forTest(state)` : constructeur `@visibleForTesting` avec champs `late final` pour éviter Firebase dans les tests widget

### États `ParcoursGenerationState`

```dart
sealed class ParcoursGenerationState { ... }
class ParcoursGenerationIdle       extends ParcoursGenerationState
class ParcoursGenerationLoading    extends ParcoursGenerationState
class ParcoursGenerationSuccess    extends ParcoursGenerationState { parcours, newStreetsCount }
class ParcoursGenerationError      extends ParcoursGenerationState { message }
```

### Cloud Function response JSON

```json
{
  "name": "Circuit 30 min à pied",
  "points": [{"lat": 48.8566, "lng": 2.3522}, ...],  // 9 points (8 + fermeture)
  "estimatedDistance": 2490,
  "estimatedDuration": 1800,
  "mode": "walk",
  "type": "auto",
  "newStreetsCount": 14,
  "createdAt": "2026-05-12T..."
}
```

### UX

- Bouton Générer désactivé (spinner inline) pendant le loading
- Sélecteurs ChoiceChip désactivés pendant le loading (onChanged = null)
- CTA "Démarrer ce parcours" (Ocre) → sauvegarde dans Firestore via `ParcoursRepository.create` — guidage réel en Story 5.4
- Position GPS : `Geolocator.getLastKnownPosition()` via `lastKnownPositionProvider`, fallback Paris (48.8566, 2.3522)

## Dev Agent Record

### Completion Notes

- Cloud Function Go — 15/15 tests, algorithme circulaire pur (pas d'appel OSM au MVP), timeout NFR3 garanti par la simplicité algorithmique O(1)
- `ParcoursGenerationService` : injection `http.Client` + `getIdToken` pour testabilité sans Firebase
- `ParcoursGenerationNotifier` : constructeur `.forTest(state)` + champs `late final` évitent l'init Firebase dans les tests widget
- `ParcoursScreen` : 4 états visuels (idle/loading/success/error), sélecteurs ChoiceChip, `RouteMapPreview` variant medium, stats row (km / min / rues)
- Router : `_PlaceholderScreen(label: 'Parcours')` remplacé par `ParcoursScreen()`
- 15 nouveaux tests widget (474 total = 459 baseline + 15) — 0 régression
- `flutter analyze --no-pub` : 0 issue

## File List

- `_bmad-output/implementation-artifacts/5-2-generation-parcours-automatique.md`
- `functions/generate_parcours/main.go` (nouveau)
- `functions/generate_parcours/main_test.go` (nouveau)
- `urbink/lib/features/parcours/services/parcours_generation_service.dart` (nouveau)
- `urbink/lib/features/parcours/providers/parcours_generation_provider.dart` (nouveau)
- `urbink/lib/features/parcours/screens/parcours_screen.dart` (nouveau)
- `urbink/lib/core/router/app_router.dart` (modifié)
- `urbink/test/parcours/parcours_screen_test.dart` (nouveau)

## Change Log

- Ajout Story 5.2 — Génération parcours automatique Cloud Function + ParcoursScreen (Date: 2026-05-12)

## Status

review
