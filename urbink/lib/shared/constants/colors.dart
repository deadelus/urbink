import 'package:flutter/material.dart';

abstract final class UrbinkColors {
  // Palette principale
  static const Color primary = Color(0xFFB8832E); // Ocre Chaud
  static const Color secondary = Color(0xFF5A7A5A); // Vert Sauge
  static const Color onSurface = Color(0xFF1E1610); // Brun Profond
  static const Color surface = Color(0xFFFAFAF7); // Fond chaud

  // Rues
  static const Color streetExplored = Color(0xFF5A7A5A); // Vert Sauge opacité 0.75
  static const Color streetRecording = Color(0xFF6A9A6A); // Vert animé

  // Feedback toasts
  static const Color toastSuccess = Color(0xFF2D5A2D);
  static const Color toastInfo = Color(0xFF1E1610);
  static const Color toastError = Color(0xFF8B2020);
  static const Color toastWarning = Color(0xFF7A5A1E);

  // Bouton destructif
  static const Color destructive = Color(0xFFC0392B);

  // Bottom nav inactif
  static const Color navInactive = Color(0xFF8C7B6A);

  // Bottom sheet
  static const Color sheetScrim = Color(0xFF1E1610); // @ 40% opacity
  static const Color sheetDragPill = Color(0xFFD4C8B4);

  // Empty states / fantôme
  static const Color ghost = Color(0xFFF0EDE8);
  static const Color surfaceVariant = Color(0xFFF4F2ED);
}
