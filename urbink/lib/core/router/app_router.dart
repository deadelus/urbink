import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:urbink/features/sessions/session_active_provider.dart';
import 'package:urbink/shared/constants/colors.dart';
import 'package:urbink/shared/widgets/urbink_bottom_nav.dart';

// Routes nommées — éviter les chaînes magiques dans le code
abstract final class AppRoutes {
  static const String home = '/';
  static const String map = '/map';
  static const String start = '/start';
  static const String challenges = '/challenges';
  static const String profile = '/profile';
}

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.home,
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
                child: _PlaceholderScreen(label: 'Carte'),
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
        onTabSelected: (index) {
          if (index == 2) {
            // Bouton Démarrer/Pause — navigue vers /start ET bascule l'état de session
            navigationShell.goBranch(
              index,
              // Retap sur l'onglet actif → retour à la route initiale (scroll to top UX)
              initialLocation: index == navigationShell.currentIndex,
            );
            final current = ref.read(sessionStateProvider);
            ref.read(sessionStateProvider.notifier).state =
                current == SessionState.active ? SessionState.paused : SessionState.active;
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
