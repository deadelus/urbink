import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urbink/features/sessions/providers/gps_tracking_provider.dart';
import 'package:urbink/features/sessions/providers/session_metrics_provider.dart';
import 'package:urbink/features/sessions/session_state_provider.dart';

/// Pill flottant top-center affichant les métriques de la session en cours.
///
/// Affiché uniquement quand la session est active ou en pause.
/// Fond #1E1610 @ 85% d'opacité, mis à jour toutes les secondes.
///
/// Indicateur GPS :
///   - Vert fixe → signal acquis
///   - Orange pulsant → acquisition en cours
class SessionCounter extends ConsumerStatefulWidget {
  const SessionCounter({super.key});

  @override
  ConsumerState<SessionCounter> createState() => _SessionCounterState();
}

class _SessionCounterState extends ConsumerState<SessionCounter>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  StreamSubscription<void>? _tickSub;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    // Mise à jour toutes les secondes pour le chronomètre HH:MM:SS
    _tickSub = Stream<void>.periodic(const Duration(seconds: 1)).listen((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _tickSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sessionState = ref.watch(sessionStateProvider);
    if (sessionState == SessionState.idle) return const SizedBox.shrink();

    final metrics = ref.watch(sessionMetricsProvider);
    final hasGpsSignal = ref.watch(gpsPositionStreamProvider).hasValue;

    final elapsed = metrics.elapsed;
    final h = elapsed.inHours;
    final m = elapsed.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = elapsed.inSeconds.remainder(60).toString().padLeft(2, '0');
    final timeStr = h > 0 ? '$h:$m:$s' : '$m:$s';

    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0xFF1E1610).withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _GpsSignalDot(
                    hasSignal: hasGpsSignal,
                    pulseController: _pulseController,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${metrics.streetCount} rues · '
                    '${metrics.distanceKm.toStringAsFixed(1)}km · '
                    '$timeStr',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GpsSignalDot extends StatelessWidget {
  final bool hasSignal;
  final AnimationController pulseController;

  const _GpsSignalDot({
    required this.hasSignal,
    required this.pulseController,
  });

  @override
  Widget build(BuildContext context) {
    if (hasSignal) {
      return Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: Color(0xFF5A7A5A), // Vert Sauge — signal acquis
          shape: BoxShape.circle,
        ),
      );
    }

    return AnimatedBuilder(
      animation: pulseController,
      builder: (_, _) => Opacity(
        opacity: 0.35 + 0.65 * pulseController.value,
        child: Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: Colors.orange, // Pulse orange — acquisition en cours
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
