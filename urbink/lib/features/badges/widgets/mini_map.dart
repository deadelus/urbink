import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart' hide Path;
import 'package:urbink/shared/constants/colors.dart';

// ---------------------------------------------------------------------------
// MiniMap — carte stylisée V1 (CustomPainter, offline, déterministe)
//
// Représentation fictive de Paris : fond beige, grille de rues, Seine, parcs,
// et un pin positionné selon les coordonnées normalisées du monument.
// ---------------------------------------------------------------------------

// Bounding box Paris (approximatif)
const _latMin = 48.815;
const _latMax = 48.902;
const _lngMin = 2.224;
const _lngMax = 2.466;

double _normalizedX(LatLng ll) =>
    ((ll.longitude - _lngMin) / (_lngMax - _lngMin)).clamp(0.0, 1.0);
double _normalizedY(LatLng ll) =>
    (1.0 - (ll.latitude - _latMin) / (_latMax - _latMin)).clamp(0.0, 1.0);

class MiniMap extends StatelessWidget {
  const MiniMap({
    super.key,
    required this.monument,
    required this.accentColor,
    required this.arrondissement,
    required this.unlocked,
  });

  final LatLng? monument;
  final Color accentColor;
  final String arrondissement;
  final bool unlocked;

  @override
  Widget build(BuildContext context) {
    final nx = monument != null ? _normalizedX(monument!) : 0.5;
    final ny = monument != null ? _normalizedY(monument!) : 0.5;

    return Container(
      height: 140,
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: UrbinkColors.border),
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          // Carte peinte
          CustomPaint(
            painter: _MiniMapPainter(
              pinX: nx,
              pinY: ny,
              accentColor: accentColor,
              unlocked: unlocked,
            ),
            size: Size.infinite,
          ),

          // Pill arrondissement top-left
          if (arrondissement.isNotEmpty)
            Positioned(
              top: 8,
              left: 8,
              child: _MapPill(
                text: arrondissement,
                backgroundColor: Colors.white.withValues(alpha: 0.92),
                textColor: UrbinkColors.navInactive,
              ),
            ),

          // Pill "Visité ✓" top-right si débloqué
          if (unlocked)
            Positioned(
              top: 8,
              right: 8,
              child: _MapPill(
                text: 'Visité ✓',
                backgroundColor: accentColor,
                textColor: Colors.white,
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _MiniMapPainter
// ---------------------------------------------------------------------------

class _MiniMapPainter extends CustomPainter {
  const _MiniMapPainter({
    required this.pinX,
    required this.pinY,
    required this.accentColor,
    required this.unlocked,
  });

  final double pinX;
  final double pinY;
  final Color accentColor;
  final bool unlocked;

  // Coordonnées de référence pour le rendu (200×140)
  static const _refW = 200.0;
  static const _refH = 140.0;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / _refW, size.height / _refH);

    // 1. Fond beige carte
    canvas.drawRect(
      const Rect.fromLTWH(0, 0, _refW, _refH),
      Paint()..color = const Color(0xFFE8E4D8),
    );

    // 2. Grille de rues
    final gridPaint = Paint()
      ..color = const Color(0xFFCEC9BD).withValues(alpha: 0.7)
      ..strokeWidth = 0.5;
    for (final y in [30.0, 55.0, 80.0, 105.0]) {
      canvas.drawLine(Offset(0, y), Offset(_refW, y), gridPaint);
    }
    for (final x in [30.0, 70.0, 110.0, 150.0, 180.0]) {
      canvas.drawLine(Offset(x, 0), Offset(x, _refH), gridPaint);
    }

    // 3. Parcs
    final parkPaint = Paint()
      ..color = const Color(0xFFC5D5A8).withValues(alpha: 0.7);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          const Rect.fromLTWH(20, 92, 32, 22), const Radius.circular(3)),
      parkPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          const Rect.fromLTWH(140, 20, 28, 20), const Radius.circular(3)),
      parkPaint,
    );

    // 4. Seine (chemin quadratique)
    final seinePath = Path()
      ..moveTo(-5, 75)
      ..quadraticBezierTo(40, 82, 90, 72)
      ..quadraticBezierTo(140, 60, 200, 80);
    canvas.drawPath(
      seinePath,
      Paint()
        ..color = const Color(0xFFC8DFF0)
        ..strokeWidth = 9
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
    );

    // 5. Pin
    final px = pinX * _refW;
    final py = pinY * _refH;

    if (unlocked) {
      canvas.drawCircle(
          Offset(px, py), 22, Paint()..color = accentColor.withValues(alpha: 0.15));
      canvas.drawCircle(
          Offset(px, py), 14, Paint()..color = accentColor.withValues(alpha: 0.25));
    }

    final pinColor = unlocked ? accentColor : const Color(0xFF94A3B8);
    canvas.drawCircle(Offset(px, py), 9, Paint()..color = pinColor);
    canvas.drawCircle(
      Offset(px, py),
      9,
      Paint()
        ..color = Colors.white
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(_MiniMapPainter old) =>
      old.pinX != pinX ||
      old.pinY != pinY ||
      old.accentColor != accentColor ||
      old.unlocked != unlocked;
}

// ---------------------------------------------------------------------------
// _MapPill — petite étiquette superposée à la mini-carte
// ---------------------------------------------------------------------------

class _MapPill extends StatelessWidget {
  const _MapPill({
    required this.text,
    required this.backgroundColor,
    required this.textColor,
  });

  final String text;
  final Color backgroundColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}
