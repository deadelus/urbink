# Story 3.3 : Composant WeekHistogram + onglet Vous (historique personnel)

## Story

En tant qu'**utilisateur**,
Je veux voir un résumé visuel de mon activité hebdomadaire et la liste de mes sorties,
Afin de suivre mes habitudes d'exploration dans l'onglet Vous.

## Acceptance Criteria

**AC-1 :** WeekHistogram — 7 barres L-D
- Given l'onglet Vous ouvert
- When l'écran se charge
- Then `WeekHistogram` affiche 7 barres L-D, hauteur proportionnelle aux rues explorées ce jour — le jour actuel en Ocre #B8832E, jours sans activité en barre fantôme #F0EDE8 (UX-DR6)

**AC-2 :** État `empty` — aucune session cette semaine
- Given `WeekHistogram` en état `empty` (aucune session cette semaine)
- When il est affiché
- Then toutes les barres sont fantômes et un message "Ta première sortie cette semaine n'attend que toi" s'affiche avec CTA "Démarrer"

**AC-3 :** Toggle Vue simple / Vue feed
- Given l'écran Vous sous le WeekHistogram
- When il affiche la liste des sorties
- Then un toggle "Vue simple / Vue feed" est visible — Vue simple : `ListTile` compact (date · rues · km · durée) ; Vue feed : `FeedActivityItem` avec tracé miniature (à activer à l'Epic 9)

**AC-4 :** Filtre par jour sur tap
- Given une barre du `WeekHistogram` tapée
- When l'utilisateur tape sur un jour
- Then la liste des sorties est filtrée pour afficher uniquement les sessions de ce jour

## Tasks/Subtasks

- [x] **T1 — Couleurs**
  - [x] `UrbinkColors.histogramOcre` (#B8832E) — barre jour courant
  - [x] `UrbinkColors.histogramGhost` (#F0EDE8) — barre fantôme jour sans activité

- [x] **T2 — `SessionLocalCache.getSessionsForWeek()`**
  - [x] Méthode qui retourne toutes les sessions complètes (session_end IS NOT NULL) d'un userId pour une plage 7 jours

- [x] **T3 — `lib/features/profile/models/day_stats.dart`**
  - [x] Classe `DayStats` : date, streetCount, distanceKm, totalDuration, sessions
  - [x] `DayStats.empty(date)` factory

- [x] **T4 — `lib/features/profile/providers/week_histogram_provider.dart`**
  - [x] `startOfWeek(DateTime)` — utilitaire pur (testable)
  - [x] `WeekHistogramNotifier extends AsyncNotifier<List<DayStats>>`
  - [x] Agrégation des rues uniques (union des streetIds) par jour
  - [x] `weekHistogramProvider`

- [x] **T5 — `lib/features/profile/widgets/week_histogram.dart`**
  - [x] 7 barres animées (AnimatedContainer 200ms), hauteur proportionnelle
  - [x] Barre fantôme = ghost color + hauteur minimale 6px
  - [x] Barre avec activité = min 10px, max 72px, proportionnel
  - [x] Jour courant = Ocre ; autres jours actifs = primary
  - [x] Tap → `onDayTapped(index)` ; re-tap même barre → `onDayTapped(null)` (désélectionne)
  - [x] Semantics pour accessibilité VoiceOver

- [x] **T6 — `lib/features/profile/screens/profile_screen.dart`**
  - [x] En-tête "Vous" + carte "Cette semaine" + WeekHistogram
  - [x] État empty → message + CTA "Démarrer" (navigue vers /map)
  - [x] Toggle `_ViewToggle` : Vue simple / Vue feed (animé 150ms)
  - [x] Liste sessions : `_buildSessionTile` compact (date · rues · km · durée · emoji mode)
  - [x] Filtre par jour sélectionné ; "Aucune sortie ce jour-là" si vide
  - [x] Vue feed : même rendu Vue simple (FeedActivityItem à activer Epic 9)

- [x] **T7 — `lib/core/router/app_router.dart`**
  - [x] Branche 4 : `_PlaceholderScreen('Profil')` → `ProfileScreen()`

- [x] **T8 — Tests**
  - [x] `test/features/profile/models/day_stats_test.dart`
  - [x] `test/features/profile/providers/week_histogram_provider_test.dart` (`startOfWeek`)
  - [x] `test/features/profile/widgets/week_histogram_test.dart`

## Dev Notes

### Limitation : sessions locales seulement

`getSessionsForWeek()` interroge uniquement le cache sqflite. Les sessions
synchronisées depuis Firestore sur un autre appareil ne sont pas visibles.
Pour le MVP, c'est acceptable — toutes les sessions transitent d'abord par sqflite.

### Vue feed — hors scope Epic 3

Le toggle "Vue feed" est affiché et sélectionnable, mais rend le même contenu que
"Vue simple". Le composant `FeedActivityItem` avec tracé miniature est réservé à
l'Epic 9. Aucune dette technique : le point d'accroche est dans `_buildSessionTile`.

### `startOfWeek()` — ISO week (lundi = jour 1)

Dart's `DateTime.weekday` : 1=Lun, 7=Dim. La fonction `startOfWeek(date)` soustrait
`date.weekday - 1` jours pour obtenir le lundi de la semaine ISO.

### `weekHistogramProvider` — dépendance uid

`ref.watch(currentUidProvider)` est appelé AVANT tout `await` pour que Riverpod
enregistre la dépendance synchroniquement. Si uid est null (utilisateur non connecté),
le provider retourne une semaine vide.

### Hauteur des barres

- Barres vides (isEmpty) : 6px ghost
- Barres actives : `max(10px, streetCount / maxStreets × 72px)`
- Si `maxStreets == 0` : toutes à 6px ghost

## Dev Agent Record

### Implementation Plan
1. Ajouter couleurs histogramOcre + histogramGhost dans UrbinkColors
2. Ajouter getSessionsForWeek() à SessionLocalCache
3. Créer DayStats model
4. Créer WeekHistogramNotifier + weekHistogramProvider
5. Créer WeekHistogram widget (7 barres animées, tappable)
6. Créer ProfileScreen (histogram + liste + toggle + filtre)
7. Brancher ProfileScreen dans le router
8. Tests + flutter analyze

### Completion Notes
- T1 : 2 couleurs ajoutées dans UrbinkColors
- T2 : getSessionsForWeek() ajouté à SessionLocalCache
- T3 : DayStats créé avec factory empty()
- T4 : WeekHistogramNotifier + startOfWeek() créés
- T5 : WeekHistogram widget avec AnimatedContainer, Semantics, tap toggle
- T6 : ProfileScreen avec CustomScrollView + _EmptyWeekState + _ViewToggle + _Chip
- T7 : Router branché sur ProfileScreen
- T8 : 13 tests écrits, 223 tests passent au total

### Debug Log
- `error: (_, __) => ...` → lint `unnecessary_underscores` — corrigé en `error: (err, stack) => ...`

## File List

- `urbink/lib/shared/constants/colors.dart` — MODIFIÉ (histogramOcre, histogramGhost)
- `urbink/lib/features/sessions/services/session_local_cache.dart` — MODIFIÉ (getSessionsForWeek)
- `urbink/lib/features/profile/models/day_stats.dart` — NOUVEAU
- `urbink/lib/features/profile/providers/week_histogram_provider.dart` — NOUVEAU
- `urbink/lib/features/profile/widgets/week_histogram.dart` — NOUVEAU
- `urbink/lib/features/profile/screens/profile_screen.dart` — NOUVEAU
- `urbink/lib/core/router/app_router.dart` — MODIFIÉ (ProfileScreen remplace placeholder)
- `urbink/test/features/profile/models/day_stats_test.dart` — NOUVEAU
- `urbink/test/features/profile/providers/week_histogram_provider_test.dart` — NOUVEAU
- `urbink/test/features/profile/widgets/week_histogram_test.dart` — NOUVEAU

## Change Log

| Date | Modification |
|------|-------------|
| 2026-04-24 | Implémentation initiale Story 3.3 — WeekHistogram + onglet Vous |

## Status

done
