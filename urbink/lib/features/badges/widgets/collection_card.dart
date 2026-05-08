import 'package:flutter/material.dart';
import 'package:urbink/features/badges/data/collection_model.dart';
import 'package:urbink/shared/constants/colors.dart';

// ---------------------------------------------------------------------------
// CollectionCard — carte collection dans BadgesScreen
// ---------------------------------------------------------------------------

class CollectionCard extends StatelessWidget {
  const CollectionCard({
    super.key,
    required this.collection,
    required this.onTap,
  });

  final MonumentCollection collection;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final stats = collection.stats;
    final isComplete = stats.pct == 100;
    final col = collection.color;
    final preview = collection.monuments.take(6).toList();

    return Semantics(
      label:
          'Collection ${collection.name}, ${stats.unlocked} sur ${stats.total} monuments débloqués, ${stats.pct}%',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: UrbinkColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: UrbinkColors.border),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 4,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Stripe gauche couleur de collection
                  Container(width: 4, color: col),

                  // Contenu
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header row : icône + titre + trophée + chevron
                          Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: col.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Center(
                                  child: Text(
                                    collection.icon,
                                    style: const TextStyle(fontSize: 24),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            collection.name,
                                            style: const TextStyle(
                                              fontFamily: 'CrimsonPro',
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: UrbinkColors.onSurface,
                                              letterSpacing: -0.3,
                                            ),
                                          ),
                                        ),
                                        if (isComplete)
                                          const Padding(
                                            padding:
                                                EdgeInsets.only(left: 4),
                                            child: Text('🏆',
                                                style:
                                                    TextStyle(fontSize: 14)),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      collection.subtitle,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: UrbinkColors.navInactive,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.chevron_right_rounded,
                                color: UrbinkColors.navInactive,
                                size: 20,
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // Mini-grille aperçu : 6 premiers monuments 32×32
                          Row(
                            children: [
                              for (final m in preview) ...[
                                _MiniTile(
                                  monument: m,
                                  collectionColor: col,
                                ),
                                const SizedBox(width: 4),
                              ],
                            ],
                          ),

                          const SizedBox(height: 10),

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
                                    minHeight: 5,
                                    backgroundColor: UrbinkColors.surfaceVariant,
                                    valueColor:
                                        AlwaysStoppedAnimation<Color>(col),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${stats.unlocked}/${stats.total}',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: col,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _MiniTile — tuile 32×32 dans l'aperçu de la card
// ---------------------------------------------------------------------------

class _MiniTile extends StatelessWidget {
  const _MiniTile({
    required this.monument,
    required this.collectionColor,
  });

  final CollectionMonument monument;
  final Color collectionColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: monument.locked
            ? UrbinkColors.surfaceVariant
            : collectionColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: ColorFiltered(
          colorFilter: monument.locked
              ? const ColorFilter.matrix([
                  0.2126, 0.7152, 0.0722, 0, 0,
                  0.2126, 0.7152, 0.0722, 0, 0,
                  0.2126, 0.7152, 0.0722, 0, 0,
                  0, 0, 0, 1, 0,
                ])
              : const ColorFilter.mode(Colors.transparent, BlendMode.dst),
          child: Opacity(
            opacity: monument.locked ? 0.4 : 1.0,
            child: Text(
              monument.emoji,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }
}
