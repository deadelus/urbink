import 'package:flutter/material.dart';

abstract final class UrbinkColors {
  // ── Palette principale ────────────────────────────────────────────────────
  /// Deep green — primary action, active states
  static const Color primary = Color(0xFF256F4C);
  /// Amber — accent, CTA secondaire (itinéraire, "C'est parti")
  static const Color accent = Color(0xFFF59E0B);
  /// Bright green — GPS dot when signal acquired (distinct from streetExplored)
  static const Color sessionGreen = Color(0xFF4ADE80);
  /// Text primary — alias for onSurface (WCAG: required on accent/amber backgrounds)
  static const Color textPrimary = Color(0xFF0F172A);
  /// Text muted — alias for navInactive
  static const Color textMuted = Color(0xFF64748B);

  // ── Surfaces ─────────────────────────────────────────────────────────────
  /// Fond général de l'app — light grey
  static const Color background = Color(0xFFF8FAFC);
  /// Surface des cartes / bottom sheets — blanc pur
  static const Color surface = Color(0xFFFFFFFF);
  /// Variante surface — très léger gris chaud pour les chips / inputs
  static const Color surfaceVariant = Color(0xFFF1F5F9);
  /// Brun profond → remplacé par Slate 900
  static const Color onSurface = Color(0xFF0F172A);

  // ── Rues ─────────────────────────────────────────────────────────────────
  static const Color streetExplored = Color(0xFF256F4C);
  static const Color streetRecording = Color(0xFF34A76A);

  // ── Feedback toasts ───────────────────────────────────────────────────────
  static const Color toastSuccess = Color(0xFF256F4C);
  static const Color toastInfo = Color(0xFF0F172A);
  static const Color toastError = Color(0xFFDC2626);
  static const Color toastWarning = Color(0xFFF59E0B);

  // ── Bouton destructif ─────────────────────────────────────────────────────
  static const Color destructive = Color(0xFFDC2626);

  // ── Navigation ────────────────────────────────────────────────────────────
  static const Color navInactive = Color(0xFF64748B);

  // ── Bottom sheet ─────────────────────────────────────────────────────────
  static const Color sheetScrim = Color(0xFF0F172A);
  static const Color sheetDragPill = Color(0xFFCBD5E1);

  // ── Empty states / fantôme ────────────────────────────────────────────────
  static const Color ghost = Color(0xFFF1F5F9);

  // ── Vert Sauge (ancienne valeur, gardée pour compatibilité) ───────────────
  static const Color secondary = Color(0xFF256F4C);

  // ── Séparateurs & bordures ────────────────────────────────────────────────
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderSubtle = Color(0xFFF1F5F9);
}
