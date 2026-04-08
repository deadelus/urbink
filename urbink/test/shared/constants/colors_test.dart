import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:urbink/shared/constants/colors.dart';

void main() {
  group('UrbinkColors — palette principale', () {
    test('primary = Ocre #B8832E', () {
      expect(UrbinkColors.primary, const Color(0xFFB8832E));
    });

    test('secondary = Vert Sauge #5A7A5A', () {
      expect(UrbinkColors.secondary, const Color(0xFF5A7A5A));
    });

    test('surface = Fond chaud #FAFAF7', () {
      expect(UrbinkColors.surface, const Color(0xFFFAFAF7));
    });

    test('onSurface = Brun Profond #1E1610', () {
      expect(UrbinkColors.onSurface, const Color(0xFF1E1610));
    });
  });

  group('UrbinkColors — rues', () {
    test('streetExplored = Vert Sauge #5A7A5A', () {
      expect(UrbinkColors.streetExplored, const Color(0xFF5A7A5A));
    });

    test('streetRecording = Vert animé #6A9A6A', () {
      expect(UrbinkColors.streetRecording, const Color(0xFF6A9A6A));
    });
  });

  group('UrbinkColors — toasts', () {
    test('toastSuccess #2D5A2D', () {
      expect(UrbinkColors.toastSuccess, const Color(0xFF2D5A2D));
    });

    test('toastInfo #1E1610', () {
      expect(UrbinkColors.toastInfo, const Color(0xFF1E1610));
    });

    test('toastError #8B2020', () {
      expect(UrbinkColors.toastError, const Color(0xFF8B2020));
    });

    test('toastWarning #7A5A1E', () {
      expect(UrbinkColors.toastWarning, const Color(0xFF7A5A1E));
    });
  });

  group('UrbinkColors — UI', () {
    test('destructive = Rouge #C0392B', () {
      expect(UrbinkColors.destructive, const Color(0xFFC0392B));
    });

    test('navInactive #8C7B6A', () {
      expect(UrbinkColors.navInactive, const Color(0xFF8C7B6A));
    });

    test('sheetScrim = Brun Profond #1E1610', () {
      expect(UrbinkColors.sheetScrim, const Color(0xFF1E1610));
    });

    test('sheetDragPill #D4C8B4', () {
      expect(UrbinkColors.sheetDragPill, const Color(0xFFD4C8B4));
    });

    test('ghost #F0EDE8', () {
      expect(UrbinkColors.ghost, const Color(0xFFF0EDE8));
    });

    test('surfaceVariant #F4F2ED', () {
      expect(UrbinkColors.surfaceVariant, const Color(0xFFF4F2ED));
    });
  });
}
