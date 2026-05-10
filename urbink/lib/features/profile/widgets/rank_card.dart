import 'package:flutter/material.dart';
import 'package:urbink/features/profile/data/explorer_rank.dart';
import 'package:urbink/features/profile/widgets/gem_widget.dart';
import 'package:urbink/l10n/app_localizations.dart';
import 'package:urbink/shared/constants/colors.dart';

// ---------------------------------------------------------------------------
// RankCard — carte de rang dans ProfilScreen (light theme)
// ---------------------------------------------------------------------------

class RankCard extends StatelessWidget {
  const RankCard({
    super.key,
    required this.rank,
    required this.currentXp,
  });

  final ExplorerRank rank;
  final int currentXp;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final progress = rank.progressTo(currentXp);
    final xpIn = rank.xpInRank(currentXp);
    final needed = rank.xpNeeded;
    final nextRank = rank.xpNext != null && rank.index + 1 < kExplorerRanks.length
        ? kExplorerRanks[rank.index + 1]
        : null;

    return Container(
      decoration: BoxDecoration(
        color: UrbinkColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: UrbinkColors.border),
        boxShadow: const [
          BoxShadow(color: Color(0x06000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          // Halo teinté (top-right)
          Positioned(
            top: -30,
            right: -30,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    rank.haloColor.withValues(alpha: 0.10),
                    rank.haloColor.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Row : gem + infos
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GemWidget(rank: rank, size: 72),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.rank_explorer_label,
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.5,
                              color: UrbinkColors.navInactive,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            rank.name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: UrbinkColors.onSurface,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.rank_monuments_count(currentXp),
                            style: const TextStyle(
                              fontSize: 11,
                              color: UrbinkColors.navInactive,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: UrbinkColors.navInactive,
                    ),
                  ],
                ),

                // Barre XP (uniquement si pas rang max)
                if (nextRank != null) ...[
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.rank_toward_next(nextRank.name),
                        style: const TextStyle(
                          fontSize: 11,
                          color: UrbinkColors.navInactive,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '$xpIn / ${needed ?? 0}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: UrbinkColors.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 5,
                      backgroundColor: UrbinkColors.surfaceVariant,
                      valueColor: AlwaysStoppedAnimation<Color>(rank.haloColor),
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: 10),
                  Text(
                    l10n.rank_max_reached,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: rank.haloColor,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
