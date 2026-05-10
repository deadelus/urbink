import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:urbink/features/profile/data/explorer_rank.dart';

// ---------------------------------------------------------------------------
// GemWidget — emblème gemme pour le rang d'explorateur
// Style glyph : cercle sombre + halo radial + bordure colorée + initiale
// ---------------------------------------------------------------------------

class GemWidget extends StatelessWidget {
  const GemWidget({super.key, required this.rank, this.size = 72});

  final ExplorerRank rank;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _GemPainter(rank: rank),
      ),
    );
  }
}

class _GemPainter extends CustomPainter {
  const _GemPainter({required this.rank});

  final ExplorerRank rank;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerR = size.width / 2;
    final bodyR = outerR * 0.70;

    // 1. Halo radial (teinté couleur pierre)
    final haloPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          rank.haloColor.withValues(alpha: 0.28),
          rank.haloColor.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: outerR));
    canvas.drawCircle(center, outerR, haloPaint);

    // 2. Corps sombre (gradient radial centré haut-gauche)
    final bodyRect = Rect.fromCircle(center: center, radius: bodyR);
    final bodyPaint = Paint()
      ..shader = const RadialGradient(
        center: Alignment(-0.4, -0.4),
        colors: [Color(0xFF2D2D30), Color(0xFF0F0F12)],
      ).createShader(bodyRect);
    canvas.drawCircle(center, bodyR, bodyPaint);

    // 3. Bordure colorée principale
    canvas.drawCircle(
      center,
      bodyR,
      Paint()
        ..color = rank.haloColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // 4. Anneau intérieur subtil
    canvas.drawCircle(
      center,
      bodyR * 0.84,
      Paint()
        ..color = rank.haloColor.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.7,
    );

    // 5. Reflet spéculaire (arc blanc haut-gauche)
    final specPath = Path()
      ..addArc(
        Rect.fromCircle(center: center, radius: bodyR * 0.82),
        math.pi * 1.15,
        math.pi * 0.45,
      );
    canvas.drawPath(
      specPath,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.20)
        ..style = PaintingStyle.stroke
        ..strokeWidth = bodyR * 0.18
        ..strokeCap = StrokeCap.round,
    );

    // 6. Initiale (TextPainter)
    final fontSize = bodyR * 0.58;
    final tp = TextPainter(
      text: TextSpan(
        text: rank.initial,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w800,
          color: rank.haloColor,
          height: 1.0,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
      canvas,
      center - Offset(tp.width / 2, tp.height / 2),
    );
  }

  @override
  bool shouldRepaint(_GemPainter old) => old.rank != rank;
}
