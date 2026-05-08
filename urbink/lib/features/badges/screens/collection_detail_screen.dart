import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:urbink/core/router/app_router.dart';
import 'package:urbink/features/badges/data/collection_model.dart';
import 'package:urbink/features/badges/screens/monument_detail_sheet.dart';
import 'package:urbink/features/badges/widgets/monument_tile.dart';
import 'package:urbink/l10n/app_localizations.dart';
import 'package:urbink/shared/constants/colors.dart';

// ---------------------------------------------------------------------------
// CollectionDetailScreen — overlay plein écran (fadeIn 200ms)
// Poussé via Navigator.of(context, rootNavigator: true).push pour passer
// au-dessus de la BottomNav.
// ---------------------------------------------------------------------------

class CollectionDetailScreen extends StatelessWidget {
  const CollectionDetailScreen({super.key, required this.collection});

  final MonumentCollection collection;

  static void _showMonumentDetail(
    BuildContext context, {
    required CollectionMonument monument,
    required MonumentCollection collection,
  }) {
    // Capture navigator + router AVANT toute navigation (contexte stable).
    final rootNav = Navigator.of(context, rootNavigator: true);
    final router = GoRouter.of(context);
    MonumentDetailSheet.show(
      context,
      monument: monument,
      collection: collection,
      onShowOnMap: () {
        rootNav.pop(); // ferme l'overlay collection
        router.go(AppRoutes.map); // navigue vers l'onglet Carte
      },
    );
  }

  static Future<void> show(
    BuildContext context,
    MonumentCollection collection,
  ) {
    return Navigator.of(context, rootNavigator: true).push(
      PageRouteBuilder<void>(
        opaque: false,
        barrierColor: Colors.black54,
        transitionDuration: const Duration(milliseconds: 200),
        pageBuilder: (_, _, _) =>
            CollectionDetailScreen(collection: collection),
        transitionsBuilder: (_, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final stats = collection.stats;
    final col = collection.color;
    final isComplete = stats.pct == 100;

    return Scaffold(
      backgroundColor: UrbinkColors.background,
      body: Column(
        children: [
          // ── Header coloré avec gradient ──────────────────────────────────
          _CollectionHeader(collection: collection, stats: stats),

          // ── Body scrollable ───────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Banner "Collection complète"
                  if (isComplete)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: col.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        '🏆 ${AppLocalizations.of(context).badges_collection_complete}',
                        style: TextStyle(
                          fontFamily: 'CrimsonPro',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: col,
                        ),
                      ),
                    ),

                  // Grille 3 colonnes
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: collection.monuments.length,
                      itemBuilder: (_, index) {
                        final monument = collection.monuments[index];
                        return MonumentTile(
                          monument: monument,
                          collectionColor: col,
                          onTap: () => _showMonumentDetail(
                            context,
                            monument: monument,
                            collection: collection,
                          ),
                        );
                      },
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
// _CollectionHeader — gradient + barre de progression
// ---------------------------------------------------------------------------

class _CollectionHeader extends StatelessWidget {
  const _CollectionHeader({
    required this.collection,
    required this.stats,
  });

  final MonumentCollection collection;
  final CollectionStats stats;

  @override
  Widget build(BuildContext context) {
    final col = collection.color;
    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [col, col.withValues(alpha: 0.87)],
        ),
      ),
      child: Stack(
        children: [
          // Cercles décoratifs
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            left: 40,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // Contenu header
          Padding(
            padding: EdgeInsets.fromLTRB(16, topPadding + 8, 16, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Bouton retour
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.arrow_back_ios_new_rounded,
                          color: Colors.white, size: 16),
                      SizedBox(width: 4),
                      Text(
                        'Retour',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Icône + titre + sous-titre
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.40),
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          collection.icon,
                          style: const TextStyle(fontSize: 32),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            collection.name,
                            style: const TextStyle(
                              fontFamily: 'CrimsonPro',
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            collection.subtitle,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.85),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Barre de progression
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: stats.total > 0
                              ? stats.unlocked / stats.total
                              : 0,
                          minHeight: 6,
                          backgroundColor:
                              Colors.white.withValues(alpha: 0.20),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '${stats.unlocked}/${stats.total} · ${stats.pct}%',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
