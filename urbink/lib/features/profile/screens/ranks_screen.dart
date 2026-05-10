import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urbink/features/profile/data/explorer_rank.dart';
import 'package:urbink/features/profile/providers/explorer_rank_provider.dart';
import 'package:urbink/features/profile/widgets/gem_widget.dart';
import 'package:urbink/l10n/app_localizations.dart';
import 'package:urbink/shared/constants/colors.dart';
import 'package:urbink/shared/constants/spacing.dart';

// ---------------------------------------------------------------------------
// RanksScreen — liste des 11 rangs avec hero rang actuel
// ---------------------------------------------------------------------------

class RanksScreen extends ConsumerWidget {
  const RanksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rank = ref.watch(explorerRankProvider);
    final xp = ref.watch(explorerXpProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: UrbinkColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: UrbinkColors.background,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            toolbarHeight: 64,
            automaticallyImplyLeading: false,
            title: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: UrbinkColors.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: UrbinkColors.border),
                    ),
                    child: const Icon(
                      Icons.chevron_left_rounded,
                      color: UrbinkColors.onSurface,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: UrbinkSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.ranks_screen_title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: UrbinkColors.onSurface,
                          letterSpacing: -.3,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.ranks_screen_subtitle,
                        style: const TextStyle(
                          fontSize: 11,
                          color: UrbinkColors.navInactive,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            bottom: const PreferredSize(
              preferredSize: Size.fromHeight(1),
              child: Divider(height: 1),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: UrbinkSpacing.sm),
              child: _RanksHero(rank: rank, currentXp: xp),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              UrbinkSpacing.md,
              UrbinkSpacing.lg,
              UrbinkSpacing.md,
              UrbinkSpacing.sm,
            ),
            sliver: SliverToBoxAdapter(
              child: Row(
                children: [
                  Text(
                    l10n.rank_all_label.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                      color: UrbinkColors.navInactive,
                    ),
                  ),
                  const SizedBox(width: UrbinkSpacing.sm),
                  const Expanded(child: Divider()),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              UrbinkSpacing.md,
              0,
              UrbinkSpacing.md,
              100,
            ),
            sliver: SliverList.separated(
              itemCount: kExplorerRanks.length,
              separatorBuilder: (_, _) => const SizedBox(height: 6),
              itemBuilder: (ctx, i) {
                final r = kExplorerRanks[i];
                final status = i < rank.index
                    ? _RankStatus.reached
                    : i == rank.index
                        ? _RankStatus.current
                        : _RankStatus.locked;
                return _RankRow(rank: r, status: status);
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _RanksHero — rang actuel en grand
// ---------------------------------------------------------------------------

class _RanksHero extends StatelessWidget {
  const _RanksHero({required this.rank, required this.currentXp});

  final ExplorerRank rank;
  final int currentXp;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final xpInRank = rank.xpInRank(currentXp);
    final needed = rank.xpNeeded;
    final nextRank = rank.xpNext != null && rank.index + 1 < kExplorerRanks.length
        ? kExplorerRanks[rank.index + 1]
        : null;
    final progress = rank.progressTo(currentXp);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: UrbinkSpacing.md),
      decoration: BoxDecoration(
        color: UrbinkColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: UrbinkColors.border),
        boxShadow: const [
          BoxShadow(color: Color(0x08000000), blurRadius: 8, offset: Offset(0, 1)),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    rank.haloColor.withValues(alpha: 0.14),
                    rank.haloColor.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 22, 18, 18),
            child: Column(
              children: [
                Text(
                  l10n.rank_hero_label(rank.index + 1, kExplorerRanks.length),
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                    color: UrbinkColors.navInactive,
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: rank.haloColor.withValues(alpha: 0.35),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: GemWidget(rank: rank, size: 120),
                ),
                const SizedBox(height: 14),
                Text(
                  rank.name,
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w700,
                    color: UrbinkColors.onSurface,
                    letterSpacing: -.5,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  rank.description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    color: UrbinkColors.navInactive,
                    height: 1.4,
                    letterSpacing: .2,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  l10n.rank_monuments_count(currentXp),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: UrbinkColors.navInactive,
                  ),
                ),
                if (nextRank != null) ...[
                  const SizedBox(height: 18),
                  const Divider(),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text(
                        l10n.rank_next_label,
                        style: const TextStyle(
                          fontSize: 11,
                          color: UrbinkColors.navInactive,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        nextRank.name,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: nextRank.haloColor,
                          letterSpacing: .2,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '$xpInRank',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: UrbinkColors.onSurface,
                        ),
                      ),
                      Text(
                        ' / ${needed ?? 0}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: UrbinkColors.navInactive,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: SizedBox(
                      height: 6,
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: UrbinkColors.surfaceVariant,
                        valueColor: AlwaysStoppedAnimation<Color>(rank.haloColor),
                      ),
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

// ---------------------------------------------------------------------------
// _RankRow — ligne dans la timeline des 11 rangs
// ---------------------------------------------------------------------------

enum _RankStatus { reached, current, locked }

class _RankRow extends StatelessWidget {
  const _RankRow({required this.rank, required this.status});

  final ExplorerRank rank;
  final _RankStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isCurrent = status == _RankStatus.current;
    final isReached = status != _RankStatus.locked;
    final isLegendary = rank.id == 'legendaire';

    Widget gemContent = GemWidget(rank: rank, size: 42);
    if (!isReached) {
      gemContent = Opacity(
        opacity: 0.55,
        child: ColorFiltered(
          colorFilter: const ColorFilter.matrix([
            0.2126, 0.7152, 0.0722, 0, 0,
            0.2126, 0.7152, 0.0722, 0, 0,
            0.2126, 0.7152, 0.0722, 0, 0,
            0, 0, 0, 1, 0,
          ]),
          child: GemWidget(rank: rank, size: 42),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isCurrent ? rank.haloColor.withValues(alpha: 0.06) : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isCurrent ? rank.haloColor.withValues(alpha: 0.4) : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: isReached
                  ? rank.haloColor.withValues(alpha: 0.08)
                  : UrbinkColors.surfaceVariant,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isCurrent ? rank.haloColor : UrbinkColors.border,
                width: isCurrent ? 1.5 : 1.0,
              ),
              boxShadow: isCurrent
                  ? [
                      BoxShadow(
                        color: rank.haloColor.withValues(alpha: 0.35),
                        blurRadius: 14,
                      ),
                    ]
                  : null,
            ),
            child: Center(child: gemContent),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  children: [
                    Text(
                      (rank.index + 1).toString().padLeft(2, '0'),
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: UrbinkColors.navInactive,
                        letterSpacing: 1,
                      ),
                    ),
                    Text(
                      rank.name,
                      style: TextStyle(
                        fontSize: isLegendary ? 20 : 18,
                        fontWeight: FontWeight.w700,
                        color: isReached ? UrbinkColors.onSurface : UrbinkColors.navInactive,
                        letterSpacing: -.2,
                        height: 1,
                      ),
                    ),
                    if (isCurrent)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: rank.haloColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          l10n.rank_you_are_here,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                            color: rank.haloColor,
                          ),
                        ),
                      ),
                    if (isLegendary)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFF7E0), Color(0xFFF4E4B0)],
                          ),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0x44D4A642)),
                        ),
                        child: const Text(
                          'Mythique',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                            color: Color(0xFF8A6E2E),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  rank.description,
                  style: const TextStyle(
                    fontSize: 11,
                    color: UrbinkColors.navInactive,
                    height: 1.35,
                    letterSpacing: .1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  rank.xpMin == 0
                      ? l10n.rank_threshold_start
                      : l10n.rank_threshold_from(rank.xpMin),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: isReached ? FontWeight.w600 : FontWeight.w400,
                    color: isReached ? UrbinkColors.onSurface : UrbinkColors.navInactive,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          if (status == _RankStatus.reached)
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(color: rank.haloColor, shape: BoxShape.circle),
              child: const Icon(Icons.check_rounded, size: 13, color: Colors.white),
            )
          else if (status == _RankStatus.locked)
            const Icon(
              Icons.lock_rounded,
              size: 14,
              color: UrbinkColors.navInactive,
            ),
        ],
      ),
    );
  }
}
