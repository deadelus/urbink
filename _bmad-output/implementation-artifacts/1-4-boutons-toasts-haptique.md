# Story 1.4 : Hiérarchie des boutons + toasts + empty states + feedback haptique

## Story

En tant qu'**utilisateur**,
Je veux des retours visuels et haptiques clairs à chaque action,
Afin de savoir immédiatement si mon action a été prise en compte.

## Acceptance Criteria

**AC-1 :** UrbinkButton — variante Primary
- Given le widget `UrbinkButton` en variante `primary`
- When il est rendu
- Then fond Ocre #B8832E, texte blanc, hauteur 52pt, radius 12px, zone tactile min 52×52pt — état `isLoading: true` : spinner blanc inline, bouton non interactif

**AC-2 :** UrbinkButton — variante Destructive
- Given le widget `UrbinkButton` en variante `destructive`
- When il est affiché
- Then texte Rouge #C0392B sur fond transparent — jamais 2 boutons Primary sur le même écran

**AC-3 :** UrbinkSnackBar — 4 types
- Given `showUrbinkSnackBar()` appelé avec un type
- When une action se termine (succès/info/erreur/warning)
- Then un SnackBar flottant apparaît au-dessus de la nav, icône à gauche, durée 2.5s, fond selon type : success #2D5A2D · info #1E1610 · error #8B2020 · warning #7A5A1E — dismissable par swipe haut

**AC-4 :** Feedback haptique
- Given une action primaire (tap UrbinkButton primary)
- When elle se déclenche
- Then `HapticFeedback.heavyImpact()` est émis — secondary et destructive émettent `HapticFeedback.lightImpact()`

**AC-5 :** UrbinkEmptyState
- Given un contexte sans données
- When l'écran se charge vide
- Then `UrbinkEmptyState` affiche emoji 56px + titre ≤ 2 lignes + subtitle optionnel ≤ 2 lignes + CTA `UrbinkButton.primary` si `onCta` fourni — jamais écran blanc

## Tasks/Subtasks

- [x] **T1 — `shared/widgets/urbink_button.dart`**
  - [x] Enum `UrbinkButtonVariant` : primary / secondary / destructive
  - [x] `FilledButton` pour primary (Ocre bg, texte blanc, height 52, radius 12)
  - [x] `OutlinedButton` pour secondary (contour Ocre 1.5px, fond transparent)
  - [x] `TextButton` pour destructive (texte Rouge #C0392B, fond transparent)
  - [x] Paramètre `isLoading` : spinner `CircularProgressIndicator` inline, `onPressed: null`
  - [x] Paramètre `icon` optionnel : Row(Icon + SizedBox + Text)
  - [x] `_handlePress()` : `HapticFeedback.heavyImpact()` (primary) / `lightImpact()` (autres)

- [x] **T2 — `shared/widgets/urbink_snack_bar.dart`**
  - [x] Fonction `showUrbinkSnackBar()` avec `BuildContext`, `message`, `type`
  - [x] `ScaffoldMessenger` + `SnackBar` floating, `behavior: floating`, margin au-dessus nav
  - [x] `_UrbinkSnackBarContent` : Container coloré + Row(Icon + Text)
  - [x] `duration: 2500ms`, `dismissDirection: DismissDirection.up`
  - [x] 4 couleurs via `UrbinkColors.toast*` + 4 icônes Material outlined

- [x] **T3 — `shared/widgets/urbink_empty_state.dart`**
  - [x] Widget `UrbinkEmptyState` avec `emoji`, `title`, `subtitle?`, `ctaLabel?`, `onCta?`
  - [x] Text emoji 56px + titleMedium SemiBold + bodyMedium (2 lignes max chacun)
  - [x] CTA : `UrbinkButton.primary` conditionnel si `ctaLabel` et `onCta` fournis

## Dev Notes

### Variante Secondary non dans les ACs epics

La variante `secondary` (contour Ocre, fond transparent) est documentée dans `ux-design-specification.md` Pattern 1 mais absente des ACs epics. Implémentée car elle sera utilisée par les stories suivantes (ex: "Modifier itinéraire", "Voir le tracé").

### Haptique intégré dans UrbinkButton

Le feedback haptique est géré dans `_handlePress()` du widget plutôt que dans les screens. Avantage : cohérence garantie sans que chaque screen ait à gérer le haptique manuellement.

### SnackBar au-dessus de la nav

`SnackBarBehavior.floating` avec `margin.bottom: UrbinkSpacing.sm` positionne le SnackBar juste au-dessus de la bottom nav. La hauteur exacte dépend de la safe area — géré automatiquement par le `ScaffoldMessenger`.

## Dev Agent Record

### Implementation Plan
1. `UrbinkButton` — 3 variantes + loading + haptics
2. `showUrbinkSnackBar()` — 4 types, floating, swipe dismiss
3. `UrbinkEmptyState` — emoji + message + CTA conditionnel
4. `flutter analyze` zéro erreur
5. Artifact + commit + PR → develop

### Completion Notes
- T1 : `UrbinkButton` créé, 3 variantes + isLoading + icon optionnel + haptics
- T2 : `showUrbinkSnackBar()` créé, 4 types, floating au-dessus nav, swipe up dismiss
- T3 : `UrbinkEmptyState` créé, CTA conditionnel via `UrbinkButton.primary`

### Debug Log
(vide)

## File List

- `urbink/lib/shared/widgets/urbink_button.dart` — NOUVEAU
- `urbink/lib/shared/widgets/urbink_snack_bar.dart` — NOUVEAU
- `urbink/lib/shared/widgets/urbink_empty_state.dart` — NOUVEAU

## Change Log

| Date | Modification |
|------|-------------|
| 2026-04-08 | Implémentation initiale Story 1.4 — boutons, toasts, empty states, haptique |

## Status

done
