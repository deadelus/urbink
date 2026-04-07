import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
    ShellRoute(
      builder: (context, state, child) => _ScaffoldWithBottomNav(child: child),
      routes: [
        GoRoute(
          path: AppRoutes.home,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: _PlaceholderScreen(label: 'Accueil'),
          ),
        ),
        GoRoute(
          path: AppRoutes.map,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: _PlaceholderScreen(label: 'Carte'),
          ),
        ),
        GoRoute(
          path: AppRoutes.start,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: _PlaceholderScreen(label: 'Démarrer'),
          ),
        ),
        GoRoute(
          path: AppRoutes.challenges,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: _PlaceholderScreen(label: 'Challenges'),
          ),
        ),
        GoRoute(
          path: AppRoutes.profile,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: _PlaceholderScreen(label: 'Vous'),
          ),
        ),
      ],
    ),
  ],
);

class _ScaffoldWithBottomNav extends StatelessWidget {
  const _ScaffoldWithBottomNav({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final String location =
        GoRouterState.of(context).uri.toString();

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _locationToIndex(location),
        onDestinationSelected: (index) =>
            context.go(_indexToRoute(index)),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Accueil',
          ),
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map),
            label: 'Carte',
          ),
          NavigationDestination(
            icon: Icon(Icons.play_circle_outline),
            selectedIcon: Icon(Icons.play_circle),
            label: 'Démarrer',
          ),
          NavigationDestination(
            icon: Icon(Icons.emoji_events_outlined),
            selectedIcon: Icon(Icons.emoji_events),
            label: 'Challenges',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Vous',
          ),
        ],
      ),
    );
  }

  static int _locationToIndex(String location) {
    if (location.startsWith(AppRoutes.map)) return 1;
    if (location.startsWith(AppRoutes.start)) return 2;
    if (location.startsWith(AppRoutes.challenges)) return 3;
    if (location.startsWith(AppRoutes.profile)) return 4;
    return 0;
  }

  static String _indexToRoute(int index) {
    const routes = [
      AppRoutes.home,
      AppRoutes.map,
      AppRoutes.start,
      AppRoutes.challenges,
      AppRoutes.profile,
    ];
    return routes[index];
  }
}

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
