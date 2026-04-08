# Story 1.3 : Bottom navigation 5 onglets + bottom sheets conformes UX

## Story

En tant qu'**utilisateur**,
Je veux naviguer entre les 5 sections de l'app via une navigation claire en bas d'écran,
Afin d'accéder rapidement à toutes les fonctionnalités depuis n'importe quel écran.

## Acceptance Criteria

**AC-1 :** Bottom nav 5 onglets — structure et élévation
- Given l'app lancée
- When l'utilisateur regarde le bas de l'écran
- Then la bottom nav affiche 5 onglets : Accueil 🏠 · Carte 🗺️ · Démarrer ▶ · Challenges 🏆 · Vous 👤 — le bouton Démarrer est central, surélevé de 12px avec ombre Material 3

**AC-2 :** États des onglets — sélectionné / inactif
- Given un onglet sélectionné
- When l'utilisateur tape dessus
- Then l'icône et le label passent en Ocre #B8832E avec un underline 2px animé (150ms) — les autres onglets restent en #8C7B6A

**AC-3 :** Préservation d'état par onglet
- Given l'état de chaque onglet
- When l'utilisateur navigue entre onglets puis revient
- Then chaque onglet mémorise sa position de scroll et son état — `StatefulShellRoute.indexedStack` assure un Navigator dédié par branche

**AC-4 :** Bottom sheet — snap, pill, scrim, accessibilité
- Given un bottom sheet déclenché via `showUrbinkBottomSheet()`
- When il s'élève depuis le bas
- Then il snape à 40% (aperçu) ou 70% (détail), affiche une pill de drag 4×32px en #D4C8B4, un scrim #1E1610 à 40%, et se ferme par swipe bas ou tap sur le scrim — `Semantics(scopesRoute: true)` piège le focus VoiceOver à l'intérieur

**AC-5 :** États visuels du bouton Démarrer
- Given aucune session active
- When l'utilisateur tape le bouton Démarrer
- Then le bouton passe en Vert Sauge #5A7A5A avec icône ⏸, et un bouton Arrêter rouge #C0392B 44px apparaît en haut à droite

**AC-6 :** Pause session
- Given une session active
- When l'utilisateur tape le bouton ⏸ (pause central)
- Then le bouton repasse en Ocre #B8832E avec icône ▶ — le bouton Arrêter reste visible

**AC-7 :** Arrêt session UI
- Given une session active ou en pause
- When l'utilisateur tape le bouton Arrêter (top right)
- Then la session s'arrête côté UI : bouton Démarrer → Vert Sauge ▶, bouton Arrêter disparaît — modale de confirmation + sauvegarde Firestore + écran récapitulatif implémentés en Story 2.5

**AC-8 :** Semantics VoiceOver bottom nav
- Given VoiceOver iOS activé
- When l'utilisateur navigue dans la bottom nav
- Then chaque onglet annonce : "Accueil, onglet 1 sur 5" / "Carte, onglet 2 sur 5" / "Démarrer, onglet 3 sur 5" etc. — bouton Pause annonce "Pause session, onglet 3 sur 5", bouton Arrêter annonce "Arrêter la session"

## Tasks/Subtasks

- [x] **T1 — `shared/widgets/urbink_bottom_nav.dart`**
  - [x] Widget `UrbinkBottomNav` stateless avec `currentIndex`, `onTabSelected`, `isSessionActive`
  - [x] Bouton Démarrer central : `Stack` + `Positioned`, surélevé 12px, double `BoxShadow` M3
  - [x] 4 onglets normaux : icône + label + underline 2px `AnimatedContainer` 150ms
  - [x] `_StartButton` : `AnimatedContainer` couleur + `AnimatedSwitcher` icône (200ms)
  - [x] Safe areas : `MediaQuery.of(context).padding.bottom` sur toute la hauteur
  - [x] Semantics VoiceOver sur chaque item (`excludeSemantics: true`, `label`, `selected`)

- [x] **T2 — `shared/widgets/urbink_bottom_sheet.dart`**
  - [x] Fonction `showUrbinkBottomSheet<T>()` avec paramètre `initialSnap` (0.4 / 0.7)
  - [x] `DraggableScrollableSheet` avec `snap: true`, `snapSizes: [0.4, 0.7]`
  - [x] Pill de drag 4×32px en `UrbinkColors.sheetDragPill` (#D4C8B4)
  - [x] Scrim via `barrierColor: UrbinkColors.sheetScrim.withValues(alpha: 0.40)`
  - [x] `Semantics(scopesRoute: true)` pour piéger le focus VoiceOver

- [x] **T3 — `core/router/app_router.dart`**
  - [x] Migrer `ShellRoute` → `StatefulShellRoute.indexedStack` (5 branches)
  - [x] `_ScaffoldWithBottomNav` → `ConsumerWidget` (Riverpod)
  - [x] Tap index 2 → bascule `sessionActiveProvider` (pas de navigation)
  - [x] `_StopSessionButton` rouge top-right : `Positioned` conditionnel sur `isSessionActive`
  - [x] Retap onglet actif → `goBranch(initialLocation: true)` (scroll to top UX)

- [x] **T4 — `features/sessions/session_active_provider.dart`**
  - [x] `StateProvider<bool>` nommé `sessionActiveProvider`, documenté pour extension Epic 2

- [x] **T5 — Docs produit**
  - [x] `epics.md` : ACs Story 1.3 précisés + Story 2.5 enrichie (lien bouton Arrêter → récapitulatif)
  - [x] `ux-design-specification.md` : 5 sections mises à jour (initiation, D3, Pattern 1, Pattern 4, VoiceOver)
  - [x] `ux-design-directions.html` : CSS + D3 phones + D7 anatomy mis à jour (Vert Sauge repos / Ocre pause / rouge Arrêter)

## Dev Notes

### Décision : pas de modale de confirmation en Story 1.3

La modale "Arrêter la session ?" et l'écran récapitulatif sont reportés en **Story 2.5** car :
- Sans GPS tracké, une confirmation ne protège aucune donnée réelle
- La modale sera branchée sur la sauvegarde Firestore (Story 2.5) — construire une version vide maintenant = double implémentation
- Le bouton Arrêter reset le `StateProvider<bool>` — comportement correct pour le MVP navigation

### Architecture `StatefulShellRoute`

`StatefulShellRoute.indexedStack` crée un `Navigator` dédié par branche. Chaque onglet conserve sa pile de routes et sa position de scroll de manière indépendante. Le retap sur l'onglet actif appelle `goBranch(initialLocation: true)` pour revenir à la route racine de la branche (pattern "scroll to top").

### `sessionActiveProvider` — point d'extension Epic 2

Le provider est volontairement minimal (`StateProvider<bool>`). En Story 2.5 il sera remplacé par un `AsyncNotifierProvider<SessionState>` complet (GPS, Firestore, sqflite). Le bouton Arrêter dans `app_router.dart` appelle déjà `ref.read(sessionActiveProvider.notifier).state = false` — le point d'accroche pour la logique de sauvegarde est commenté dans le code.

### Couleurs bouton Démarrer

| État | Couleur | Icône |
|------|---------|-------|
| Repos (aucune session) | Vert Sauge `#5A7A5A` | ▶ play |
| Session active | Ocre `#B8832E` | ⏸ pause |

### Safe areas iOS

La hauteur totale du `UrbinkBottomNav` = `64 + bottomPadding + 12` (élévation). Le scaffold Urbink n'a pas d'AppBar — le bouton Arrêter est positionné avec `top: MediaQuery.padding.top + 12` pour respecter la Dynamic Island et le notch.

## Dev Agent Record

### Implementation Plan
1. Créer `UrbinkBottomNav` avec Stack + Positioned pour le bouton surélevé
2. Créer `showUrbinkBottomSheet()` avec `DraggableScrollableSheet`
3. Migrer `app_router.dart` vers `StatefulShellRoute.indexedStack` + `ConsumerWidget`
4. Créer `sessionActiveProvider` dans `features/sessions/`
5. Mettre à jour epics.md, ux-design-specification.md, ux-design-directions.html

### Completion Notes
- T1 : `UrbinkBottomNav` créé — `AnimatedContainer`/`AnimatedSwitcher` pour transitions couleur/icône
- T2 : `showUrbinkBottomSheet()` créé — `DraggableScrollableSheet` snap 40%/70%
- T3 : Router migré vers `StatefulShellRoute`, scaffold → `ConsumerWidget`
- T4 : `sessionActiveProvider` créé, documenté pour extension Story 2.5
- T5 : 3 docs produit mis à jour en cohérence avec l'implémentation

### Debug Log
- `Semantics(modal: true)` n'existe pas dans Flutter → remplacé par `Semantics(scopesRoute: true)` qui délimite la portée de navigation accessibilité au bottom sheet

## File List

- `urbink/lib/shared/widgets/urbink_bottom_nav.dart` — NOUVEAU
- `urbink/lib/shared/widgets/urbink_bottom_sheet.dart` — NOUVEAU
- `urbink/lib/core/router/app_router.dart` — MODIFIÉ (ShellRoute → StatefulShellRoute, ConsumerWidget, bouton Arrêter)
- `urbink/lib/features/sessions/session_active_provider.dart` — NOUVEAU
- `_bmad-output/planning-artifacts/epics.md` — MODIFIÉ (ACs Story 1.3 + Story 2.5)
- `_bmad-output/planning-artifacts/ux-design-specification.md` — MODIFIÉ (5 sections)
- `_bmad-output/planning-artifacts/ux-design-directions.html` — MODIFIÉ (CSS + D3 + D7)

## Change Log

| Date | Modification |
|------|-------------|
| 2026-04-08 | Implémentation initiale Story 1.3 — bottom nav + bottom sheets + états session UI |

## Status

done
