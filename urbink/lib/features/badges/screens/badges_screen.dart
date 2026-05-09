import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urbink/features/badges/screens/collection_detail_screen.dart';
import 'package:urbink/features/badges/state/badges_provider.dart';
import 'package:urbink/features/badges/widgets/collection_card.dart';
import 'package:urbink/features/gamification/models/quartier_badge.dart';
import 'package:urbink/features/gamification/models/quartier_progression.dart';
import 'package:urbink/features/gamification/providers/quartier_badges_provider.dart';
import 'package:urbink/features/gamification/providers/quartiers_progression_provider.dart';
import 'package:urbink/shared/constants/colors.dart';
import 'package:urbink/shared/constants/spacing.dart';

// ---------------------------------------------------------------------------
// BadgesScreen — onglet Badges (remplace ChallengesScreen)
// ---------------------------------------------------------------------------

class BadgesScreen extends ConsumerStatefulWidget {
  const BadgesScreen({super.key});

  @override
  ConsumerState<BadgesScreen> createState() => _BadgesScreenState();
}

class _BadgesScreenState extends ConsumerState<BadgesScreen> {
  _Tab _tab = _Tab.monuments;

  @override
  Widget build(BuildContext context) {
    final stats = ref.watch(badgesStatsProvider);
    final collections = ref.watch(collectionsProvider);
    final progressionAsync = ref.watch(quartiersProgressionProvider);
    final quartierBadgesAsync = ref.watch(quartierBadgesStreamProvider);
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: UrbinkColors.background,
      body: CustomScrollView(
        slivers: [
          // ── Padding status bar ──────────────────────────────────────────
          SliverToBoxAdapter(child: SizedBox(height: topPadding)),

          // ── Header ─────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          'Badges',
                          style: TextStyle(
                            fontFamily: 'CrimsonPro',
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            color: UrbinkColors.onSurface,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${stats.monumentsUnlocked} monuments · '
                    '${stats.collectionsComplete} collections complètes — Paris',
                    style: const TextStyle(
                      fontSize: 12,
                      color: UrbinkColors.navInactive,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Stats banner ───────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Container(
                decoration: BoxDecoration(
                  color: UrbinkColors.accent.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: UrbinkColors.accent.withValues(alpha: 0.22),
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatCell(
                        value: '${stats.monumentsUnlocked}',
                        label: 'Badges'),
                    _StatCell(
                        value: '${stats.collectionsComplete}',
                        label: 'Collections'),
                    _StatCell(
                        value: '${stats.quartiersComplete}',
                        label: 'Quartiers'),
                  ],
                ),
              ),
            ),
          ),

          // ── Tab toggle ─────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Container(
                decoration: BoxDecoration(
                  color: UrbinkColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    _TabSegment(
                      label: '🏛️ Monuments',
                      selected: _tab == _Tab.monuments,
                      onTap: () => setState(() => _tab = _Tab.monuments),
                    ),
                    _TabSegment(
                      label: '🏘️ Quartiers',
                      selected: _tab == _Tab.quartiers,
                      onTap: () => setState(() => _tab = _Tab.quartiers),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Contenu selon onglet ───────────────────────────────────────
          if (_tab == _Tab.monuments) ...[
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final col = collections[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: CollectionCard(
                        collection: col,
                        onTap: () =>
                            CollectionDetailScreen.show(context, col),
                      ),
                    );
                  },
                  childCount: collections.length,
                ),
              ),
            ),
          ] else ...[
            // Badges Quartiers (horizontal scroll)
            quartierBadgesAsync.when(
              data: (badges) {
                if (badges.isEmpty) {
                  return const SliverToBoxAdapter(child: SizedBox.shrink());
                }
                return SliverMainAxisGroup(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                        child: Text(
                          'Badges Quartiers',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
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
                          itemBuilder: (_, index) =>
                              _QuartierBadgeTile(badge: badges[index]),
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(
                        child: SizedBox(height: UrbinkSpacing.md)),
                  ],
                );
              },
              loading: () =>
                  const SliverToBoxAdapter(child: SizedBox.shrink()),
              error: (_, _) =>
                  const SliverToBoxAdapter(child: SizedBox.shrink()),
            ),

            // Titre Quartiers
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Text(
                  'Quartiers',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ),

            // Liste progression quartiers
            progressionAsync.when(
              data: (progressions) => SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _QuartierProgressionCard(
                          quartier: progressions[index]),
                    ),
                    childCount: progressions.length,
                  ),
                ),
              ),
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (_, _) => const SliverFillRemaining(
                child: Center(child: Text('Erreur de chargement')),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

enum _Tab { monuments, quartiers }

// ---------------------------------------------------------------------------
// _StatCell
// ---------------------------------------------------------------------------

class _StatCell extends StatelessWidget {
  const _StatCell({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'CrimsonPro',
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: UrbinkColors.accent,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: UrbinkColors.navInactive,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// _TabSegment
// ---------------------------------------------------------------------------

class _TabSegment extends StatelessWidget {
  const _TabSegment({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: selected ? UrbinkColors.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color:
                  selected ? UrbinkColors.onSurface : UrbinkColors.navInactive,
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _QuartierBadgeTile
// ---------------------------------------------------------------------------

const _kGold = Color(0xFFF59E0B);
const _kGoldLight = Color(0xFFFEF3C7);
const _kGoldBorder = Color(0xFFFDE68A);

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
// _QuartierProgressionCard
// ---------------------------------------------------------------------------

class _QuartierProgressionCard extends StatelessWidget {
  const _QuartierProgressionCard({required this.quartier});

  final QuartierProgression quartier;

  @override
  Widget build(BuildContext context) {
    final pct = quartier.completionPercent;
    final isComplete = pct >= 100;

    return Container(
      decoration: BoxDecoration(
        color: UrbinkColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: UrbinkColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      quartier.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: UrbinkColors.onSurface,
                      ),
                    ),
                    Text(
                      '${isComplete ? '100' : pct.toStringAsFixed(1)}% exploré',
                      style: const TextStyle(
                        fontSize: 11,
                        color: UrbinkColors.navInactive,
                      ),
                    ),
                  ],
                ),
              ),
              if (isComplete)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _kGold.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Complet 🏆',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: _kGold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: (pct / 100).clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: UrbinkColors.surfaceVariant,
              valueColor: AlwaysStoppedAnimation<Color>(
                isComplete ? UrbinkColors.accent : UrbinkColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
