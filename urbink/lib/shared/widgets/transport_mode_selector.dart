import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urbink/features/sessions/models/transport_mode.dart';
import 'package:urbink/features/sessions/providers/transport_mode_provider.dart';

/// Sélecteur de mode de transport — 3 chips segmentés 🚶 · 🚴 · 🚗
///
/// Chip actif : fond Ocre #B8832E + texte blanc.
/// Chips inactifs : fond #F4F2ED + texte Brun Profond.
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

        return GestureDetector(
          onTap: () => ref.read(transportModeProvider.notifier).select(mode),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFFB8832E)
                  : const Color(0xFFF4F2ED),
              borderRadius: BorderRadius.horizontal(
                left: isFirst ? const Radius.circular(8) : Radius.zero,
                right: isLast ? const Radius.circular(8) : Radius.zero,
              ),
              border: Border.all(
                color: const Color(0xFFD4C8B4),
                width: 0.5,
              ),
            ),
            child: Text(
              '${mode.emoji} ${mode.label}',
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : const Color(0xFF1E1610),
                fontSize: 14,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
