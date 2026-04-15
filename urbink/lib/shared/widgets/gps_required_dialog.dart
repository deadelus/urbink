import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

/// Affiche le dialog "GPS requis" standardisé.
///
/// Utilisé depuis [SortiesBottomSheet] et [app_router.dart] pour garantir
/// un texte, des actions et un comportement cohérents sur toute l'app.
Future<void> showGpsRequiredDialog(BuildContext context) {
  return showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('GPS requis'),
      content: const Text(
        'Le GPS est requis pour colorier tes rues.\n'
        'Active-le dans les Réglages pour continuer.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('Annuler'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(ctx).pop();
            openAppSettings();
          },
          child: const Text('Ouvrir les réglages'),
        ),
      ],
    ),
  );
}
