import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urbink/features/sessions/providers/gps_tracking_provider.dart';
import 'package:urbink/features/sessions/providers/session_metrics_provider.dart';
import 'package:urbink/features/sessions/session_state_provider.dart';
import 'package:urbink/shared/constants/colors.dart';
import 'package:urbink/shared/constants/typography.dart';

/// Pill flottant top-center affichant les métriques de la session en cours.
///
/// Affiché uniquement quand la session est active ou en pause.
/// Fond [UrbinkColors.onSurface] @ 85% d'opacité, mis à jour toutes les secondes.
///
/// Indicateur GPS :
///   - Vert fixe → signal acquis
///   - Orange pulsant → acquisition en cours (arrêté si `disableAnimations`)
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

    // Tick toutes les secondes — setState ignoré si la session est idle
    _tickSub = Stream<void>.periodic(const Duration(seconds: 1)).listen((_) {
      if (mounted && ref.read(sessionStateProvider) != SessionState.idle) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _tickSub?.cancel();
    super.dispose();
  }

  /// Contrôle le pulse : arrêté quand le signal GPS est acquis ou que
  /// l'utilisateur a activé "Réduire les animations".
  void _updatePulseAnimation({
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
  Widget build(BuildContext context) {
    final sessionState = ref.watch(sessionStateProvider);
    if (sessionState == SessionState.idle) return const SizedBox.shrink();

    final metrics = ref.watch(sessionMetricsProvider);
    final hasGpsSignal = ref.watch(gpsPositionStreamProvider).hasValue;
    final disableAnimations = MediaQuery.of(context).disableAnimations;

    _updatePulseAnimation(
      hasSignal: hasGpsSignal,
      disableAnimations: disableAnimations,
    );

    // Format HH:MM — conforme à la spec AC story 2.4
    final elapsed = metrics.elapsed;
    final h = elapsed.inHours.toString().padLeft(2, '0');
    final m = elapsed.inMinutes.remainder(60).toString().padLeft(2, '0');
    final timeStr = '$h:$m';

    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: UrbinkColors.onSurface.withValues(alpha: 0.85),
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
                      fontFamily: UrbinkTypography.bodyFamily,
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
          color: UrbinkColors.streetExplored, // Vert Sauge — signal acquis
          shape: BoxShape.circle,
        ),
      );
    }

    // Pulse orange — acquisition en cours
    // Le controller est déjà arrêté par le parent si disableAnimations == true :
    // on affiche alors un dot orange statique.
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
