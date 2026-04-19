import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:urbink/shared/constants/colors.dart';

void main() {
  group('UrbinkColors — palette principale', () {
    test('primary = Deep Green #256F4C', () {
      expect(UrbinkColors.primary, const Color(0xFF256F4C));
    });

    test('secondary = Deep Green #256F4C', () {
      expect(UrbinkColors.secondary, const Color(0xFF256F4C));
    });

    test('surface = Blanc pur #FFFFFF', () {
      expect(UrbinkColors.surface, const Color(0xFFFFFFFF));
    });

    test('onSurface = Slate 900 #0F172A', () {
      expect(UrbinkColors.onSurface, const Color(0xFF0F172A));
    });
  });

  group('UrbinkColors — rues', () {
    test('streetExplored = Deep Green #256F4C', () {
      expect(UrbinkColors.streetExplored, const Color(0xFF256F4C));
    });

    test('streetRecording = Vert animé #34A76A', () {
      expect(UrbinkColors.streetRecording, const Color(0xFF34A76A));
    });
  });

  group('UrbinkColors — toasts', () {
    test('toastSuccess #256F4C', () {
      expect(UrbinkColors.toastSuccess, const Color(0xFF256F4C));
    });

    test('toastInfo #0F172A', () {
      expect(UrbinkColors.toastInfo, const Color(0xFF0F172A));
    });

    test('toastError #DC2626', () {
      expect(UrbinkColors.toastError, const Color(0xFFDC2626));
    });

    test('toastWarning #F59E0B', () {
      expect(UrbinkColors.toastWarning, const Color(0xFFF59E0B));
    });
  });

  group('UrbinkColors — UI', () {
    test('destructive = Rouge #DC2626', () {
      expect(UrbinkColors.destructive, const Color(0xFFDC2626));
    });

    test('navInactive #64748B', () {
      expect(UrbinkColors.navInactive, const Color(0xFF64748B));
    });

    test('sheetScrim = Slate 900 #0F172A', () {
      expect(UrbinkColors.sheetScrim, const Color(0xFF0F172A));
    });

    test('sheetDragPill #CBD5E1', () {
      expect(UrbinkColors.sheetDragPill, const Color(0xFFCBD5E1));
    });

    test('ghost #F1F5F9', () {
      expect(UrbinkColors.ghost, const Color(0xFFF1F5F9));
    });

    test('surfaceVariant #F1F5F9', () {
      expect(UrbinkColors.surfaceVariant, const Color(0xFFF1F5F9));
    });
  });
}
