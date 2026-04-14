import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urbink/features/map/providers/streets_visible_provider.dart';
import 'package:urbink/shared/constants/colors.dart';

/// Pill bas-gauche — toggle affichage des rues explorées (FR10b).
///
/// Appuyer sur le pill bascule [streetsVisibleProvider].
/// Le tracking passif continue indépendamment de l'état du toggle.
class ZonesTogglePill extends ConsumerWidget {
  const ZonesTogglePill({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visible = ref.watch(streetsVisibleProvider);

    return Semantics(
      label: visible ? 'Masquer les zones explorées' : 'Afficher les zones explorées',
      button: true,
      child: GestureDetector(
        onTap: () =>
            ref.read(streetsVisibleProvider.notifier).state = !visible,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: visible
                ? UrbinkColors.streetExplored
                : const Color(0xFF555555),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                visible ? Icons.layers_rounded : Icons.layers_clear_rounded,
                color: Colors.white,
                size: 16,
              ),
              const SizedBox(width: 5),
              const Text(
                'Zones',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
