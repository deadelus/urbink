import 'package:flutter/material.dart';
import 'package:urbink/features/badges/data/collection_model.dart';
import 'package:urbink/shared/constants/colors.dart';

// ---------------------------------------------------------------------------
// MonumentTile — tuile dans la grille de la CollectionDetailScreen
// ---------------------------------------------------------------------------

class MonumentTile extends StatelessWidget {
  const MonumentTile({
    super.key,
    required this.monument,
    required this.collectionColor,
    this.onTap,
  });

  final CollectionMonument monument;
  final Color collectionColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${monument.name}, ${monument.locked ? 'verrouillé' : 'débloqué'}',
      child: GestureDetector(
        onTap: onTap,
        child: Stack(
          clipBehavior: Clip.none,
          fit: StackFit.expand,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
              decoration: BoxDecoration(
                color: UrbinkColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: monument.locked
                      ? UrbinkColors.border
                      : collectionColor.withValues(alpha: 0.25),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 4,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: Opacity(
                opacity: monument.locked ? 0.4 : 1.0,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ColorFiltered(
                      colorFilter: monument.locked
                          ? const ColorFilter.matrix([
                              0.2126,
                              0.7152,
                              0.0722,
                              0,
                              0,
                              0.2126,
                              0.7152,
                              0.0722,
                              0,
                              0,
                              0.2126,
                              0.7152,
                              0.0722,
                              0,
                              0,
                              0,
                              0,
                              0,
                              1,
                              0,
                            ])
                          : const ColorFilter.mode(
                              Colors.transparent,
                              BlendMode.dst,
                            ),
                      child: Text(
                        monument.emoji,
                        style: const TextStyle(fontSize: 30),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      monument.name,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: monument.locked
                            ? UrbinkColors.navInactive
                            : UrbinkColors.onSurface,
                        height: 1.2,
                      ),
                    ),
                    if (monument.locked) ...[
                      const SizedBox(height: 4),
                      const Icon(
                        Icons.lock,
                        color: UrbinkColors.navInactive,
                        size: 12,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (!monument.locked)
              Positioned(
                top: -4,
                right: -4,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: collectionColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 10),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
