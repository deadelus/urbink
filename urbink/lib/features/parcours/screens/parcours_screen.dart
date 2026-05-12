import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urbink/features/parcours/data/parcours_model.dart';
import 'package:urbink/features/parcours/providers/parcours_generation_provider.dart';
import 'package:urbink/features/parcours/widgets/route_map_preview.dart';
import 'package:urbink/features/sessions/models/transport_mode.dart';
import 'package:urbink/features/sessions/providers/session_lifecycle_provider.dart';
import 'package:urbink/shared/constants/colors.dart';
import 'package:urbink/shared/constants/spacing.dart';

class ParcoursScreen extends ConsumerStatefulWidget {
  const ParcoursScreen({super.key});

  @override
  ConsumerState<ParcoursScreen> createState() => _ParcoursScreenState();
}

class _ParcoursScreenState extends ConsumerState<ParcoursScreen> {
  int _selectedDuration = 30;
  TransportMode _selectedMode = TransportMode.walking;

  @override
  Widget build(BuildContext context) {
    final generationState = ref.watch(parcoursGenerationNotifierProvider);
    final uid = ref.watch(currentUidProvider);
    final position = ref.watch(lastKnownPositionProvider);

    return Scaffold(
      backgroundColor: UrbinkColors.background,
      appBar: AppBar(
        title: const Text('Parcours'),
        backgroundColor: UrbinkColors.surface,
        foregroundColor: UrbinkColors.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(UrbinkSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _AutoSection(
                selectedDuration: _selectedDuration,
                selectedMode: _selectedMode,
                generationState: generationState,
                isLoading: generationState is ParcoursGenerationLoading,
                onDurationChanged: (d) => setState(() => _selectedDuration = d),
                onModeChanged: (m) => setState(() => _selectedMode = m),
                onGenerate: () async {
                  if (uid == null) return;
                  final pos = position.valueOrNull ?? _parisCenter;
                  await ref
                      .read(parcoursGenerationNotifierProvider.notifier)
                      .generate(
                        uid: uid,
                        lat: pos.$1,
                        lng: pos.$2,
                        durationMinutes: _selectedDuration,
                        mode: _selectedMode,
                      );
                },
                onDemarrer: () async {
                  if (uid == null) return;
                  final state = generationState;
                  if (state is! ParcoursGenerationSuccess) return;
                  final messenger = ScaffoldMessenger.of(context);
                  await ref
                      .read(parcoursGenerationNotifierProvider.notifier)
                      .saveParcours(uid: uid, parcours: state.parcours);
                  if (!mounted) return;
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('Parcours sauvegardé — guidage disponible en Story 5.4'),
                      duration: Duration(seconds: 3),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

const _parisCenter = (48.8566, 2.3522);

// ---------------------------------------------------------------------------
// Sections
// ---------------------------------------------------------------------------

class _AutoSection extends StatelessWidget {
  const _AutoSection({
    required this.selectedDuration,
    required this.selectedMode,
    required this.generationState,
    required this.isLoading,
    required this.onDurationChanged,
    required this.onModeChanged,
    required this.onGenerate,
    required this.onDemarrer,
  });

  final int selectedDuration;
  final TransportMode selectedMode;
  final ParcoursGenerationState generationState;
  final bool isLoading;
  final ValueChanged<int> onDurationChanged;
  final ValueChanged<TransportMode> onModeChanged;
  final VoidCallback onGenerate;
  final VoidCallback onDemarrer;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SectionHeader(
          title: 'Parcours automatique',
          subtitle: 'Découvrez de nouvelles rues autour de vous',
        ),
        const SizedBox(height: UrbinkSpacing.md),
        _DurationSelector(
          selected: selectedDuration,
          onChanged: isLoading ? null : onDurationChanged,
        ),
        const SizedBox(height: UrbinkSpacing.md),
        _ModeSelector(
          selected: selectedMode,
          onChanged: isLoading ? null : onModeChanged,
        ),
        const SizedBox(height: UrbinkSpacing.lg),
        _GenerateButton(
          isLoading: isLoading,
          onPressed: isLoading ? null : onGenerate,
        ),
        const SizedBox(height: UrbinkSpacing.lg),
        _GenerationResult(
          state: generationState,
          onDemarrer: onDemarrer,
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Sous-widgets
// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: tt.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: UrbinkColors.onSurface,
            )),
        const SizedBox(height: UrbinkSpacing.xs),
        Text(subtitle,
            style: tt.bodyMedium?.copyWith(color: UrbinkColors.textMuted)),
      ],
    );
  }
}

class _DurationSelector extends StatelessWidget {
  const _DurationSelector({required this.selected, this.onChanged});

  final int selected;
  final ValueChanged<int>? onChanged;

  static const _values = [15, 30, 45, 60];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Durée',
            style: Theme.of(context)
                .textTheme
                .labelLarge
                ?.copyWith(color: UrbinkColors.textMuted)),
        const SizedBox(height: UrbinkSpacing.sm),
        Wrap(
          spacing: UrbinkSpacing.sm,
          children: _values.map((d) {
            final isSelected = d == selected;
            return ChoiceChip(
              key: ValueKey('duration_$d'),
              label: Text('$d min'),
              selected: isSelected,
              onSelected: onChanged == null ? null : (_) => onChanged!(d),
              selectedColor: UrbinkColors.primary,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : UrbinkColors.onSurface,
                fontWeight: FontWeight.w500,
              ),
              backgroundColor: UrbinkColors.surfaceVariant,
              side: BorderSide.none,
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _ModeSelector extends StatelessWidget {
  const _ModeSelector({required this.selected, this.onChanged});

  final TransportMode selected;
  final ValueChanged<TransportMode>? onChanged;

  static const _modes = [
    TransportMode.walking,
    TransportMode.cycling,
    TransportMode.driving,
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Mode',
            style: Theme.of(context)
                .textTheme
                .labelLarge
                ?.copyWith(color: UrbinkColors.textMuted)),
        const SizedBox(height: UrbinkSpacing.sm),
        Wrap(
          spacing: UrbinkSpacing.sm,
          children: _modes.map((m) {
            final isSelected = m == selected;
            return ChoiceChip(
              key: ValueKey('mode_${m.name}'),
              label: Text('${m.emoji} ${m.label}'),
              selected: isSelected,
              onSelected: onChanged == null ? null : (_) => onChanged!(m),
              selectedColor: UrbinkColors.primary,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : UrbinkColors.onSurface,
                fontWeight: FontWeight.w500,
              ),
              backgroundColor: UrbinkColors.surfaceVariant,
              side: BorderSide.none,
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _GenerateButton extends StatelessWidget {
  const _GenerateButton({required this.isLoading, this.onPressed});

  final bool isLoading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: UrbinkSpacing.minTapTarget,
      child: FilledButton(
        key: const Key('generate_button'),
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: UrbinkColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(UrbinkSpacing.radiusButton),
          ),
        ),
        child: isLoading
            ? const SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Text('Générer', style: TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class _GenerationResult extends StatelessWidget {
  const _GenerationResult({required this.state, required this.onDemarrer});

  final ParcoursGenerationState state;
  final VoidCallback onDemarrer;

  @override
  Widget build(BuildContext context) {
    return switch (state) {
      ParcoursGenerationIdle() => const SizedBox.shrink(),
      ParcoursGenerationLoading() => const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: UrbinkSpacing.xl),
            child: Column(
              children: [
                CircularProgressIndicator(color: UrbinkColors.primary),
                SizedBox(height: UrbinkSpacing.md),
                Text('Génération en cours…'),
              ],
            ),
          ),
        ),
      ParcoursGenerationError(:final message) => _ErrorCard(message: message),
      ParcoursGenerationSuccess(:final parcours, :final newStreetsCount) =>
        _SuccessCard(
          parcours: parcours,
          newStreetsCount: newStreetsCount,
          onDemarrer: onDemarrer,
        ),
    };
  }
}

class _SuccessCard extends StatelessWidget {
  const _SuccessCard({
    required this.parcours,
    required this.newStreetsCount,
    required this.onDemarrer,
  });

  final Parcours parcours;
  final int newStreetsCount;
  final VoidCallback onDemarrer;

  @override
  Widget build(BuildContext context) {
    final distKm = (parcours.estimatedDistance / 1000).toStringAsFixed(1);
    final durMin = (parcours.estimatedDuration ~/ 60).toString();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(UrbinkSpacing.radiusCard),
          child: RouteMapPreview(
            key: const Key('result_preview'),
            points: parcours.points,
            variant: RouteMapVariant.medium,
            isSession: false,
          ),
        ),
        const SizedBox(height: UrbinkSpacing.md),
        _StatsRow(
          distKm: distKm,
          durMin: durMin,
          newStreetsCount: newStreetsCount,
        ),
        const SizedBox(height: UrbinkSpacing.md),
        SizedBox(
          height: UrbinkSpacing.minTapTarget,
          child: FilledButton(
            key: const Key('demarrer_button'),
            onPressed: onDemarrer,
            style: FilledButton.styleFrom(
              backgroundColor: UrbinkColors.ocre,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(UrbinkSpacing.radiusButton),
              ),
            ),
            child: const Text(
              'Démarrer ce parcours',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({
    required this.distKm,
    required this.durMin,
    required this.newStreetsCount,
  });

  final String distKm;
  final String durMin;
  final int newStreetsCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _StatChip(label: '$distKm km', icon: Icons.straighten),
        _StatChip(label: '$durMin min', icon: Icons.timer_outlined),
        _StatChip(
          label: '$newStreetsCount rues',
          icon: Icons.add_road,
          color: UrbinkColors.primary,
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.icon,
    this.color,
  });

  final String label;
  final IconData icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? UrbinkColors.textMuted;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: effectiveColor),
        const SizedBox(width: UrbinkSpacing.xs),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: effectiveColor,
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('error_card'),
      padding: const EdgeInsets.all(UrbinkSpacing.md),
      decoration: BoxDecoration(
        color: UrbinkColors.toastError.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(UrbinkSpacing.radiusCard),
        border: Border.all(
          color: UrbinkColors.toastError.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: UrbinkColors.toastError),
          const SizedBox(width: UrbinkSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: UrbinkColors.toastError,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
