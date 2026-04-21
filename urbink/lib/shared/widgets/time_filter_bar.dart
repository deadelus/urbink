import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urbink/features/map/providers/time_filter_provider.dart';
import 'package:urbink/shared/constants/colors.dart';

/// Barre de chips horizontale permettant de filtrer les rues explorées par période.
///
/// Affiche 4 options : Tout / Aujourd'hui / Cette semaine / Ce mois.
/// La sélection est persistée via SharedPreferences.
class TimeFilterBar extends ConsumerWidget {
  const TimeFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(timeFilterProvider);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(
        children: TimeFilter.values.map((filter) {
          final isSelected = filter == selected;
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: _FilterChip(
              label: filter.label,
              isSelected: isSelected,
              onTap: () =>
                  ref.read(timeFilterProvider.notifier).select(filter),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      label: label,
      onTapHint: 'Filtrer par $label',
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? UrbinkColors.primary : UrbinkColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: isSelected
                ? null
                : Border.all(
                    color: UrbinkColors.primary.withValues(alpha: 0.35),
                    width: 1,
                  ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ExcludeSemantics(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : UrbinkColors.onSurface,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
