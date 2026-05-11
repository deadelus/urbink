import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart' hide Path;
import 'package:urbink/shared/constants/colors.dart';

enum RouteMapVariant { small, medium, thumbnail }

/// Aperçu miniature d'un tracé de parcours.
///
/// Variantes :
/// - [RouteMapVariant.small] : 176×85px (cards, FeedActivityItem)
/// - [RouteMapVariant.medium] : full-width 16:9 (écran détail parcours)
/// - [RouteMapVariant.thumbnail] : 48×48px (ListTile compact)
class RouteMapPreview extends StatelessWidget {
  const RouteMapPreview({
    super.key,
    required this.points,
    this.variant = RouteMapVariant.small,
    this.isSession = false,
  });

  final List<LatLng> points;
  final RouteMapVariant variant;

  /// `true` → polyline Vert Sauge (sortie/session), `false` → Ocre (itinéraire planifié).
  final bool isSession;

  @override
  Widget build(BuildContext context) {
    final radius = variant == RouteMapVariant.thumbnail
        ? const BorderRadius.all(Radius.circular(6))
        : const BorderRadius.all(Radius.circular(8));

    final child = ClipRRect(
      borderRadius: radius,
      child: CustomPaint(
        painter: _RouteMapPainter(
          points: points,
          variant: variant,
          isSession: isSession,
        ),
      ),
    );

    return switch (variant) {
      RouteMapVariant.small => SizedBox(width: 176, height: 85, child: child),
      RouteMapVariant.medium => AspectRatio(
          aspectRatio: 16 / 9,
          child: SizedBox(width: double.infinity, child: child),
        ),
      RouteMapVariant.thumbnail =>
        SizedBox(width: 48, height: 48, child: child),
    };
  }
}

class _RouteMapPainter extends CustomPainter {
  const _RouteMapPainter({
    required this.points,
    required this.variant,
    required this.isSession,
  });

  final List<LatLng> points;
  final RouteMapVariant variant;
  final bool isSession;

  static const Color _background = Color(0xFFFAF9F7);

  double get _padding => variant == RouteMapVariant.medium ? 12.0 : 6.0;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = _background,
    );

    if (points.length < 2) return;

    final normalized = _normalize(size);
    _drawPolyline(canvas, normalized);
    _drawEndpoints(canvas, normalized);
  }

  List<Offset> _normalize(Size size) {
    final pad = _padding;
    final drawW = size.width - pad * 2;
    final drawH = size.height - pad * 2;

    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (final p in points) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }

    final latRange = maxLat - minLat;
    final lngRange = maxLng - minLng;

    // Preserve aspect ratio — pick the tightest scale
    final double scaleX = lngRange == 0 ? 1 : drawW / lngRange;
    final double scaleY = latRange == 0 ? 1 : drawH / latRange;
    final double scale = math.min(scaleX, scaleY);

    final offsetX = pad + (drawW - lngRange * scale) / 2;
    final offsetY = pad + (drawH - latRange * scale) / 2;

    return points.map((p) {
      final x = offsetX + (p.longitude - minLng) * scale;
      // Flip Y: lat increases up, pixel Y increases down
      final y = offsetY + (maxLat - p.latitude) * scale;
      return Offset(x, y);
    }).toList();
  }

  void _drawPolyline(Canvas canvas, List<Offset> pts) {
    final color = isSession ? UrbinkColors.streetExplored : UrbinkColors.ocre;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final path = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (int i = 1; i < pts.length; i++) {
      path.lineTo(pts[i].dx, pts[i].dy);
    }
    canvas.drawPath(path, paint);
  }

  void _drawEndpoints(Canvas canvas, List<Offset> pts) {
    final r = variant == RouteMapVariant.thumbnail ? 3.0 : 4.0;

    canvas.drawCircle(
      pts.first,
      r,
      Paint()..color = UrbinkColors.sessionGreen,
    );
    canvas.drawCircle(
      pts.last,
      r,
      Paint()..color = UrbinkColors.ocre,
    );
  }

  @override
  bool shouldRepaint(_RouteMapPainter old) =>
      !listEquals(old.points, points) ||
      old.variant != variant ||
      old.isSession != isSession;
}
