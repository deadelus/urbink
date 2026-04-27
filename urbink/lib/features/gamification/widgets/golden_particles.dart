import 'dart:math';

import 'package:flutter/material.dart';

const _kGoldenEmojis = ['🏆', '✨', '⭐', '🌟', '🎯', '🥇'];

class _GoldenParticle {
  final double xFraction;
  final double delayMs;
  final String emoji;
  final double size;

  const _GoldenParticle({
    required this.xFraction,
    required this.delayMs,
    required this.emoji,
    required this.size,
  });
}

/// 28 emojis dorés animés qui tombent pour la célébration de quartier.
/// Désactivé si MediaQuery.disableAnimations.
class GoldenParticles extends StatefulWidget {
  const GoldenParticles({super.key});

  @override
  State<GoldenParticles> createState() => _GoldenParticlesState();
}

class _GoldenParticlesState extends State<GoldenParticles>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_GoldenParticle> _particles;

  @override
  void initState() {
    super.initState();
    final rng = Random();
    _particles = List.generate(28, (_) => _GoldenParticle(
          xFraction: rng.nextDouble(),
          delayMs: rng.nextDouble() * 800,
          emoji: _kGoldenEmojis[rng.nextInt(_kGoldenEmojis.length)],
          size: 14.0 + rng.nextDouble() * 18.0,
        ));
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).disableAnimations) return const SizedBox.shrink();

    final screenSize = MediaQuery.sizeOf(context);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final tMs = _controller.value * 3500;
        return Stack(
          children: _particles.map((p) {
            if (tMs < p.delayMs) return const SizedBox.shrink();

            final pt = ((tMs - p.delayMs) / 2700.0).clamp(0.0, 1.0);
            final easedY = Curves.easeIn.transform(pt);
            final y = easedY * (screenSize.height * 1.1 + 30) - 30;
            final x = p.xFraction * screenSize.width;
            final angle = easedY * 5 * pi;
            final opacity = (pt < 0.7) ? 1.0 : (1.0 - pt) / 0.3;

            return Positioned(
              left: x,
              top: y,
              child: Transform.rotate(
                angle: angle,
                child: Opacity(
                  opacity: opacity.clamp(0.0, 1.0),
                  child: Text(p.emoji, style: TextStyle(fontSize: p.size)),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
