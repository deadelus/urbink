import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:urbink/features/badges/screens/badges_screen.dart';
import 'package:urbink/features/gamification/widgets/celebration_queue_listener.dart';
import 'package:urbink/features/map/providers/streets_visible_provider.dart';
import 'package:urbink/features/map/screens/filters_screen.dart';
import 'package:urbink/features/map/screens/map_screen.dart';
import 'package:urbink/features/map/widgets/itineraire_bottom_sheet.dart';
import 'package:urbink/features/onboarding/screens/privacy_screen.dart';
import 'package:urbink/features/profile/screens/profile_screen.dart';
import 'package:urbink/features/sessions/models/session.dart';
import 'package:urbink/features/sessions/providers/session_lifecycle_provider.dart';
import 'package:urbink/features/sessions/screens/session_summary_screen.dart';
import 'package:urbink/features/sessions/session_state_provider.dart';
import 'package:urbink/shared/constants/colors.dart';
import 'package:urbink/shared/constants/spacing.dart';
import 'package:urbink/shared/widgets/filter_chips_row.dart';
import 'package:urbink/shared/widgets/time_filter_select.dart';
import 'package:urbink/shared/widgets/urbink_bottom_nav.dart';
import 'package:urbink/shared/widgets/zones_toggle_pill.dart';

// Routes nommées — éviter les chaînes magiques dans le code
abstract final class AppRoutes {
  static const String map = '/map';
  static const String parcours = '/parcours';
  static const String social = '/social';
  static const String badges = '/badges';
  static const String profile = '/profile';
  static const String sessionSummary = '/session-summary';
  static const String onboarding = '/onboarding';
  static const String createItineraire = '/create-itineraire';
  static const String filters = '/filters';
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
          CelebrationQueueListener(
            child: _ScaffoldWithBottomNav(navigationShell: navigationShell),
          ),
      branches: [
        // 0 — Carte (hub principal)
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
        // 1 — Parcours
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.parcours,
              pageBuilder: (context, state) => const NoTransitionPage(
                child: _PlaceholderScreen(label: 'Parcours'),
              ),
            ),
          ],
        ),
        // 2 — Social
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.social,
              pageBuilder: (context, state) => const NoTransitionPage(
                child: _PlaceholderScreen(label: 'Social'),
              ),
            ),
          ],
        ),
        // 3 — Challenges (onglet Badges)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.badges,
              pageBuilder: (context, state) => const NoTransitionPage(
                child: BadgesScreen(),
              ),
            ),
          ],
        ),
        // 4 — Profil
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.profile,
              pageBuilder: (context, state) => const NoTransitionPage(
                child: ProfileScreen(),
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
      pageBuilder: (context, state) => const NoTransitionPage(
        child: _CreateItineraireScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.filters,
      builder: (context, state) => const FiltersScreen(),
    ),
  ],
);

// ---------------------------------------------------------------------------
// Dialog GPS refusé
// ---------------------------------------------------------------------------


// ---------------------------------------------------------------------------
// Scaffold principal avec bottom nav
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

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: UrbinkBottomNav(
        currentIndex: navigationShell.currentIndex,
        sessionState: sessionState,
        onTabSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Écran Créer un itinéraire — carte + panneau bas (placeholder Story 2.9)
// ---------------------------------------------------------------------------

class _CreateItineraireScreen extends ConsumerWidget {
  const _CreateItineraireScreen();

  static const _tabRoutes = [
    AppRoutes.map,
    AppRoutes.parcours,
    AppRoutes.social,
    AppRoutes.badges,
    AppRoutes.profile,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topPadding = MediaQuery.of(context).padding.top;
    final sessionState = ref.watch(sessionStateProvider);
    final streetsVisible = ref.watch(streetsVisibleProvider);

    return Scaffold(
      bottomNavigationBar: UrbinkBottomNav(
        currentIndex: 0,
        sessionState: sessionState,
        onTabSelected: (i) => context.go(_tabRoutes[i]),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Carte complète — bottom UI géré par ce screen
          const MapScreen(hideSearchBar: true, showBottomUi: false),

          // Top bar — 3 niveaux : titre/retour · recherche · filtres
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: UrbinkColors.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Niveau 1 — retour + titre
                  SizedBox(height: topPadding + 4),
                  SizedBox(
                    height: 44,
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => context.pop(),
                          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                          color: UrbinkColors.onSurface,
                        ),
                        const Expanded(
                          child: Text(
                            'Créer un itinéraire',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: UrbinkColors.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Niveau 2 — barre de recherche
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: UrbinkSpacing.md),
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: UrbinkColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(UrbinkSpacing.radiusChip),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.07),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Row(
                        children: [
                          SizedBox(width: 12),
                          Icon(Icons.search_rounded,
                              color: UrbinkColors.navInactive, size: 18),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Rechercher un lieu…',
                              style: TextStyle(
                                fontSize: 14,
                                color: UrbinkColors.navInactive,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Niveau 3 — filtres
                  const SizedBox(height: UrbinkSpacing.sm),
                  FilterChipsRow(
                    padding: const EdgeInsets.symmetric(horizontal: UrbinkSpacing.md),
                    onMoreTap: () => context.push(AppRoutes.filters),
                  ),
                  const SizedBox(height: UrbinkSpacing.sm),
                ],
              ),
            ),
          ),

          // Pill "Zones explorées" + filtre temporel
          Positioned(
            left: UrbinkSpacing.md,
            bottom: ItineraireBottomSheet.collapsedHeight + UrbinkSpacing.md,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const ZonesTogglePill(),
                if (streetsVisible) ...[
                  const SizedBox(width: UrbinkSpacing.sm),
                  const TimeFilterSelect(),
                ],
              ],
            ),
          ),

          // Bottom sheet itinéraire
          const ItineraireBottomSheet(),
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
