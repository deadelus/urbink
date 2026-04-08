import 'package:flutter/material.dart';
import 'package:urbink/shared/constants/colors.dart';
import 'package:urbink/shared/constants/spacing.dart';

enum UrbinkSnackBarType { success, info, error, warning }

/// Affiche un SnackBar Urbink conforme Story 1.4.
///
/// - Positionné au-dessus de la bottom nav
/// - Icône à gauche + message
/// - Durée 2.5s, dismissable par swipe vers le haut
/// - Couleur de fond selon le type :
///   success → #2D5A2D · info → #1E1610 · error → #8B2020 · warning → #7A5A1E
void showUrbinkSnackBar(
  BuildContext context, {
  required String message,
  UrbinkSnackBarType type = UrbinkSnackBarType.info,
}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: _UrbinkSnackBarContent(message: message, type: type),
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(
          left: UrbinkSpacing.md,
          right: UrbinkSpacing.md,
          bottom: UrbinkSpacing.sm,
        ),
        duration: const Duration(milliseconds: 2500),
        dismissDirection: DismissDirection.up,
        padding: EdgeInsets.zero,
      ),
    );
}

// ---------------------------------------------------------------------------

class _UrbinkSnackBarContent extends StatelessWidget {
  const _UrbinkSnackBarContent({required this.message, required this.type});

  final String message;
  final UrbinkSnackBarType type;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: UrbinkSpacing.md,
        vertical: UrbinkSpacing.sm + UrbinkSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(UrbinkSpacing.radiusChip + 2),
      ),
      child: Row(
        children: [
          Icon(_icon, color: Colors.white, size: 18),
          const SizedBox(width: UrbinkSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color get _backgroundColor {
    switch (type) {
      case UrbinkSnackBarType.success:
        return UrbinkColors.toastSuccess;
      case UrbinkSnackBarType.info:
        return UrbinkColors.toastInfo;
      case UrbinkSnackBarType.error:
        return UrbinkColors.toastError;
      case UrbinkSnackBarType.warning:
        return UrbinkColors.toastWarning;
    }
  }

  IconData get _icon {
    switch (type) {
      case UrbinkSnackBarType.success:
        return Icons.check_circle_outline;
      case UrbinkSnackBarType.info:
        return Icons.info_outline;
      case UrbinkSnackBarType.error:
        return Icons.error_outline;
      case UrbinkSnackBarType.warning:
        return Icons.warning_amber_outlined;
    }
  }
}
