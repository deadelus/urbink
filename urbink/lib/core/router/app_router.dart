import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:urbink/features/map/screens/map_screen.dart';
import 'package:urbink/features/sessions/models/session.dart';
import 'package:urbink/features/sessions/providers/session_lifecycle_provider.dart';
import 'package:urbink/features/sessions/providers/session_metrics_provider.dart';
import 'package:urbink/features/sessions/screens/session_summary_screen.dart';
import 'package:urbink/features/sessions/session_state_provider.dart';
import 'package:urbink/shared/constants/colors.dart';
import 'package:urbink/shared/constants/spacing.dart';
import 'package:urbink/shared/widgets/session_status_bar.dart';
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
  static const String sessionSummary = '/session-summary';
}

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.map,
  routes: [
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
    GoRoute(
      path: AppRoutes.sessionSummary,
      redirect: (context, state) {
        if (state.extra is! Session) return AppRoutes.map;
        return null;
      },
      builder: (context, state) => SessionSummaryScreen(
        session: state.extra! as Session,
      ),
    ),
  ],
);

// ---------------------------------------------------------------------------
// Scaffold principal avec bottom nav + SessionStatusBar + bouton Arrêter
// ---------------------------------------------------------------------------

class _ScaffoldWithBottomNav extends ConsumerWidget {
  const _ScaffoldWithBottomNav({required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionState = ref.watch(sessionStateProvider);
    // S'assurer que SessionLifecycleNotifier est instancié dès que le scaffold
    // est monté — sans ce watch, le notifier n'est jamais construit et
    // _startSession() n'est jamais appelé lors du passage à active.
    ref.watch(sessionLifecycleProvider);
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    // Hauteur bottom nav Material 3 ≈ 56dp + safe area
    const bottomNavHeight = 56.0;

    return Scaffold(
      body: Stack(
        children: [
          navigationShell,
          // SessionStatusBar — barre Terra Cotta 44px top (sous safe area)
          Positioned(
            top: MediaQuery.of(context).padding.top,
            left: 0,
            right: 0,
            child: const SessionStatusBar(),
          ),
          // Bouton Arrêter ■ — bas-droite 52×52px, au-dessus de la bottom nav
          if (sessionState != SessionState.idle)
            Positioned(
              bottom: bottomPadding + bottomNavHeight + 16,
              right: 16,
              child: _StopSessionButton(
                onTap: () => _onStopTapped(context, ref),
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
            initialLocation: index == navigationShell.currentIndex,
          );
        },
      ),
    );
  }

  Future<void> _onStopTapped(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Arrêter la session ?'),
        content: const Text('Ta progression sera sauvegardée.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Continuer'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: UrbinkColors.destructive,
            ),
            child: const Text('Arrêter'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final metrics = ref.read(sessionMetricsProvider);
    final session = await ref
        .read(sessionLifecycleProvider.notifier)
        .stopAndSave(metrics);

    if (!context.mounted) return;
    ref.read(sessionStateProvider.notifier).state = SessionState.idle;

    if (session != null) {
      context.push(AppRoutes.sessionSummary, extra: session);
    }
  }
}

// ---------------------------------------------------------------------------
// Bouton Arrêter session — carré 52×52px bas-droite
// ---------------------------------------------------------------------------

class _StopSessionButton extends StatelessWidget {
  const _StopSessionButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Arrêter la session',
      button: true,
      explicitChildNodes: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: UrbinkColors.destructive,
            boxShadow: [
              BoxShadow(
                color: UrbinkColors.destructive.withValues(alpha: 0.35),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.stop_rounded, color: Colors.white, size: 26),
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
              child: const Text('Démarrer la sortie'),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Écran placeholder
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
