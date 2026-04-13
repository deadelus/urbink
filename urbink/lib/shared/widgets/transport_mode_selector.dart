import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urbink/features/sessions/models/transport_mode.dart';
import 'package:urbink/features/sessions/providers/transport_mode_provider.dart';
import 'package:urbink/shared/constants/colors.dart';
import 'package:urbink/shared/constants/spacing.dart';
import 'package:urbink/shared/constants/typography.dart';

/// Sélecteur de mode de transport — 3 chips segmentés 🚶 · 🚴 · 🚗
///
/// Chip actif : fond [UrbinkColors.primary] (Ocre) + texte blanc.
/// Chips inactifs : fond [UrbinkColors.surfaceVariant] + texte [UrbinkColors.onSurface].
/// Le dernier choix est mémorisé via SharedPreferences.
class TransportModeSelector extends ConsumerWidget {
  const TransportModeSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(transportModeProvider);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: TransportMode.values.map((mode) {
        final isSelected = mode == selected;
        final isFirst = mode == TransportMode.values.first;
        final isLast = mode == TransportMode.values.last;

        return Semantics(
          button: true,
          selected: isSelected,
          label: '${mode.label}, mode de déplacement',
          excludeSemantics: true,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => ref.read(transportModeProvider.notifier).select(mode),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minWidth: UrbinkSpacing.minTapTarget,
                minHeight: UrbinkSpacing.minTapTarget,
              ),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? UrbinkColors.primary
                      : UrbinkColors.surfaceVariant,
                  borderRadius: BorderRadius.horizontal(
                    left: isFirst
                        ? const Radius.circular(UrbinkSpacing.radiusChip)
                        : Radius.zero,
                    right: isLast
                        ? const Radius.circular(UrbinkSpacing.radiusChip)
                        : Radius.zero,
                  ),
                  border: Border.all(
                    color: UrbinkColors.sheetDragPill,
                    width: 0.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    '${mode.emoji} ${mode.label}',
                    style: TextStyle(
                      color: isSelected ? Colors.white : UrbinkColors.onSurface,
                      fontSize: 14,
                      fontFamily: UrbinkTypography.bodyFamily,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
