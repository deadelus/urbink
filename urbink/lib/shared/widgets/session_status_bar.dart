import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urbink/features/sessions/models/transport_mode.dart';
import 'package:urbink/features/sessions/providers/session_metrics_provider.dart';
import 'package:urbink/features/sessions/session_state_provider.dart';
import 'package:urbink/shared/constants/colors.dart';

/// Barre de statut session — placeholder minimal Terra Cotta.
///
/// Affichée en position absolute top (après safe area) quand une session
/// circuit libre est active. Hauteur fixe 44px.
///
/// ⚠️ Story 2.10 remplace entièrement ce composant (SessionStatusBar v4
/// avec auto-détection mode, design spec complet). Garder minimal.
class SessionStatusBar extends ConsumerStatefulWidget {
  const SessionStatusBar({super.key});

  @override
  ConsumerState<SessionStatusBar> createState() => _SessionStatusBarState();
}

class _SessionStatusBarState extends ConsumerState<SessionStatusBar> {
  Timer? _timer;

  void _startTimer() {
    if (_timer != null) return;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _syncTimer(SessionState sessionState) {
    if (sessionState == SessionState.idle) {
      _stopTimer();
    } else {
      _startTimer();
    }
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sessionState = ref.watch(sessionStateProvider);
    // Démarrer/arrêter le tick selon l'état — pas de rebuild inutile quand idle
    _syncTimer(sessionState);

    if (sessionState == SessionState.idle) return const SizedBox.shrink();

    final metrics = ref.watch(sessionMetricsProvider);
    final detectedMode = ref.watch(autoDetectedModeProvider);
    final elapsed = metrics.elapsed;
    final hours = elapsed.inHours;
    final minutes = elapsed.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = elapsed.inSeconds.remainder(60).toString().padLeft(2, '0');
    final durationLabel = hours > 0
        ? '$hours:$minutes:$seconds'
        : '$minutes:$seconds';

    final distanceLabel = metrics.distanceKm >= 1.0
        ? '${metrics.distanceKm.toStringAsFixed(1)} km'
        : '${metrics.distanceMeters.toStringAsFixed(0)} m';

    return Semantics(
      label: 'Session en cours : ${metrics.streetCount} rues, $distanceLabel, $durationLabel',
      child: Container(
        height: 44,
        color: UrbinkColors.terraCotta,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_modeEmoji(detectedMode), style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Text(
              '${metrics.streetCount} rues · $distanceLabel · $durationLabel',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _modeEmoji(TransportMode mode) => switch (mode) {
        TransportMode.walking => '🚶',
        TransportMode.cycling => '🚴',
        TransportMode.driving => '🚗',
      };
}
