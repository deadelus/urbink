import 'package:flutter/material.dart';
import 'package:urbink/features/profile/data/explorer_rank.dart';
import 'package:urbink/features/profile/widgets/gem_widget.dart';
import 'package:urbink/l10n/app_localizations.dart';
import 'package:urbink/shared/constants/colors.dart';

// ---------------------------------------------------------------------------
// RankPreviewStrip — scroll horizontal des 11 rangs
// ---------------------------------------------------------------------------

class RankPreviewStrip extends StatelessWidget {
  const RankPreviewStrip({super.key, required this.currentRank});

  final ExplorerRank currentRank;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                l10n.rank_all_label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: UrbinkColors.onSurface,
                ),
              ),
              Text(
                l10n.rank_position(currentRank.index + 1, kExplorerRanks.length),
                style: const TextStyle(
                  fontSize: 11,
                  color: UrbinkColors.navInactive,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: kExplorerRanks.map((rank) {
              final reached = rank.index <= currentRank.index;
              final isCurrent = rank.index == currentRank.index;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Opacity(
                  opacity: reached ? 1.0 : 0.5,
                  child: Column(
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: isCurrent
                              ? rank.haloColor.withValues(alpha: 0.10)
                              : reached
                                  ? UrbinkColors.surface
                                  : UrbinkColors.surfaceVariant,
                          border: Border.all(
                            color: isCurrent ? rank.haloColor : UrbinkColors.border,
                            width: isCurrent ? 1.5 : 1.0,
                          ),
                        ),
                        child: Center(
                          child: GemWidget(rank: rank, size: 42),
                        ),
                      ),
                      const SizedBox(height: 4),
                      SizedBox(
                        width: 54,
                        child: Text(
                          rank.name,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                            color: isCurrent ? rank.haloColor : UrbinkColors.navInactive,
                            letterSpacing: 0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
