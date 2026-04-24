import 'dart:math';

import 'package:flutter/material.dart';

const _kEmojis = ['🎉', '⭐', '✨', '🏆', '🎊'];

class _Particle {
  final double xFraction;
  final double delayMs;
  final String emoji;
  final double size;

  const _Particle({
    required this.xFraction,
    required this.delayMs,
    required this.emoji,
    required this.size,
  });
}

/// 24 emojis animés qui tombent — désactivé si MediaQuery.disableAnimations.
class CelebrationParticles extends StatefulWidget {
  const CelebrationParticles({super.key});

  @override
  State<CelebrationParticles> createState() => _CelebrationParticlesState();
}

class _CelebrationParticlesState extends State<CelebrationParticles>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    final rng = Random();
    _particles = List.generate(24, (_) => _Particle(
          xFraction: rng.nextDouble(),
          delayMs: rng.nextDouble() * 500,
          emoji: _kEmojis[rng.nextInt(_kEmojis.length)],
          size: 12.0 + rng.nextDouble() * 16.0,
        ));
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
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
        final tMs = _controller.value * 2500;
        return Stack(
          children: _particles.map((p) {
            if (tMs < p.delayMs) return const SizedBox.shrink();

            final pt = ((tMs - p.delayMs) / 2000.0).clamp(0.0, 1.0);
            final easedY = Curves.easeIn.transform(pt);
            final y = easedY * (screenSize.height * 1.1 + 30) - 30;
            final x = p.xFraction * screenSize.width;
            final angle = easedY * 4 * pi;
            final opacity = (pt < 0.75) ? 1.0 : (1.0 - pt) / 0.25;

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
