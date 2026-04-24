import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urbink/features/map/providers/active_filters_provider.dart';
import 'package:urbink/l10n/app_localizations.dart';
import 'package:urbink/shared/constants/colors.dart';
import 'package:urbink/shared/constants/poi_filters.dart';
import 'package:urbink/shared/constants/typography.dart';

/// Barre de filtres POI horizontale avec bouton "Voir plus".
///
/// Affiche [quickPoiFilters] + un chip "Voir plus" qui déclenche [onMoreTap].
/// L'état actif est géré via [activeFiltersProvider] (multi-sélection).
class FilterChipsRow extends ConsumerWidget {
  const FilterChipsRow({
    super.key,
    required this.onMoreTap,
    this.padding = EdgeInsets.zero,
  });

  final VoidCallback onMoreTap;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ref.watch(activeFiltersProvider);
    final extraActive = active.where(
      (id) => !quickPoiFilters.any((f) => f.id == id),
    ).length;

    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: padding,
        children: [
          ...quickPoiFilters.map((f) {
            final isActive = active.contains(f.id);
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _FilterChip(
                filter: f,
                isActive: isActive,
                onTap: () {
                  final set = Set<String>.from(active);
                  isActive ? set.remove(f.id) : set.add(f.id);
                  ref.read(activeFiltersProvider.notifier).state = set;
                },
              ),
            );
          }),
          _MoreChip(onTap: onMoreTap, extraActiveCount: extraActive),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Chip individuel
// ---------------------------------------------------------------------------

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.filter,
    required this.isActive,
    required this.onTap,
  });

  final PoiFilter filter;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: isActive ? UrbinkColors.primary : UrbinkColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive ? UrbinkColors.primary : UrbinkColors.border,
            width: isActive ? 1.5 : 1.0,
          ),
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                filter.icon,
                size: 13,
                color: isActive ? Colors.white : UrbinkColors.onSurface,
              ),
              const SizedBox(width: 5),
              Text(
                filter.label,
                style: TextStyle(
                  fontFamily: UrbinkTypography.bodyFamily,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isActive ? Colors.white : UrbinkColors.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Chip "Voir plus"
// ---------------------------------------------------------------------------

class _MoreChip extends StatelessWidget {
  const _MoreChip({required this.onTap, required this.extraActiveCount});

  final VoidCallback onTap;
  final int extraActiveCount;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: UrbinkColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: extraActiveCount > 0
                ? UrbinkColors.primary
                : UrbinkColors.border,
            width: extraActiveCount > 0 ? 1.5 : 1.0,
          ),
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.tune_rounded,
                size: 14,
                color: extraActiveCount > 0
                    ? UrbinkColors.primary
                    : UrbinkColors.navInactive,
              ),
              const SizedBox(width: 5),
              Text(
                AppLocalizations.of(context).btn_see_more,
                style: TextStyle(
                  fontFamily: UrbinkTypography.bodyFamily,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: extraActiveCount > 0
                      ? UrbinkColors.primary
                      : UrbinkColors.navInactive,
                ),
              ),
              if (extraActiveCount > 0) ...[
                const SizedBox(width: 5),
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: UrbinkColors.primary,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Center(
                    child: Text(
                      '$extraActiveCount',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
