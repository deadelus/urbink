import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:urbink/l10n/app_localizations.dart';

/// Affiche le dialog "GPS requis" standardisé.
///
/// Utilisé depuis [SortiesBottomSheet] et [app_router.dart] pour garantir
/// un texte, des actions et un comportement cohérents sur toute l'app.
Future<void> showGpsRequiredDialog(BuildContext context) {
  final l10n = AppLocalizations.of(context);
  return showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(l10n.gps_required_title),
      content: Text(l10n.gps_required_message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: Text(l10n.btn_cancel),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(ctx).pop();
            openAppSettings();
          },
          child: Text(l10n.btn_open_settings),
        ),
      ],
    ),
  );
}
