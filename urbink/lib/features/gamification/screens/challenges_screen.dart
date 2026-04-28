import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urbink/features/gamification/models/quartier_badge.dart';
import 'package:urbink/features/gamification/models/quartier_progression.dart';
import 'package:urbink/features/gamification/providers/badgeable_monuments_provider.dart';
import 'package:urbink/features/gamification/providers/monument_badges_provider.dart';
import 'package:urbink/features/gamification/providers/quartier_badges_provider.dart';
import 'package:urbink/features/gamification/providers/quartiers_progression_provider.dart';
import 'package:urbink/features/gamification/widgets/badge_grid.dart';
import 'package:urbink/l10n/app_localizations.dart';
import 'package:urbink/shared/constants/colors.dart';
import 'package:urbink/shared/constants/spacing.dart';

const _kGold = Color(0xFFF59E0B);
const _kGoldLight = Color(0xFFFEF3C7);
const _kGoldBorder = Color(0xFFFDE68A);

class ChallengesScreen extends ConsumerWidget {
  const ChallengesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressionAsync = ref.watch(quartiersProgressionProvider);
    final badgesAsync = ref.watch(quartierBadgesStreamProvider);
    final monumentsAsync = ref.watch(badgeableMonumentsProvider);
    final monumentBadgesAsync = ref.watch(monumentBadgesStreamProvider);

    return Scaffold(
      backgroundColor: UrbinkColors.background,
      body: CustomScrollView(
        slivers: [
          const SliverAppBar(
            title: Text('Challenges'),
            backgroundColor: UrbinkColors.surface,
            foregroundColor: UrbinkColors.onSurface,
            floating: true,
            snap: true,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
          ),

          // ── Badges Quartiers ───────────────────────────────────────────
          badgesAsync.when(
            data: (badges) {
              if (badges.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());
              return SliverMainAxisGroup(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        UrbinkSpacing.md,
                        UrbinkSpacing.lg,
                        UrbinkSpacing.md,
                        UrbinkSpacing.sm,
                      ),
                      child: Text(
                        AppLocalizations.of(context).challenges_badges_section_title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: UrbinkColors.onSurface,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 96,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(
                            horizontal: UrbinkSpacing.md),
                        itemCount: badges.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(width: UrbinkSpacing.sm),
                        itemBuilder: (context, index) =>
                            _QuartierBadgeTile(badge: badges[index]),
                      ),
                    ),
                  ),
                ],
              );
            },
            loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
            error: (_, _) => const SliverToBoxAdapter(child: SizedBox.shrink()),
          ),

          // ── Badges Monuments ──────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                UrbinkSpacing.md,
                UrbinkSpacing.lg,
                UrbinkSpacing.md,
                UrbinkSpacing.sm,
              ),
              child: Text(
                'Monuments',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: UrbinkColors.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
          ),
          monumentsAsync.when(
            data: (monuments) => monumentBadgesAsync.when(
              data: (badges) => SliverToBoxAdapter(
                child: BadgeGrid(monuments: monuments, badges: badges),
              ),
              loading: () =>
                  const SliverToBoxAdapter(child: SizedBox.shrink()),
              error: (_, _) =>
                  const SliverToBoxAdapter(child: SizedBox.shrink()),
            ),
            loading: () =>
                const SliverToBoxAdapter(child: SizedBox.shrink()),
            error: (_, _) =>
                const SliverToBoxAdapter(child: SizedBox.shrink()),
          ),

          // ── Quartiers Progression ──────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                UrbinkSpacing.md,
                UrbinkSpacing.lg,
                UrbinkSpacing.md,
                UrbinkSpacing.sm,
              ),
              child: Text(
                'Quartiers',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: UrbinkColors.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
          ),
          progressionAsync.when(
            data: (progressions) => SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) =>
                    _QuartierProgressionTile(quartier: progressions[index]),
                childCount: progressions.length,
              ),
            ),
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, e) => const SliverFillRemaining(
              child: Center(child: Text('Erreur de chargement')),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _QuartierBadgeTile extends StatelessWidget {
  const _QuartierBadgeTile({required this.badge});

  final QuartierBadge badge;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      decoration: BoxDecoration(
        color: _kGoldLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kGoldBorder, width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🏆', style: TextStyle(fontSize: 28)),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              badge.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Color(0xFF92400E),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _QuartierProgressionTile extends StatelessWidget {
  const _QuartierProgressionTile({required this.quartier});

  final QuartierProgression quartier;

  @override
  Widget build(BuildContext context) {
    final percent = quartier.completionPercent;
    final isCompleted = percent >= 100.0;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: UrbinkSpacing.md,
        vertical: UrbinkSpacing.xs,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  if (isCompleted) ...[
                    const Text('🏆', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 4),
                  ],
                  Text(
                    quartier.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isCompleted ? _kGold : UrbinkColors.onSurface,
                    ),
                  ),
                ],
              ),
              Text(
                isCompleted ? '100%' : '${percent.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isCompleted ? _kGold : UrbinkColors.navInactive,
                ),
              ),
            ],
          ),
          const SizedBox(height: UrbinkSpacing.xs),
          LinearProgressIndicator(
            value: (percent / 100).clamp(0.0, 1.0),
            backgroundColor: isCompleted
                ? _kGoldBorder
                : UrbinkColors.ghost,
            color: isCompleted ? _kGold : UrbinkColors.primary,
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
          const SizedBox(height: UrbinkSpacing.xs),
          Text(
            '${quartier.exploredStreets} / ${quartier.totalStreets} rues',
            style: TextStyle(
              fontSize: 11,
              color: isCompleted ? _kGold : UrbinkColors.navInactive,
            ),
          ),
          const SizedBox(height: UrbinkSpacing.sm),
        ],
      ),
    );
  }
}
