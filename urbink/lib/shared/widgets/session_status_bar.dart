import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urbink/features/sessions/providers/gps_tracking_provider.dart';
import 'package:urbink/features/sessions/providers/session_metrics_provider.dart';
import 'package:urbink/features/sessions/session_state_provider.dart';
import 'package:urbink/shared/constants/colors.dart';
import 'package:urbink/shared/constants/typography.dart';

/// Barre de statut session v4 — 44px position absolue haut de carte.
///
/// Fond Primary #256F4C (circuit libre et itinéraire).
/// Format : [GPS dot] X.Xkm · N rues · HH:MM [mode emoji]
///
/// GPS dot : sessionGreen #4ADE80 fixe = signal acquis, orange pulsant = acquisition en cours.
class SessionStatusBar extends ConsumerStatefulWidget {
  const SessionStatusBar({super.key});

  @override
  ConsumerState<SessionStatusBar> createState() => _SessionStatusBarState();
}

class _SessionStatusBarState extends ConsumerState<SessionStatusBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  void _syncTimer(SessionState sessionState) {
    if (sessionState == SessionState.idle) {
      _timer?.cancel();
      _timer = null;
    } else {
      _timer ??= Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() {});
      });
    }
  }

  void _updatePulse({
    required bool hasSignal,
    required bool disableAnimations,
  }) {
    if (hasSignal || disableAnimations) {
      if (_pulseController.isAnimating) _pulseController.stop();
    } else if (!_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sessionState = ref.watch(sessionStateProvider);
    _syncTimer(sessionState);

    if (sessionState == SessionState.idle) return const SizedBox.shrink();

    final metrics = ref.watch(sessionMetricsProvider);
    final hasGpsSignal = ref.watch(gpsPositionStreamProvider).hasValue;
    final detectedMode = ref.watch(autoDetectedModeProvider);
    final disableAnimations = MediaQuery.of(context).disableAnimations;

    _updatePulse(hasSignal: hasGpsSignal, disableAnimations: disableAnimations);

    final elapsed = metrics.elapsed;
    final h = elapsed.inHours.toString().padLeft(2, '0');
    final m = elapsed.inMinutes.remainder(60).toString().padLeft(2, '0');
    final timeStr = '$h:$m';
    final distanceStr = '${metrics.distanceKm.toStringAsFixed(1)}km';

    return Semantics(
      label:
          'Session en cours : ${metrics.streetCount} rues, $distanceStr, $timeStr',
      child: Container(
        height: 44,
        color: UrbinkColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            _GpsSignalDot(
              hasSignal: hasGpsSignal,
              pulseController: _pulseController,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Circuit libre · ${metrics.streetCount} rues · $distanceStr',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontFamily: UrbinkTypography.bodyFamily,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              '$timeStr ${detectedMode.emoji}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontFamily: UrbinkTypography.bodyFamily,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
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
          color: UrbinkColors.sessionGreen,
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
            color: Colors.orange,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
