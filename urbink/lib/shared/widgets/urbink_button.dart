import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:urbink/shared/constants/colors.dart';
import 'package:urbink/shared/constants/spacing.dart';

enum UrbinkButtonVariant { primary, secondary, destructive }

/// Bouton Urbink — 3 variantes conformes Story 1.4.
///
/// - [primary]     : fond Primary #256F4C, texte blanc, hauteur 52pt, radius 16px
/// - [secondary]   : contour Primary 1.5px, fond transparent, texte Primary
/// - [destructive] : texte Rouge #DC2626, fond transparent — pour actions irréversibles
///
/// État loading : spinner blanc inline, bouton non interactif.
/// Haptique : HeavyImpact (primary) · LightImpact (secondary/destructive).
class UrbinkButton extends StatelessWidget {
  const UrbinkButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = UrbinkButtonVariant.primary,
    this.isLoading = false,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final UrbinkButtonVariant variant;
  final bool isLoading;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: _buildButton(context),
    );
  }

  Widget _buildButton(BuildContext context) {
    switch (variant) {
      case UrbinkButtonVariant.primary:
        return FilledButton(
          onPressed: (isLoading || onPressed == null) ? null : _handlePress,
          style: FilledButton.styleFrom(
            backgroundColor: UrbinkColors.primary,
            disabledBackgroundColor: UrbinkColors.primary.withValues(alpha: 0.5),
            foregroundColor: Colors.white,
            minimumSize: const Size(UrbinkSpacing.minTapTarget, 52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(UrbinkSpacing.radiusButton),
            ),
          ),
          child: _buildContent(Colors.white),
        );

      case UrbinkButtonVariant.secondary:
        return OutlinedButton(
          onPressed: (isLoading || onPressed == null) ? null : _handlePress,
          style: OutlinedButton.styleFrom(
            foregroundColor: UrbinkColors.primary,
            side: const BorderSide(color: UrbinkColors.primary, width: 1.5),
            minimumSize: const Size(UrbinkSpacing.minTapTarget, 52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(UrbinkSpacing.radiusButton),
            ),
          ),
          child: _buildContent(UrbinkColors.primary),
        );

      case UrbinkButtonVariant.destructive:
        return TextButton(
          onPressed: (isLoading || onPressed == null) ? null : _handlePress,
          style: TextButton.styleFrom(
            foregroundColor: UrbinkColors.destructive,
            minimumSize: const Size(UrbinkSpacing.minTapTarget, 52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(UrbinkSpacing.radiusButton),
            ),
          ),
          child: _buildContent(UrbinkColors.destructive),
        );
    }
  }

  Widget _buildContent(Color color) {
    if (isLoading) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: UrbinkSpacing.sm),
          Text(label),
        ],
      );
    }

    return Text(label);
  }

  void _handlePress() {
    // Haptique selon la variante — Story 1.4
    switch (variant) {
      case UrbinkButtonVariant.primary:
        HapticFeedback.heavyImpact();
        break;
      case UrbinkButtonVariant.secondary:
      case UrbinkButtonVariant.destructive:
        HapticFeedback.lightImpact();
        break;
    }
    onPressed?.call();
  }
}
