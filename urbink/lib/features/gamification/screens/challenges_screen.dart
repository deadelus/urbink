import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urbink/features/gamification/models/quartier_progression.dart';
import 'package:urbink/features/gamification/providers/quartiers_progression_provider.dart';
import 'package:urbink/shared/constants/colors.dart';
import 'package:urbink/shared/constants/spacing.dart';

class ChallengesScreen extends ConsumerWidget {
  const ChallengesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressionAsync = ref.watch(quartiersProgressionProvider);

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

class _QuartierProgressionTile extends StatelessWidget {
  const _QuartierProgressionTile({required this.quartier});

  final QuartierProgression quartier;

  @override
  Widget build(BuildContext context) {
    final percent = quartier.completionPercent;

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
              Text(
                quartier.name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: UrbinkColors.onSurface,
                ),
              ),
              Text(
                '${percent.toStringAsFixed(1)}%',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: UrbinkColors.navInactive,
                ),
              ),
            ],
          ),
          const SizedBox(height: UrbinkSpacing.xs),
          LinearProgressIndicator(
            value: percent / 100,
            backgroundColor: UrbinkColors.ghost,
            color: UrbinkColors.primary,
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
          const SizedBox(height: UrbinkSpacing.xs),
          Text(
            '${quartier.exploredStreets} / ${quartier.totalStreets} rues',
            style: const TextStyle(
              fontSize: 11,
              color: UrbinkColors.navInactive,
            ),
          ),
          const SizedBox(height: UrbinkSpacing.sm),
        ],
      ),
    );
  }
}
