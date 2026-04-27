# Implementation Artifact — Story 4.3

## Story
Epic 4 · Story 4.3 — Composant CelebrationOverlay — animations de célébration

## ACs implémentés

- [x] Given un badge monument débloqué / When `CelebrationOverlay` est déclenché en état `badge` / Then overlay plein écran : fond semi-transparent, icône scale-in 300ms (ou fade 150ms si reduceMotion), particules dorées, titre du badge, dismissable par tap
- [x] Given un quartier complété / When `CelebrationOverlay` est déclenché en état `district` / Then durée auto-dismiss 5s avec countdown, secret local révélé, bouton Partager + Continuer
- [x] Given "Réduire les animations" iOS activé / When `CelebrationOverlay` se déclenche / Then animations remplacées par fade 150ms, `SemanticsService.sendAnnouncement` annonce le texte de célébration à VoiceOver
- [x] Given plusieurs badges débloqués dans la même session / When ils se déclenchent en séquence / Then `CelebrationQueueNotifier` les affiche un par un via `CelebrationQueueListener`

## Tasks / Subtasks

- [x] Créer `CelebrationEvent` model + `CelebrationMode` enum
- [x] Créer `CelebrationQueueNotifier` (Notifier<List<CelebrationEvent>>) avec push/pop + déduplication par id
- [x] Créer `CelebrationOverlay` widget unifié (badge + district), animations staggered, accessibility, auto-dismiss district
- [x] Créer `CelebrationQueueListener` (ConsumerStatefulWidget) avec `addPostFrameCallback` pour éviter showGeneralDialog pendant build
- [x] Brancher `CelebrationQueueListener` dans `app_router.dart` autour du shell
- [x] Migrer `MapScreen._handleQuartierCompleted` : supprimer `_isCelebrating`, push vers queue
- [x] Migrer `SessionEndFlow.show()` : ajouter `WidgetRef ref` + `onNavigate?`, push badges vers queue
- [x] Mettre à jour `SortiesBottomSheet` pour passer `ref`
- [x] Tests : 14 nouveaux tests (provider, overlay, queue listener, session end flow)
- [x] `flutter analyze --no-pub` → 0 erreur

## Dev Notes

**Architecture queue** : `celebrationQueueProvider` (Notifier<List<CelebrationEvent>>) est la source de vérité. `CelebrationQueueListener` est placé une seule fois dans le shell router — il écoute la queue et affiche séquentiellement via `showGeneralDialog` (useRootNavigator: true).

**addPostFrameCallback** : nécessaire dans `CelebrationQueueListener.ref.listen` pour éviter de pousser une route Navigator pendant la phase de build Riverpod.

**showCelebrationOverlay** : pop le dialog via `Navigator.of(ctx, rootNavigator: true).pop()` dans le `onDone` wrapper avant d'appeler le callback de la queue.

**SessionEndFlow.onNavigate** : paramètre optionnel pour remplacer `context.go()` — permet les tests sans GoRouter.

**Lottie** : package installé (`lottie: ^3.2.0`) mais aucun fichier d'animation fourni. Les particules utilisent `GoldenParticles` (emoji custom Flutter) pour les deux modes. La couche Lottie est prête à être branchée quand les assets design seront disponibles.

**Anciens widgets conservés** : `BadgeCelebration`, `QuartierCelebrationOverlay`, `CelebrationParticles` restent dans le codebase mais ne sont plus utilisés pour les nouveaux déclencheurs. Peuvent être supprimés en Story 4.4+.

## File List

**Nouveaux :**
- `urbink/lib/features/gamification/models/celebration_event.dart`
- `urbink/lib/features/gamification/providers/celebration_queue_provider.dart`
- `urbink/lib/features/gamification/widgets/celebration_overlay.dart`
- `urbink/lib/features/gamification/widgets/celebration_queue_listener.dart`
- `urbink/test/features/gamification/providers/celebration_queue_provider_test.dart`
- `urbink/test/features/gamification/widgets/celebration_overlay_test.dart`

**Modifiés :**
- `urbink/lib/core/router/app_router.dart`
- `urbink/lib/features/map/screens/map_screen.dart`
- `urbink/lib/features/session_end/controllers/session_end_flow.dart`
- `urbink/lib/features/map/widgets/sorties_bottom_sheet.dart`
- `urbink/test/features/session_end/session_end_flow_test.dart`

## Dev Agent Record

- Tests baseline : 335 → final : 349 (+14)
- `flutter analyze --no-pub` : 0 erreur, 0 warning
- `flutter test` : 349/349 ✅

## Status

`done`
