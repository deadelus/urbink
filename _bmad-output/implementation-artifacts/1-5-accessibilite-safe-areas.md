# Story 1.5 : Accessibilité WCAG 2.1 AA + safe areas iOS

## Story

En tant qu'**utilisateur ayant des besoins d'accessibilité**,
Je veux que l'app soit utilisable avec VoiceOver et respecte les réglages d'accessibilité iOS,
Afin de pouvoir explorer la ville sans barrière.

## Acceptance Criteria

- [x] **AC1 — VoiceOver Semantics** : chaque bouton, onglet et card a un `Semantics` Flutter avec `label` explicite en français. Les onglets annoncent "Accueil, onglet 1 sur 5", le bouton central annonce son état (Démarrer / Pause session / Reprendre session / Arrêter la session).
- [x] **AC2 — Réduire les animations** : quand `MediaQuery.of(context).disableAnimations` est `true`, l'underline des onglets utilise `AnimatedOpacity` (fade 150ms) au lieu de `AnimatedContainer` (width), et l'`AnimatedContainer` du bouton central passe à `duration: Duration.zero`. L'`AnimatedSwitcher` utilise un `FadeTransition` explicite.
- [x] **AC3 — Dynamic Type xxxLarge** : le `textScaler` est capé à 1.3x pour les labels de navigation (espace fixe ~60px), aucun overflow vertical. Les styles utilisent `Theme.of(context).textTheme.labelSmall` sans `fontSize` hardcodé. `maxLines: 1, overflow: TextOverflow.ellipsis` sur les labels.
- [x] **AC4 — Touch targets ≥ 44×44pt** : bouton Démarrer 56×56, bouton Arrêter 44×44, `UrbinkButton` minimumSize 44×52, onglets `HitTestBehavior.opaque` sur toute la hauteur (~60px).
- [x] **AC5 — Safe areas iOS** : `MediaQuery.of(context).padding.bottom` utilisé dans `UrbinkBottomNav` et `_UrbinkSheetContent`. `MediaQuery.of(context).padding.top` utilisé pour le bouton Arrêter dans `_ScaffoldWithBottomNav`.

## Tasks / Subtasks

- [x] Lire tous les widgets existants (bottom_nav, bottom_sheet, button, app_router, theme)
- [x] AC1 : vérifier les Semantics existants → déjà conformes, aucun changement nécessaire
- [x] AC2 : ajouter `disableAnimations` dans `_buildTab` → `AnimatedOpacity` vs `AnimatedContainer`
- [x] AC2 : ajouter `disableAnimations` dans `_StartButton` → `colorDuration` + `iconDuration` + `FadeTransition`
- [x] AC3 : supprimer `fontSize: 11` du `copyWith`, ajouter `maxLines: 1, overflow: TextOverflow.ellipsis`
- [x] AC3 : wrapper `Column` avec `MediaQuery(textScaler: clamp(max: 1.3x))` pour éviter l'overflow vertical
- [x] AC3 : supprimer import `typography.dart` devenu inutile
- [x] AC4 : vérifier conformité → déjà conforme, aucun changement
- [x] AC5 : vérifier conformité → déjà conforme, aucun changement
- [x] Écrire 17 tests unitaires couvrant AC1→AC5
- [x] Corriger test pré-existant `urbink_empty_state_test.dart` cassé par l'assert Copilot
- [x] `flutter test` : 102/102 ✓
- [x] `flutter analyze --no-pub` : 0 issue ✓

## Dev Notes

**textScaler cap à 1.3x** : WCAG 2.1 AA autorise de ne pas scaler les éléments de navigation UI compacts. La nav bar a une hauteur fixe (~60px) insuffisante pour absorber un scale 3×. Le cap à 1.3× est un compromis conforme : les utilisateurs avec Dynamic Type voient un texte légèrement plus grand sans overflow.

**Animations reduce motion** : `AnimatedSwitcher` utilise déjà un `FadeTransition` par défaut, mais on l'explicite pour la clarté et la conformité. La couleur du bouton central passe à `Duration.zero` (instantané) ce qui correspond au comportement attendu sous "Réduire les animations".

**Import typography supprimé** : `_buildTab` utilisait la constante `UrbinkTypography.bodyFamily` dans un fallback. En passant uniquement par `textTheme.labelSmall`, le fallback devient inutile.

**Test `urbink_empty_state_test.dart` corrigé** : le test "pas de CTA si ctaLabel absent" passait `onCta` sans `ctaLabel`, déclenchant l'`assert` ajouté lors de la review Copilot PR#4. Corrigé pour tester le cas conforme (les deux null).

## Dev Agent Record

- Agent : Claude Sonnet 4.6
- Date : 2026-04-08
- Branche : `epic-1/story-1.5-accessibilite-safe-areas`
- Tests : 17 nouveaux + 1 correctif (102 total, tous ✓)

## File List

### Modifiés
- `urbink/lib/shared/widgets/urbink_bottom_nav.dart` — disableAnimations + textScaler cap + fontSize fix + import supprimé

### Créés
- `urbink/test/shared/widgets/urbink_bottom_nav_test.dart` — 17 tests (AC1→AC5)

### Correctifs tests
- `urbink/test/shared/widgets/urbink_empty_state_test.dart` — test "pas de CTA" aligné avec l'assert Copilot

## Change Log

| Version | Date | Auteur | Description |
|---------|------|--------|-------------|
| 1.0 | 2026-04-08 | Claude Sonnet 4.6 | Implémentation initiale Story 1.5 |

## Status

done
