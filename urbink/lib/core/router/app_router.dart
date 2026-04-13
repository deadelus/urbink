import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:urbink/features/map/screens/map_screen.dart';
import 'package:urbink/features/sessions/session_state_provider.dart';
import 'package:urbink/shared/constants/colors.dart';
import 'package:urbink/shared/constants/spacing.dart';
import 'package:urbink/shared/widgets/transport_mode_selector.dart';
import 'package:urbink/shared/widgets/urbink_bottom_nav.dart';
import 'package:urbink/shared/widgets/urbink_bottom_sheet.dart';

// Routes nommées — éviter les chaînes magiques dans le code
abstract final class AppRoutes {
  static const String home = '/';
  static const String map = '/map';
  static const String start = '/start';
  static const String challenges = '/challenges';
  static const String profile = '/profile';
}

final GoRouter appRouter = GoRouter(
  // La carte est l'écran principal — ouvrir directement sur l'onglet Carte.
  // Conformément à l'UX spec : "Carte comme écran principal permanent".
  initialLocation: AppRoutes.map,
  routes: [
    // StatefulShellRoute préserve le Navigator (et donc l'état de scroll)
    // de chaque onglet indépendamment — conformité AC Story 1.3 "mémorise sa position".
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          _ScaffoldWithBottomNav(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.home,
              pageBuilder: (context, state) => const NoTransitionPage(
                child: _PlaceholderScreen(label: 'Accueil'),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.map,
              pageBuilder: (context, state) => const NoTransitionPage(
                child: MapScreen(),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.start,
              pageBuilder: (context, state) => const NoTransitionPage(
                child: _PlaceholderScreen(label: 'Démarrer'),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.challenges,
              pageBuilder: (context, state) => const NoTransitionPage(
                child: _PlaceholderScreen(label: 'Challenges'),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.profile,
              pageBuilder: (context, state) => const NoTransitionPage(
                child: _PlaceholderScreen(label: 'Vous'),
              ),
            ),
          ],
        ),
      ],
    ),
  ],
);

// ---------------------------------------------------------------------------
// Scaffold principal avec bottom nav + bouton Arrêter session (top-right)
// ---------------------------------------------------------------------------

class _ScaffoldWithBottomNav extends ConsumerWidget {
  const _ScaffoldWithBottomNav({required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionState = ref.watch(sessionStateProvider);
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      body: Stack(
        children: [
          navigationShell,
          // Bouton Arrêter — visible pendant une session active ou en pause
          if (sessionState != SessionState.idle)
            Positioned(
              top: topPadding + 12,
              right: 16,
              child: _StopSessionButton(
                onTap: () {
                  // Arrêt UI de la session — reset du provider.
                  // Modale de confirmation + sauvegarde Firestore + écran récapitulatif
                  // implémentés en Story 2.5 (cycle de vie complet de la session GPS).
                  ref.read(sessionStateProvider.notifier).state = SessionState.idle;
                },
              ),
            ),
        ],
      ),
      bottomNavigationBar: UrbinkBottomNav(
        currentIndex: navigationShell.currentIndex,
        sessionState: sessionState,
        onTabSelected: (index) async {
          if (index == 2) {
            final current = ref.read(sessionStateProvider);
            if (current == SessionState.idle) {
              // Première mise en route : afficher la sélection de mode avant de démarrer
              if (!context.mounted) return;
              final confirmed = await showUrbinkBottomSheet<bool>(
                context: context,
                child: const _StartSessionSheet(),
              );
              if (confirmed == true && context.mounted) {
                ref.read(sessionStateProvider.notifier).state =
                    SessionState.active;
                navigationShell.goBranch(
                  index,
                  initialLocation: index == navigationShell.currentIndex,
                );
              }
              return;
            }
            // Session active/pause — bascule sans bottom sheet
            ref.read(sessionStateProvider.notifier).state =
                current == SessionState.active
                    ? SessionState.paused
                    : SessionState.active;
            navigationShell.goBranch(
              index,
              initialLocation: index == navigationShell.currentIndex,
            );
            return;
          }
          navigationShell.goBranch(
            index,
            // Retap sur l'onglet actif → retour à la route initiale (scroll to top UX)
            initialLocation: index == navigationShell.currentIndex,
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Bouton Arrêter session — cercle rouge top-right
// ---------------------------------------------------------------------------

class _StopSessionButton extends StatelessWidget {
  const _StopSessionButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Arrêter la session',
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: UrbinkColors.destructive,
            boxShadow: [
              BoxShadow(
                color: UrbinkColors.destructive.withValues(alpha: 0.30),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Icon(Icons.stop_rounded, color: Colors.white, size: 22),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Bottom sheet sélection du mode de transport avant de démarrer une session
// ---------------------------------------------------------------------------

class _StartSessionSheet extends StatelessWidget {
  const _StartSessionSheet();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(UrbinkSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Mode de déplacement',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: UrbinkSpacing.md),
          const Center(child: TransportModeSelector()),
          const SizedBox(height: UrbinkSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: UrbinkColors.secondary,
                foregroundColor: Colors.white,
                minimumSize: const Size(
                  double.infinity,
                  UrbinkSpacing.minTapTarget,
                ),
              ),
              child: const Text('Démarrer la session'),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Écran placeholder (remplacé feature par feature dans les stories suivantes)
// ---------------------------------------------------------------------------

class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Center(
        child: Text(
          label,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      );
}
