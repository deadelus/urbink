import 'package:flutter/material.dart';
import 'package:urbink/features/session_end/models/badge_unlock.dart';
import 'package:urbink/shared/constants/colors.dart';

/// Médaille circulaire pour un badge avec gradient selon sa rareté + halo.
class BadgeMedal extends StatelessWidget {
  final BadgeUnlock badge;
  final double size;

  const BadgeMedal({super.key, required this.badge, this.size = 120});

  static const _gradients = {
    BadgeRarity.common: [Color(0xFF94A3B8), Color(0xFF64748B)],
    BadgeRarity.rare: [Color(0xFF60A5FA), Color(0xFF2563EB)],
    BadgeRarity.epic: [Color(0xFFA78BFA), Color(0xFF7C3AED)],
    BadgeRarity.legendary: [Color(0xFFF59E0B), Color(0xFFB8832E)],
  };

  @override
  Widget build(BuildContext context) {
    final colors = _gradients[badge.rarity] ?? _gradients[BadgeRarity.legendary]!;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
        boxShadow: [
          BoxShadow(
            color: UrbinkColors.accent.withValues(alpha: 0.20),
            spreadRadius: 8,
            blurRadius: 0,
          ),
          BoxShadow(
            color: UrbinkColors.accent.withValues(alpha: 0.10),
            spreadRadius: 16,
            blurRadius: 0,
          ),
        ],
      ),
      child: Center(
        child: Text(badge.icon, style: TextStyle(fontSize: size * 0.43)),
      ),
    );
  }
}
