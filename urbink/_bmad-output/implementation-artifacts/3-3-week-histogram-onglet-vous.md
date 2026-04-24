# Story 3.3 — Composant WeekHistogram + onglet Vous (historique personnel)
## Implementation Artifact

**Branch :** `epic-3/story-3.3-week-histogram-onglet-vous`
**Epic :** Epic 3 — Historique & Filtrage Temporel

---

## Ce qui a été implémenté

### 1. weekSessionsProvider — stream des sessions de la semaine

**Fichier :** `lib/features/profile/providers/week_sessions_provider.dart`

- `weekStart(DateTime now)` — helper qui retourne le lundi de la semaine courante à minuit (ex: vendredi 24/04 → lundi 20/04)
- `weekSessionsRawStreamProvider((uid, weekStart))` — `Provider.family` injectable, query Firestore filtrée sur `sessionStart` entre lundi et lundi+7j
- `weekSessionsProvider` — `StreamProvider.autoDispose<Map<DateTime, int>>` : agrège les streetIds uniques par jour (sessions sans rues ignorées), retourne `{DateTime(minuit) → count}`
- `selectedHistogramDayProvider` — `StateProvider<DateTime?>` : jour sélectionné dans l'histogramme, null = toutes les sorties. Tap sur le même jour → toggle (reset à null)

### 2. sessionsListProvider — stream toutes sessions + filtre

**Fichier :** `lib/features/profile/providers/sessions_list_provider.dart`

- `allSessionsRawStreamProvider(uid)` — `Provider.family` injectable, query Firestore ordonnée par `sessionStart` décroissant
- `sessionsByDayProvider` — `StreamProvider<List<Session>>` : watch `currentUidProvider` + `selectedHistogramDayProvider`, filtre la liste par jour si sélectionné

### 3. WeekHistogram — widget 7 barres

**Fichier :** `lib/shared/widgets/week_histogram.dart`

- 7 barres L→D générées depuis le lundi de la semaine courante
- Couleurs :
  - Jour courant avec activité → Ocre `#B8832E`
  - Autre jour avec activité → Vert Sauge `#256F4C` (primary)
  - Jour sans activité → Fantôme `#F0EDE8`, hauteur fixe 28dp
- Hauteur des barres actives : proportionnelle à `count / maxCount`, entre 6dp et 72dp
- `AnimatedContainer(200ms, Curves.easeInOut)` sur chaque barre
- Tap barre active → met à jour `selectedHistogramDayProvider` (toggle)
- Barre sélectionnée : bordure `onSurface 60%` épaisseur 2dp
- `_EmptyState` (aucune activité cette semaine) : toutes barres fantômes + message "Ta première sortie cette semaine n'attend que toi" + TextButton "Démarrer" → `context.go('/map')`
- `_HistogramSkeleton` pendant le chargement

### 4. ProfileScreen — onglet Vous

**Fichier :** `lib/features/profile/screens/profile_screen.dart`

Structure :
```
ProfileScreen
  ├─ _ProfileHeader (fixed)
  │    ├─ Titre "Vous" + _DayFilterChip (quand jour sélectionné)
  │    └─ WeekHistogram
  └─ _SessionsList (scrollable)
       ├─ _ViewToggle (Simple / Feed)
       ├─ Titre contextuel ("Toutes les sorties" / "Sorties du lundi 20 avr")
       └─ ListView<_SortieListTile> / Vue feed placeholder
```

- `_DayFilterChip` : chip cliquable pour réinitialiser le filtre (×)
- `_SortieListTile` : ListTile compact — emoji mode · date · `N rues · X km · Xmin`
- Vue feed : placeholder "Vue feed disponible à l'Epic 9"
- Empty state via `UrbinkEmptyState` avec message contextuel (global ou par jour)
- Formatage des dates en français **sans** dépendance locale `intl` : helpers `_formatDayShort`, `_formatDayLong`, `_formatSessionDate` (fonctions top-level)

### 5. Branchement dans app_router.dart

**Fichier :** `lib/core/router/app_router.dart`

Route `/profile` (branche 4 du `StatefulShellRoute`) branchée sur `ProfileScreen()` — remplace l'ancien `_PlaceholderScreen(label: 'Profil')`.

---

## Flux de données

```
WeekHistogram (tap barre)
    └─ selectedHistogramDayProvider (StateProvider<DateTime?>)
         └─ sessionsByDayProvider (filtre)
              └─ allSessionsRawStreamProvider(uid) → List<Session>
                    └─ _SessionsList → _SortieListTile

weekSessionsProvider
    └─ weekSessionsRawStreamProvider((uid, weekStart))
         └─ Firestore sessionStart >= lundi AND < lundi+7j
              └─ Map<DateTime, int> → WeekHistogram barres
```

---

## Points d'attention pour Story 3.4+

- `selectedHistogramDayProvider` et `sessionsByDayProvider` sont réutilisables depuis d'autres features
- La vue feed dans `_SessionsList` est un placeholder — `FeedActivityItem` sera câblé à Epic 9
- `weekSessionsRawStreamProvider` est distinct de `sessionsStreetIdsStreamProvider` (Story 3.1/3.2) — les deux coexistent car ils ont des query shapes différentes (sessions complètes vs streetIds seuls)

---

## Tests

**Fichiers :**
- `test/features/profile/providers/week_sessions_provider_test.dart` (nouveau — 9 cas)
- `test/features/profile/providers/sessions_list_provider_test.dart` (nouveau — 6 cas)

Cas couverts `weekStart` :
- Vendredi → lundi précédent
- Lundi → lui-même
- Dimanche → lundi de la semaine

Cas couverts `weekSessionsProvider` :
- uid null → Map vide
- Aucune session → Map vide
- Déduplication des streetIds par jour (Set union)
- Plusieurs jours distincts
- Session sans streetIds → aucune entrée créée (skip)

Cas couverts `selectedHistogramDayProvider` :
- Valeur par défaut null
- Mise à jour
- Toggle reset à null

Cas couverts `sessionsByDayProvider` :
- uid null → liste vide
- selectedDay null → toutes les sessions
- Filtre par jour sélectionné (sessions d'autres jours exclues)
- Aucune session le jour sélectionné → liste vide
- Sessions à minuit / fin de journée incluses correctement
- Réactivité (stream multi-émissions)

**Suite complète :** 228 tests ✅ — `flutter analyze` 0 issue ✅

---

## Tasks/Subtasks

- [x] Branche `epic-3/story-3.3-week-histogram-onglet-vous` créée depuis `develop`
- [x] `week_sessions_provider.dart` — `weekStart`, stream injectable, `weekSessionsProvider`, `selectedHistogramDayProvider`
- [x] `sessions_list_provider.dart` — stream injectable, `sessionsByDayProvider` filtré
- [x] `WeekHistogram` — 7 barres, Ocre aujourd'hui, fantôme vide, empty state, skeleton
- [x] `ProfileScreen` — header fixe, toggle vue, liste sorties, empty state
- [x] `app_router.dart` — route `/profile` branchée sur `ProfileScreen`
- [x] Tests unitaires (15 cas au total)
- [x] `flutter test` 228 ✅ — `flutter analyze` 0 issue ✅

## File List

- `urbink/lib/features/profile/providers/week_sessions_provider.dart` (nouveau)
- `urbink/lib/features/profile/providers/sessions_list_provider.dart` (nouveau)
- `urbink/lib/shared/widgets/week_histogram.dart` (nouveau)
- `urbink/lib/features/profile/screens/profile_screen.dart` (nouveau)
- `urbink/lib/core/router/app_router.dart` (modifié — import + route profil)
- `urbink/test/features/profile/providers/week_sessions_provider_test.dart` (nouveau)
- `urbink/test/features/profile/providers/sessions_list_provider_test.dart` (nouveau)

## Status

`done`

## Change Log

- 2026-04-24 : Implémentation Story 3.3 — WeekHistogram + onglet Vous (228 tests ✅)
- 2026-04-24 : Corrections review (PR#29) — nowProvider, autoDispose, .limit(100), normalisation selectedDay, abréviations FR, découplage toggle quartier
