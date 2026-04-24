import 'package:flutter/material.dart';

/// Point animé (scale 1→1.3, opacity 1→0.5, 1.5s) pour l'indicateur live.
/// L'animation est désactivée si MediaQuery.disableAnimations est true.
class PulseDot extends StatefulWidget {
  final Color color;
  final double size;

  const PulseDot({super.key, required this.color, this.size = 8.0});

  @override
  State<PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<PulseDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    final curved =
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _scale = Tween<double>(begin: 1.0, end: 1.3).animate(curved);
    _opacity = Tween<double>(begin: 1.0, end: 0.5).animate(curved);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final disable = MediaQuery.of(context).disableAnimations;
    if (disable) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).disableAnimations) {
      return _dot(1.0, 1.0);
    }
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, _) => _dot(_scale.value, _opacity.value),
    );
  }

  Widget _dot(double scale, double opacity) => Opacity(
        opacity: opacity,
        child: Transform.scale(
          scale: scale,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: widget.color,
              shape: BoxShape.circle,
            ),
          ),
        ),
      );
}
