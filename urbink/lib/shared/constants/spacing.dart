abstract final class UrbinkSpacing {
  // Grille 8px — base 4px pour les micro-espacements
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  // Border radius — iOS-inspired, rounded
  static const double radiusButton = 16.0;
  static const double radiusCard = 20.0;
  static const double radiusChip = 10.0;
  static const double radiusSheet = 24.0;

  // Zones tactiles iOS HIG
  static const double minTapTarget = 44.0;

  // Bottom nav & safe areas
  static const double bottomNavHeight = 74.0;
  static const double thumbZone = 120.0; // zone pouce depuis le bas
}
