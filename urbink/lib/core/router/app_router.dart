import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:urbink/features/map/screens/map_screen.dart';
import 'package:urbink/features/onboarding/screens/privacy_screen.dart';
import 'package:urbink/features/sessions/models/session.dart';
import 'package:urbink/features/sessions/providers/gps_tracking_provider.dart';
import 'package:urbink/features/sessions/providers/session_lifecycle_provider.dart';
import 'package:urbink/features/sessions/providers/session_metrics_provider.dart';
import 'package:urbink/features/sessions/screens/session_summary_screen.dart';
import 'package:urbink/features/sessions/session_state_provider.dart';
import 'package:urbink/shared/constants/colors.dart';
import 'package:urbink/shared/constants/spacing.dart';
import 'package:urbink/shared/widgets/gps_required_dialog.dart';
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
  static const String onboarding = '/onboarding';
  static const String createItineraire = '/create-itineraire';
}

// ---------------------------------------------------------------------------
// Notifier de politique de confidentialité — pilote le redirect GoRouter.
// Initialisé depuis main() avant runApp().
// ---------------------------------------------------------------------------

class PrivacyNotifier extends ChangeNotifier {
  bool _accepted;
  PrivacyNotifier({required bool accepted}) : _accepted = accepted;

  bool get accepted => _accepted;

  void setAccepted() {
    if (_accepted) return;
    _accepted = true;
    notifyListeners();
  }
}

/// Instance module-level partagée entre main.dart et PrivacyScreen.
final privacyNotifier = PrivacyNotifier(accepted: false);

/// Clé SharedPreferences pour le consentement — source unique de vérité.
const kPrivacyAcceptedKey = 'urbink_privacy_accepted';

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.map,
  refreshListenable: privacyNotifier,
  redirect: (context, state) {
    final onOnboarding = state.matchedLocation == AppRoutes.onboarding;
    if (!privacyNotifier.accepted && !onOnboarding) return AppRoutes.onboarding;
    if (privacyNotifier.accepted && onOnboarding) return AppRoutes.map;
    return null;
  },
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
    GoRoute(
      path: AppRoutes.onboarding,
      builder: (context, state) => const PrivacyScreen(),
    ),
    GoRoute(
      path: AppRoutes.createItineraire,
      builder: (context, state) => const _CreateItineraireScreen(),
    ),
  ],
);

// ---------------------------------------------------------------------------
// Dialog GPS refusé
// ---------------------------------------------------------------------------


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
                // Vérifier le service + la permission GPS avant de démarrer
                final gpsService = ref.read(gpsTrackingServiceProvider);
                final serviceEnabled = await gpsService.isServiceEnabled();
                if (!context.mounted) return;
                if (!serviceEnabled) {
                  showGpsRequiredDialog(context);
                  return;
                }
                final granted = await gpsService.requestPermission();
                if (!context.mounted) return;
                if (!granted) {
                  showGpsRequiredDialog(context);
                  return;
                }
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
// Écran Créer un itinéraire — carte + panneau bas (placeholder Story 2.9)
// ---------------------------------------------------------------------------

class _CreateItineraireScreen extends StatelessWidget {
  const _CreateItineraireScreen();

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    // MapScreen possède son propre Scaffold — on évite le nesting en
    // enveloppant dans Material+Stack plutôt qu'un Scaffold parent.
    return Material(
      color: Colors.transparent,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Carte complète en arrière-plan (Scaffold géré par MapScreen)
          const MapScreen(),
          // Bouton ← Retour flottant (au-dessus safe area)
          Positioned(
            top: topPadding + 8,
            left: 8,
            child: Material(
              color: Colors.transparent,
              child: IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.92),
                  foregroundColor: UrbinkColors.onSurface,
                ),
              ),
            ),
          ),
          // Panneau bas — placeholder création itinéraire
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                UrbinkSpacing.md,
                UrbinkSpacing.md,
                UrbinkSpacing.md,
                UrbinkSpacing.md + bottomPadding,
              ),
              decoration: const BoxDecoration(
                color: UrbinkColors.surface,
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(16)),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x18000000),
                    blurRadius: 16,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Créer un itinéraire',
                    style:
                        Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: UrbinkColors.onSurface,
                            ),
                  ),
                  const SizedBox(height: UrbinkSpacing.xs),
                  Text(
                    'Trace ton parcours sur la carte.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: UrbinkColors.navInactive,
                        ),
                  ),
                ],
              ),
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
