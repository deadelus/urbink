import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:urbink/features/sessions/models/session_data.dart';
import 'package:urbink/features/sessions/widgets/pulse_dot.dart';
import 'package:urbink/features/sessions/widgets/session_stat_card.dart';
import 'package:urbink/l10n/app_localizations.dart';
import 'package:urbink/shared/constants/colors.dart';
import 'package:urbink/shared/constants/typography.dart';

// Vert #10B981 — token spécifique au live indicator, non dérivé du thème.
const _kLiveGreen = Color(0xFF10B981);

/// Moniteur de session en temps réel affiché dans la bottom sheet pendant
/// une sortie active. Stateless — le parent pousse une nouvelle [SessionData]
/// chaque seconde.
class SessionMonitor extends StatelessWidget {
  final SessionData session;

  /// 'libre' | 'itineraire'
  final String mode;

  /// true = afficher la section progression + astuce.
  final bool expanded;
  final VoidCallback onStop;

  /// null = pas de carte astuce.
  final String? tipText;

  const SessionMonitor({
    super.key,
    required this.session,
    required this.mode,
    required this.expanded,
    required this.onStop,
    this.tipText,
  });

  static String _formatTimer(int secs) {
    final m = (secs ~/ 60).toString().padLeft(2, '0');
    final s = (secs % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  static String _formatPace(double km, int secs) {
    if (km <= 0) return "--'--\"";
    final paceSeconds = secs / km;
    int paceMin = (paceSeconds / 60).floor();
    int paceSec = (paceSeconds % 60).round();
    if (paceSec == 60) {
      paceMin++;
      paceSec = 0;
    }
    return "$paceMin'${paceSec.toString().padLeft(2, '0')}\"";
  }

  String _modeLabel(AppLocalizations l10n) {
    if (mode == 'itineraire') return '🗺 ${l10n.mode_itinerary}';
    return '🚶 ${l10n.mode_libre}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Header live indicator ────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
          child: Row(
            children: [
              const PulseDot(color: _kLiveGreen),
              const SizedBox(width: 8),
              Text(
                l10n.session_live.toUpperCase(),
                style: const TextStyle(
                  fontFamily: UrbinkTypography.bodyFamily,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                  color: _kLiveGreen,
                ),
              ),
              const Spacer(),
              Text(
                _modeLabel(l10n),
                style: const TextStyle(
                  fontFamily: UrbinkTypography.bodyFamily,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: UrbinkColors.textMuted,
                ),
              ),
            ],
          ),
        ),

        // ── Timer principal ──────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            children: [
              Semantics(
                liveRegion: true,
                child: session.sessionStartTime != null
                    ? _LiveTimerDisplay(startTime: session.sessionStartTime!)
                    : Text(
                        _formatTimer(session.secs),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: UrbinkTypography.bodyFamily,
                          fontSize: 48,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -1,
                          fontFeatures: [FontFeature.tabularFigures()],
                          color: UrbinkColors.onSurface,
                        ),
                      ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.session_duration.toUpperCase(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: UrbinkTypography.bodyFamily,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.6,
                  color: UrbinkColors.textMuted,
                ),
              ),
            ],
          ),
        ),

        // ── Stats grid ───────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: SessionStatCard(
                  value: session.km.toStringAsFixed(2),
                  label: 'KM',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SessionStatCard(
                  value: '${session.streets}',
                  label: l10n.streets.toUpperCase(),
                  highlight: true,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SessionStatCard(
                  value: _formatPace(session.km, session.secs),
                  label: l10n.pace.toUpperCase(),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // ── Bouton Arrêter ───────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Semantics(
            button: true,
            label: l10n.btn_stop,
            child: GestureDetector(
              key: const Key('session_monitor_stop_button'),
              onTap: () {
                HapticFeedback.mediumImpact();
                onStop();
              },
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: UrbinkColors.destructive,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x59DC2626),
                      blurRadius: 14,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.stop, color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      l10n.btn_stop,
                      style: const TextStyle(
                        fontFamily: UrbinkTypography.bodyFamily,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // ── Progression en direct (expanded uniquement) ──────────────────────
        if (expanded) ...[
          _ProgressSection(
            key: const Key('session_monitor_progress_section'),
            session: session,
            l10n: l10n,
            colorScheme: colorScheme,
          ),
          if (tipText != null)
            _TipCard(
              key: const Key('session_monitor_tip_card'),
              tipText: tipText!,
              l10n: l10n,
              colorScheme: colorScheme,
            ),
        ],
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Section progression en direct
// ---------------------------------------------------------------------------

class _ProgressSection extends StatelessWidget {
  final SessionData session;
  final AppLocalizations l10n;
  final ColorScheme colorScheme;

  const _ProgressSection({
    super.key,
    required this.session,
    required this.l10n,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 18, bottom: 10),
            child: Text(
              l10n.live_progress,
              style: const TextStyle(
                fontFamily: UrbinkTypography.bodyFamily,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: UrbinkColors.onSurface,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: UrbinkColors.surfaceVariant,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.zone_progress,
                      style: const TextStyle(
                        fontFamily: UrbinkTypography.bodyFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: UrbinkColors.onSurface,
                      ),
                    ),
                    Text(
                      '${session.zonePercent}%',
                      style: const TextStyle(
                        fontFamily: UrbinkTypography.bodyFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: UrbinkColors.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: session.zonePercent / 100),
                  duration: const Duration(milliseconds: 600),
                  builder: (context, value, _) => LinearProgressIndicator(
                    value: value,
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(3),
                    backgroundColor: UrbinkColors.border,
                    valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                  ),
                ),
                const SizedBox(height: 12),
                const Divider(height: 1, thickness: 1, color: UrbinkColors.border),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '🏆 ${l10n.new_streets.toUpperCase()}',
                            style: const TextStyle(
                              fontFamily: UrbinkTypography.bodyFamily,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.4,
                              color: UrbinkColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '+${session.newStreets}',
                            style: TextStyle(
                              fontFamily: UrbinkTypography.bodyFamily,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '⚡ ${l10n.calories.toUpperCase()}',
                            style: const TextStyle(
                              fontFamily: UrbinkTypography.bodyFamily,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.4,
                              color: UrbinkColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${session.calories} kcal',
                            style: const TextStyle(
                              fontFamily: UrbinkTypography.bodyFamily,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: UrbinkColors.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Horloge auto-contenue — gère son propre Timer.periodic indépendamment
// du cycle de rebuild du parent.
// ---------------------------------------------------------------------------

class _LiveTimerDisplay extends StatefulWidget {
  final DateTime startTime;
  const _LiveTimerDisplay({required this.startTime});

  @override
  State<_LiveTimerDisplay> createState() => _LiveTimerDisplayState();
}

class _LiveTimerDisplayState extends State<_LiveTimerDisplay> {
  late Timer _timer;
  late int _secs;

  @override
  void initState() {
    super.initState();
    _secs = DateTime.now().difference(widget.startTime).inSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _secs = DateTime.now().difference(widget.startTime).inSeconds;
        });
      }
    });
  }

  @override
  void didUpdateWidget(_LiveTimerDisplay old) {
    super.didUpdateWidget(old);
    if (widget.startTime != old.startTime) {
      _timer.cancel();
      _secs = DateTime.now().difference(widget.startTime).inSeconds;
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) {
          setState(() {
            _secs = DateTime.now().difference(widget.startTime).inSeconds;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      SessionMonitor._formatTimer(_secs),
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontFamily: UrbinkTypography.bodyFamily,
        fontSize: 48,
        fontWeight: FontWeight.w800,
        letterSpacing: -1,
        fontFeatures: [FontFeature.tabularFigures()],
        color: UrbinkColors.onSurface,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Carte astuce contextuelle
// ---------------------------------------------------------------------------

class _TipCard extends StatelessWidget {
  final String tipText;
  final AppLocalizations l10n;
  final ColorScheme colorScheme;

  const _TipCard({
    super.key,
    required this.tipText,
    required this.l10n,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final primary = colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: primary.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: primary.withValues(alpha: 0.22)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('💡', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.tip_title,
                    style: const TextStyle(
                      fontFamily: UrbinkTypography.bodyFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: UrbinkColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    tipText,
                    style: const TextStyle(
                      fontFamily: UrbinkTypography.bodyFamily,
                      fontSize: 11,
                      color: UrbinkColors.textMuted,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
