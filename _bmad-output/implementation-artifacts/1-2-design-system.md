# Story 1.2 : Design system Material 3 + tokens Urbink

## Story

En tant que **développeur**,
Je veux un design system complet avec les tokens Urbink appliqués à Material 3,
Afin que tous les composants de l'app aient une apparence cohérente sans duplication de code.

## Acceptance Criteria

**AC-1 :** `shared/constants/colors.dart`
- Given le fichier `shared/constants/colors.dart`
- When un widget utilise `Theme.of(context).colorScheme`
- Then la palette Urbink est active : primary = Ocre #B8832E, secondary = Vert Sauge #5A7A5A, surface = #FAFAF7, onSurface = #1E1610 — aucun hex codé en dur dans les widgets

**AC-2 :** `shared/constants/typography.dart`
- Given le fichier `shared/constants/typography.dart`
- When un widget utilise `Theme.of(context).textTheme`
- Then Crimson Pro est la police display/heading, Inter est la police body — Dynamic Type iOS respecté (MediaQuery.textScaleFactor honoré)

**AC-3 :** `shared/constants/spacing.dart`
- Given le fichier `shared/constants/spacing.dart`
- When un widget utilise les constantes d'espacement
- Then la grille 8px est appliquée : space-xs=4, space-sm=8, space-md=16, space-lg=24, space-xl=32, space-2xl=48

**AC-4 :** ThemeData Material 3
- Given le ThemeData Material 3 configuré
- When l'app se lance
- Then `useMaterial3: true` est actif, les border-radius des composants correspondent aux specs UX (boutons 12px, cards 16px, chips 8px), et le thème passe les tests de rendu golden en mode clair

## Tasks/Subtasks

- [x] **T1 — Extraire ThemeData vers `shared/theme/app_theme.dart`**
  - [x] Créer `lib/shared/theme/app_theme.dart` avec `AppTheme.light()` factory
  - [x] Mettre à jour `main.dart` pour importer et utiliser `AppTheme.light()`
  - [x] Vérifier : `useMaterial3: true`, ColorScheme, TextTheme, button/card/chip radius

- [x] **T2 — Déclarer les fonts custom dans pubspec.yaml**
  - [x] Créer le répertoire `assets/fonts/`
  - [x] Déclarer CrimsonPro (Regular, SemiBold, Italic) et Inter (Regular, Medium, SemiBold) dans pubspec.yaml
  - [x] Documenter l'emplacement des fichiers TTF à télécharger

- [x] **T3 — Tests unitaires tokens (AC-1, AC-2, AC-3)**
  - [x] `test/shared/constants/colors_test.dart` — vérifier les valeurs hex de la palette
  - [x] `test/shared/constants/spacing_test.dart` — vérifier la grille 8px et border-radius
  - [x] `test/shared/constants/typography_test.dart` — vérifier les family names et font sizes

- [x] **T4 — Tests thème Material 3 (AC-4)**
  - [x] `test/shared/theme/app_theme_test.dart` — vérifier useMaterial3, colorScheme, textTheme, border-radius

## Dev Notes

### Architecture
- Le ThemeData doit vivre dans `shared/theme/app_theme.dart`, PAS dans `main.dart`
- Utilise `AppTheme.light()` comme factory statique pour permettre les tests sans context
- Les fonts doivent être déclarées dans pubspec.yaml avec les fichiers TTF dans `assets/fonts/`

### Fonts
- CrimsonPro : Google Fonts — télécharger depuis https://fonts.google.com/specimen/Crimson+Pro
  - `CrimsonPro-Regular.ttf`, `CrimsonPro-SemiBold.ttf`, `CrimsonPro-Italic.ttf`
- Inter : Google Fonts — télécharger depuis https://fonts.google.com/specimen/Inter
  - `Inter-Regular.ttf`, `Inter-Medium.ttf`, `Inter-SemiBold.ttf`

### Tests Golden
- Tests de propriétés thème (colorScheme, textTheme, radius) = tests de propriétés plutôt que pixel-perfect
- Les tests sont exécutés sans polices réelles (fallback système) — la vérification se fait sur les family names déclarés

## Dev Agent Record

### Implementation Plan
- Extraire ThemeData de main.dart → app_theme.dart
- Configurer pubspec.yaml + structure assets/fonts/
- Écrire tests unitaires complets pour les 3 AC de tokens
- Écrire tests widget pour le thème Material 3

### Completion Notes
- T1 : `AppTheme.light()` créé dans `shared/theme/app_theme.dart`, `main.dart` mis à jour
- T2 : Structure `assets/fonts/` créée, pubspec.yaml mis à jour avec déclarations fonts
- T3 : Tests unitaires écrits et passants pour colors, spacing, typography
- T4 : Tests widget écrits et passants pour le ThemeData Material 3

### Debug Log
(vide)

## File List

- `urbink/lib/shared/theme/app_theme.dart` — NOUVEAU
- `urbink/lib/main.dart` — MODIFIÉ
- `urbink/pubspec.yaml` — MODIFIÉ
- `urbink/assets/fonts/README.md` — NOUVEAU
- `urbink/test/shared/constants/colors_test.dart` — NOUVEAU
- `urbink/test/shared/constants/spacing_test.dart` — NOUVEAU
- `urbink/test/shared/constants/typography_test.dart` — NOUVEAU
- `urbink/test/shared/theme/app_theme_test.dart` — NOUVEAU

## Change Log

| Date | Modification |
|------|-------------|
| 2026-04-08 | Implémentation initiale Story 1.2 — design system M3 + tokens Urbink |

## Status

done
