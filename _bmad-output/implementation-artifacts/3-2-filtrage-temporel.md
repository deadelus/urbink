# Story 3.2 — Filtrage temporel (aujourd'hui / semaine / mois / tout l'historique)
## Implementation Artifact

**Branch :** `develop`
**Epic :** Epic 3 — Historique & Filtrage Temporel

---

## Ce qui a été implémenté

### 1. TimeFilter enum + TimeFilterNotifier

**Fichier :** `lib/features/map/providers/time_filter_provider.dart`

```dart
enum TimeFilter { allTime, today, thisWeek, thisMonth }
```

Extension `TimeFilterX` :
- `label` — libellé affiché dans la barre (`Tout` / `Aujourd'hui` / `Cette semaine` / `Ce mois`)
- `from` — borne inférieure `DateTime?` (null = pas de filtre) :
  - `allTime` → null
  - `today` → `DateTime(year, month, day)` (minuit aujourd'hui)
  - `thisWeek` → `DateTime(year, month, day - 7)` (minuit il y a 7 jours — normalisé à la journée pour la stabilité des records Dart)
  - `thisMonth` → `DateTime(year, month, 1)` (1er du mois courant)

`TimeFilterNotifier` (StateNotifier) :
- Constructeur par défaut → `allTime`, charge la valeur persistée via `SharedPreferences` de façon asynchrone
- `TimeFilterNotifier.forTest(initial)` — constructeur `@visibleForTesting` sans `_load()`, utilisé dans les tests pour éviter la dépendance `SharedPreferences`
- `select(filter)` — met à jour l'état et persiste la clé `"time_filter"` en `SharedPreferences`

### 2. aggregation_provider.dart — filtrage Firestore par date

**Fichier :** `lib/features/map/providers/aggregation_provider.dart`

Signature de `sessionsStreetIdsStreamProvider` changée de `String` à `(String uid, DateTime? from)` :

```dart
final sessionsStreetIdsStreamProvider =
    Provider.family<Stream<List<List<String>>>, (String uid, DateTime? from)>(
  (ref, params) {
    final (uid, from) = params;
    var query = FirebaseFirestore.instance
        .collection('users').doc(uid).collection('sessions')
        .orderBy('sessionStart', descending: true);

    if (from != null) {
      query = query.where('sessionStart',
          isGreaterThanOrEqualTo: Timestamp.fromDate(from));
    }
    ...
  },
);
```

`aggregationProvider` watch `timeFilterProvider.select((f) => f.from)` et passe `(uid, from)` au stream injectable.

### 3. TimeFilterBar — barre de chips

**Fichier :** `lib/shared/widgets/time_filter_bar.dart`

- `SingleChildScrollView` horizontal (débordement propre sur petits écrans)
- Chip `AnimatedContainer` 200ms avec `Curves.easeInOut` entre les états sélectionné / non-sélectionné
- Couleurs : sélectionné → fond `primary` + texte blanc ; non-sélectionné → fond `surface` + bordure `primary` alpha 0.35
- Tap appelle `timeFilterProvider.notifier.select(filter)` — mise à jour immédiate de l'état

### 4. map_screen.dart — intégration UI

**Fichier :** `lib/features/map/screens/map_screen.dart`

`ZonesTogglePill` et `TimeFilterBar` regroupés dans un `Column` unique positionné à `bottom: SortiesBottomSheet.collapsedHeight + md` :

```
Column(
  ├─ TimeFilterBar  ← visible uniquement quand isIdle
  ├─ SizedBox(height: sm)
  └─ ZonesTogglePill  ← toujours visible (indépendant de la session)
)
```

La `TimeFilterBar` disparaît automatiquement quand une session est active (`isIdle = false`).

### 5. map_street_overlay.dart — transition fluide

**Fichier :** `lib/shared/widgets/map_street_overlay.dart`

`PolylineLayer` enveloppé dans un `AnimatedOpacity(duration: 250ms)` :
- Quand `aggregationProvider.isLoading` (requête Firestore en cours suite au changement de filtre) → opacité 0.0
- Quand data disponible → opacité 1.0

Produit un fondu sortant/entrant à chaque changement de filtre.

---

## Flux de données (filtrage temporel)

```
TimeFilterBar (tap)
    └─ timeFilterProvider.select(filter)
        └─ aggregationProvider (rebuild)
            └─ sessionsStreetIdsStreamProvider((uid, filter.from))
                └─ Firestore query avec where('sessionStart', >=, from)
                    └─ Set<String> streetIds filtrés
                        └─ MapStreetOverlay (AnimatedOpacity fade)
```

---

## Persistence du filtre

- Clé SharedPreferences : `"time_filter"` — valeur = `filter.name` (ex: `"today"`)
- Chargement asynchrone au démarrage, non-bloquant (garde `allTime` le temps du chargement)
- Filtre par défaut : `allTime` (tout l'historique) — conforme AC3

---

## Tests

**Fichiers :**
- `test/features/map/providers/time_filter_provider_test.dart` (nouveau — 6 cas)
- `test/features/map/providers/aggregation_provider_test.dart` (mis à jour — 9 cas)
- `test/features/sessions/providers/current_uid_provider_test.dart` (signature mise à jour)

Cas couverts `TimeFilterX` :
- `allTime.from` → null
- `today.from` → minuit du jour courant (heure 0:00:00)
- `thisWeek.from` → `DateTime(year, month, day - 7)`
- `thisMonth.from` → `DateTime(year, month, 1)`
- Tous les labels non vides
- `today.label` contient "Aujourd'hui"

Cas couverts `aggregationProvider` (9 tests) :
- uid null → Set vide
- Aucune session → Set vide
- Union depuis plusieurs sessions
- Déduplication
- Mise à jour réactive
- Tolérance `streetIds: []`
- Filtre `today` — stream distinct du stream `allTime`
- Filtre `thisWeek` — union correcte

**Stratégie :** `TimeFilterNotifier.forTest(filter)` injecté via `timeFilterProvider.overrideWith(...)` — zéro dépendance `SharedPreferences` en test. `sessionsStreetIdsStreamProvider((uid, from))` toujours surchargeable par paramètre record.

**Suite complète :** 219 tests ✅ — `flutter analyze` 0 issue ✅

---

## Points d'attention pour Story 3.3

- `timeFilterProvider` peut être réutilisé dans l'onglet Vous (Story 3.3) pour filtrer la liste des sorties affichées dans `WeekHistogram`
- `sessionsStreetIdsStreamProvider` expose désormais les dates des sessions via le paramètre `from` — Story 3.3 aura besoin d'un provider dédié qui récupère les sessions avec leurs métadonnées (date, km, durée) depuis Firestore
