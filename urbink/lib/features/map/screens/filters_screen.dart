import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:urbink/features/map/providers/active_filters_provider.dart';
import 'package:urbink/shared/constants/colors.dart';
import 'package:urbink/shared/constants/poi_filters.dart';
import 'package:urbink/shared/constants/spacing.dart';

/// Écran complet de sélection des filtres POI.
///
/// Affiche toutes les catégories en Wrap. L'état est synchronisé en temps réel
/// via [activeFiltersProvider]. Un badge indique le nombre de filtres actifs.
class FiltersScreen extends ConsumerWidget {
  const FiltersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ref.watch(activeFiltersProvider);
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: UrbinkColors.background,
      body: Column(
        children: [
          // ── Header ─────────────────────────────────────────────────────────
          Container(
            color: UrbinkColors.surface,
            padding: EdgeInsets.fromLTRB(
              UrbinkSpacing.sm,
              topPadding + UrbinkSpacing.sm,
              UrbinkSpacing.md,
              UrbinkSpacing.sm,
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                  style: IconButton.styleFrom(
                    foregroundColor: UrbinkColors.onSurface,
                  ),
                ),
                Expanded(
                  child: Text(
                    'Filtres',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: UrbinkColors.onSurface,
                        ),
                  ),
                ),
                if (active.isNotEmpty)
                  TextButton(
                    onPressed: () =>
                        ref.read(activeFiltersProvider.notifier).state =
                            const <String>{},
                    style: TextButton.styleFrom(
                        foregroundColor: UrbinkColors.destructive),
                    child: const Text(
                      'Réinitialiser',
                      style: TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ),
              ],
            ),
          ),

          // ── Bandeau "X filtres actifs" ───────────────────────────────────
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: active.isNotEmpty
                ? Container(
                    key: const ValueKey('banner'),
                    width: double.infinity,
                    color: UrbinkColors.primary.withValues(alpha: 0.07),
                    padding: const EdgeInsets.symmetric(
                        horizontal: UrbinkSpacing.md,
                        vertical: UrbinkSpacing.sm),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_rounded,
                            size: 14, color: UrbinkColors.primary),
                        const SizedBox(width: 6),
                        Text(
                          '${active.length} filtre${active.length > 1 ? 's' : ''} actif${active.length > 1 ? 's' : ''}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: UrbinkColors.primary,
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox(key: ValueKey('no_banner')),
          ),

          // ── Liste des catégories ─────────────────────────────────────────
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.fromLTRB(
                UrbinkSpacing.md,
                UrbinkSpacing.lg,
                UrbinkSpacing.md,
                UrbinkSpacing.lg + bottomPadding,
              ),
              itemCount: poiFilterCategories.length,
              itemBuilder: (context, i) {
                final cat = poiFilterCategories[i];
                return Padding(
                  padding: EdgeInsets.only(
                      bottom: i < poiFilterCategories.length - 1
                          ? UrbinkSpacing.xl
                          : 0),
                  child: _CategorySection(
                    category: cat,
                    active: active,
                    onToggle: (id) {
                      final set = Set<String>.from(active);
                      set.contains(id) ? set.remove(id) : set.add(id);
                      ref.read(activeFiltersProvider.notifier).state = set;
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Section d'une catégorie
// ---------------------------------------------------------------------------

class _CategorySection extends StatelessWidget {
  const _CategorySection({
    required this.category,
    required this.active,
    required this.onToggle,
  });

  final PoiFilterCategory category;
  final Set<String> active;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    final activeInCat =
        category.filters.where((f) => active.contains(f.id)).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              category.label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: UrbinkColors.onSurface,
              ),
            ),
            if (activeInCat > 0) ...[
              const SizedBox(width: UrbinkSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: UrbinkColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$activeInCat',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: UrbinkSpacing.sm + 4),
        Wrap(
          spacing: UrbinkSpacing.sm,
          runSpacing: UrbinkSpacing.sm,
          children: category.filters
              .map((f) => _FilterTile(
                    filter: f,
                    isActive: active.contains(f.id),
                    onTap: () => onToggle(f.id),
                  ))
              .toList(),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Chip de filtre (vue grille)
// ---------------------------------------------------------------------------

class _FilterTile extends StatelessWidget {
  const _FilterTile({
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
        padding: const EdgeInsets.symmetric(
          horizontal: UrbinkSpacing.md,
          vertical: UrbinkSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isActive ? UrbinkColors.primary : UrbinkColors.surface,
          borderRadius: BorderRadius.circular(UrbinkSpacing.radiusChip),
          border: Border.all(
            color: isActive ? UrbinkColors.primary : UrbinkColors.border,
            width: isActive ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              filter.icon,
              size: 15,
              color: isActive ? Colors.white : UrbinkColors.navInactive,
            ),
            const SizedBox(width: 6),
            Text(
              filter.label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isActive ? Colors.white : UrbinkColors.onSurface,
              ),
            ),
            if (isActive) ...[
              const SizedBox(width: 5),
              const Icon(Icons.check_rounded,
                  size: 13, color: Colors.white),
            ],
          ],
        ),
      ),
    );
  }
}
