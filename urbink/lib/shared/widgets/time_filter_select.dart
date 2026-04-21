import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urbink/features/map/providers/time_filter_provider.dart';
import 'package:urbink/shared/constants/colors.dart';
import 'package:urbink/shared/constants/typography.dart';

/// Select pill flottant affiché à côté de [ZonesTogglePill] quand les zones
/// sont visibles. Permet de choisir la période de filtrage temporel.
class TimeFilterSelect extends ConsumerWidget {
  const TimeFilterSelect({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(timeFilterProvider);

    return Semantics(
      button: true,
      label: 'Période : ${selected.label}',
      child: PopupMenuButton<TimeFilter>(
        initialValue: selected,
        onSelected: (filter) =>
            ref.read(timeFilterProvider.notifier).select(filter),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        itemBuilder: (_) => TimeFilter.values
            .map(
              (f) => PopupMenuItem<TimeFilter>(
                value: f,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        f.label,
                        style: TextStyle(
                          fontFamily: UrbinkTypography.bodyFamily,
                          fontSize: 14,
                          fontWeight: f == selected
                              ? FontWeight.w700
                              : FontWeight.w400,
                          color: f == selected
                              ? UrbinkColors.primary
                              : UrbinkColors.onSurface,
                        ),
                      ),
                    ),
                    if (f == selected)
                      const Icon(Icons.check_rounded,
                          color: UrbinkColors.primary, size: 16),
                  ],
                ),
              ),
            )
            .toList(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: UrbinkColors.surface,
            borderRadius: BorderRadius.circular(50),
            border: Border.all(color: UrbinkColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                selected.label,
                style: const TextStyle(
                  fontFamily: UrbinkTypography.bodyFamily,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: UrbinkColors.primary,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.expand_more_rounded,
                  color: UrbinkColors.primary, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
