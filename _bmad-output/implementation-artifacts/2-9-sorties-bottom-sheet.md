# Story 2.9 : Bottom sheet "Carte & Sorties" — DraggableScrollableSheet (FR1, FR1b)

Status: done

## Story

En tant qu'**utilisateur**,
Je veux accéder aux options de sortie (circuit libre ou itinéraire) en déroulant un panneau depuis l'écran Carte,
Afin de démarrer une sortie enregistrée ou lancer un itinéraire sans quitter la vue carte.

## Acceptance Criteria

- [x] **AC1 — DraggableScrollableSheet 3 snap points** : Given l'écran Carte affiché ; When l'utilisateur tire vers le haut depuis le bas de l'écran ; Then un `DraggableScrollableSheet` s'élève avec 3 snap points : 72px (collapsed — handle + hint "↑ Dérouler pour démarrer une sortie") / ~260px (peek — section Démarrer une sortie visible) / 65% écran (expanded — contenu complet).

- [x] **AC2 — Contenu peek/expanded** : Given le sheet en état peek ou expanded ; When la section "Démarrer une sortie" est visible ; Then deux cards côte à côte : "Circuit libre 🚶 · ✓ Par défaut" (fond Vert Sauge léger, bordure Vert Sauge) et "Itinéraire 🗺️ · Mode GPS →" (fond #F4F2ED) ; info-chip "🤖 Mode auto-détecté · GPS prêt" sous les cards ; bouton "▶ Démarrer la sortie" (fond Vert Sauge) lance la session.

- [x] **AC3 — Tap Itinéraire → vue liste** : Given l'utilisateur tape la card "Itinéraire" ; When la card est sélectionnée ; Then le sheet anime un sub-slide (AnimatedSwitcher) vers la vue liste d'itinéraires avec bouton "← Retour" et bouton "+ Créer" — pas de GoRouter push à cette étape ; seul le bouton "Créer" déclenche un push vers `/create-itineraire`.

- [x] **AC4 — Session active : sheet locked** : Given une session circuit libre active ; When elle est en cours ; Then le sheet est collapsed et non déroulable (IgnorePointer + animateTo minSize) — seuls la `SessionStatusBar` et le bouton Arrêter ■ sont accessibles.

## Tasks / Subtasks

- [x] **T1 — `SortiesBottomSheet`** (AC: 1, 2, 3, 4)
  - [x] `DraggableScrollableController` avec `LayoutBuilder` pour snap points dynamiques (72/parentH, 260/parentH, 0.65)
  - [x] `IgnorePointer(ignoring: isSessionActive)` + `ref.listen` → `animateTo(minSize)` quand session démarre
  - [x] `_SelectModeContent` : handle, hint, cards, chip GPS, bouton Démarrer
  - [x] `_ItinerairesListContent` : handle, ← Retour, + Créer, empty state
  - [x] `AnimatedSwitcher` + `SlideTransition` (Offset(1,0) → 0) entre les deux vues

- [x] **T2 — `MapScreen`** (AC: 1)
  - [x] Import + ajout `const SortiesBottomSheet()` dans le Stack
  - [x] `ZonesTogglePill` : `bottom: 16` → `bottom: 88` (72px sheet + 16px gap)

- [x] **T3 — `app_router.dart`** (AC: 3)
  - [x] `AppRoutes.createItineraire = '/create-itineraire'`
  - [x] `GoRoute` placeholder `_PlaceholderScreen(label: 'Créer un itinéraire')`

- [x] **T4 — Tests** (AC: 1, 2, 3, 4)
  - [x] AC1 : hint visible en état collapsed
  - [x] AC2 : cards + bouton Démarrer après drag
  - [x] AC3 : tap Itinéraire → vue liste ; tap Retour → retour vue select
  - [x] AC4 : session active masque hint/cards ; retour idle réaffiche

## Dev Notes

### Snap points dynamiques
Utilise `LayoutBuilder` pour obtenir `parentH` (hauteur du viewport Map, hors bottom nav) et calcule les fractions : `minSize = 72/parentH`, `peekSize = 260/parentH`, `maxSize = 0.65`. Plus précis que `MediaQuery.of(context).size.height` qui inclut la bottom nav.

### Lock session active
`IgnorePointer(ignoring: isSessionActive)` bloque toute interaction. `ref.listen<SessionState>` + `_controller.animateTo(minSize)` replie le sheet à 72px dès que la session démarre. `maxChildSize` reste à 0.65 (pas de rebuild forcé du sheet).

### GPS check
`_startSession()` dans `SortiesBottomSheet` duplique le check GPS de `app_router.dart` (`isServiceEnabled()` + `requestPermission()`). Coexiste avec le flow FAB existant jusqu'à Story 1.7 (nav v4).

### ZonesTogglePill
Repositionné à `bottom: 88` (= 72px sheet collapsed + 16px gap) pour rester visible au-dessus du sheet.

## Dev Agent Record

### Agent
Claude Sonnet 4.6

### Completion Notes
- 192/192 tests passent — aucune régression
- `flutter analyze --no-pub` : 0 issue

## File List

### New Files
- `urbink/lib/features/map/widgets/sorties_bottom_sheet.dart`
- `urbink/test/features/map/widgets/sorties_bottom_sheet_test.dart`

### Modified Files
- `urbink/lib/features/map/screens/map_screen.dart` — import + SortiesBottomSheet dans Stack + ZonesTogglePill bottom 16→88
- `urbink/lib/core/router/app_router.dart` — AppRoutes.createItineraire + GoRoute placeholder

## Change Log

| Date | Version | Description | Author |
|------|---------|-------------|--------|
| 2026-04-15 | 1.0 | Implémentation initiale Story 2.9 | Claude Sonnet 4.6 |
