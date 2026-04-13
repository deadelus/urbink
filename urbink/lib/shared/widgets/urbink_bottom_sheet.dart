import 'package:flutter/material.dart';
import 'package:urbink/shared/constants/colors.dart';
import 'package:urbink/shared/constants/spacing.dart';

/// Affiche un bottom sheet Urbink conforme Story 1.3 :
/// - Snap à [initialSnap] (défaut 0.4 = 40% aperçu) ou 70% (détail)
/// - Pill de drag 4×32px en #D4C8B4
/// - Scrim #1E1610 à 40% opacité
/// - Fermeture par swipe bas ou tap sur le scrim
/// - Focus VoiceOver limité au bottom sheet via `Semantics(scopesRoute: true)`
Future<T?> showUrbinkBottomSheet<T>({
  required BuildContext context,
  required Widget child,
  double initialSnap = 0.4,
}) {
  if (initialSnap != 0.4 && initialSnap != 0.7) {
    throw ArgumentError.value(
      initialSnap,
      'initialSnap',
      'doit être 0.4 (aperçu) ou 0.7 (détail)',
    );
  }

  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: UrbinkColors.sheetScrim.withValues(alpha: 0.40),
    builder: (_) => DraggableScrollableSheet(
      initialChildSize: initialSnap,
      minChildSize: 0.15,
      maxChildSize: 0.70,
      snap: true,
      snapSizes: const [0.40, 0.70],
      builder: (context, scrollController) => _UrbinkSheetContent(
        scrollController: scrollController,
        child: child,
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Contenu interne du bottom sheet
// ---------------------------------------------------------------------------

class _UrbinkSheetContent extends StatelessWidget {
  const _UrbinkSheetContent({
    required this.scrollController,
    required this.child,
  });

  final ScrollController scrollController;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Semantics(
      // Focus VoiceOver piégé : scopesRoute délimite la portée de navigation
      // accessibilité à ce widget, empêchant VoiceOver d'atteindre le contenu dessous.
      scopesRoute: true,
      explicitChildNodes: true,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(UrbinkSpacing.radiusCard),
          ),
        ),
        child: Column(
          children: [
            // Pill de drag : 4×32px en #D4C8B4
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: Container(
                  width: 32,
                  height: 4,
                  decoration: BoxDecoration(
                    color: UrbinkColors.sheetDragPill,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
            // Contenu scrollable
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: EdgeInsets.only(bottom: bottomPadding),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
