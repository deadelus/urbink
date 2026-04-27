import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:urbink/features/gamification/widgets/golden_particles.dart';
import 'package:urbink/l10n/app_localizations.dart';
import 'package:urbink/shared/constants/typography.dart';

const _kScrimStrong = Color(0xD90F172A);
const _kGoldColor = Color(0xFFF59E0B);
const _kGoldDark = Color(0xFFB45309);
const _kAutoDismissSeconds = 5;

/// Overlay plein écran célébrant la complétion d'un quartier.
///
/// Affiché via [showQuartierCelebration]. Auto-dismiss après 5s.
/// [onShare] et [onContinue] sont appelés sur les boutons correspondants.
class QuartierCelebrationOverlay extends StatefulWidget {
  final String quartierName;
  final String secretLocal;
  final VoidCallback? onShare;
  final VoidCallback onContinue;

  const QuartierCelebrationOverlay({
    super.key,
    required this.quartierName,
    required this.secretLocal,
    this.onShare,
    required this.onContinue,
  });

  @override
  State<QuartierCelebrationOverlay> createState() =>
      _QuartierCelebrationOverlayState();
}

class _QuartierCelebrationOverlayState
    extends State<QuartierCelebrationOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  late Animation<double> _overlayFade;
  late Animation<double> _iconScale;
  late Animation<double> _iconOpacity;
  late Animation<double> _titleSlide;
  late Animation<double> _titleFade;
  late Animation<double> _secretFade;
  late Animation<double> _actionsFade;

  bool _exiting = false;
  Timer? _autoDismissTimer;
  Timer? _hapticTimer;
  int _countdown = _kAutoDismissSeconds;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _overlayFade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
    );
    _iconOpacity = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.1, 0.7, curve: Curves.easeOut),
    );
    _iconScale = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.1, 0.7, curve: Cubic(0.34, 1.56, 0.64, 1)),
    );
    _titleFade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.3, 0.7, curve: Curves.easeOut),
    );
    _titleSlide = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.3, 0.7, curve: Curves.easeOut),
    );
    _secretFade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.5, 0.9, curve: Curves.easeOut),
    );
    _actionsFade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.75, 1.0, curve: Curves.easeOut),
    );

    _ctrl.forward();

    HapticFeedback.heavyImpact();
    _hapticTimer = Timer(const Duration(milliseconds: 500), () {
      if (mounted) HapticFeedback.mediumImpact();
    });

    _autoDismissTimer = Timer(
      const Duration(seconds: _kAutoDismissSeconds),
      () {
        if (mounted) _dismiss(widget.onContinue);
      },
    );

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() => _countdown--);
      if (_countdown <= 0) t.cancel();
    });
  }

  @override
  void dispose() {
    _autoDismissTimer?.cancel();
    _hapticTimer?.cancel();
    _countdownTimer?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _dismiss(VoidCallback callback) async {
    if (_exiting) return;
    setState(() => _exiting = true);
    _autoDismissTimer?.cancel();
    _countdownTimer?.cancel();
    await _ctrl.animateBack(
      0,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeIn,
    );
    callback();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    return Material(
      type: MaterialType.transparency,
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (_, _) =>
            _dismiss(widget.onContinue),
        child: Semantics(
          liveRegion: true,
          label: l10n.celeb_district_semantics(widget.quartierName),
          child: AnimatedBuilder(
            animation: _ctrl,
            builder: (context, child) {
              final opacity = reduceMotion ? 1.0 : _overlayFade.value;
              return Opacity(
                opacity: opacity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                      child: Container(color: _kScrimStrong),
                    ),
                    const GoldenParticles(),
                    SafeArea(
                      child: GestureDetector(
                        onTap: () {},
                        behavior: HitTestBehavior.opaque,
                        child: Column(
                          children: [
                            const Spacer(),

                            // Trophy icon animated
                            _AnimatedTrophy(
                              scaleAnim: _iconScale,
                              opacityAnim: _iconOpacity,
                              reduceMotion: reduceMotion,
                            ),

                            const SizedBox(height: 24),

                            // Title
                            Opacity(
                              opacity: reduceMotion ? 1.0 : _titleFade.value,
                              child: Transform.translate(
                                offset: Offset(
                                  0,
                                  reduceMotion
                                      ? 0
                                      : (1.0 - _titleSlide.value) * 12,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 32),
                                  child: Text(
                                    l10n.celeb_district_title(
                                        widget.quartierName),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontFamily:
                                          UrbinkTypography.displayFamily,
                                      fontSize: 26,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      height: 1.3,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Secret local card
                            Opacity(
                              opacity: reduceMotion ? 1.0 : _secretFade.value,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1E293B),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: _kGoldColor.withValues(alpha: 0.4),
                                      width: 1,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Text('🗝️',
                                              style:
                                                  TextStyle(fontSize: 16)),
                                          const SizedBox(width: 6),
                                          Text(
                                            l10n.celeb_secret_local_label,
                                            style: const TextStyle(
                                              fontFamily:
                                                  UrbinkTypography.bodyFamily,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: _kGoldColor,
                                              letterSpacing: 0.8,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        widget.secretLocal,
                                        style: const TextStyle(
                                          fontFamily:
                                              UrbinkTypography.bodyFamily,
                                          fontSize: 13,
                                          color: Color(0xCCFFFFFF),
                                          height: 1.6,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            const Spacer(),

                            // Actions
                            Opacity(
                              opacity: reduceMotion ? 1.0 : _actionsFade.value,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24),
                                child: Column(
                                  children: [
                                    if (widget.onShare != null)
                                      SizedBox(
                                        width: double.infinity,
                                        height: 52,
                                        child: OutlinedButton(
                                          onPressed: () =>
                                              _dismiss(widget.onShare!),
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: _kGoldColor,
                                            side: const BorderSide(
                                                color: _kGoldColor, width: 1.5),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                          ),
                                          child: Text(
                                            l10n.celeb_share,
                                            style: const TextStyle(
                                              fontFamily:
                                                  UrbinkTypography.bodyFamily,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ),
                                      ),
                                    const SizedBox(height: 12),
                                    SizedBox(
                                      width: double.infinity,
                                      height: 52,
                                      child: FilledButton(
                                        onPressed: () =>
                                            _dismiss(widget.onContinue),
                                        style: FilledButton.styleFrom(
                                          backgroundColor: _kGoldDark,
                                          foregroundColor: Colors.white,
                                          elevation: 4,
                                          shadowColor: _kGoldColor
                                              .withValues(alpha: 0.35),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                          ),
                                        ),
                                        child: Text(
                                          '${l10n.celeb_continue}'
                                          '${_countdown > 0 ? ' ($_countdown)' : ''}',
                                          style: const TextStyle(
                                            fontFamily:
                                                UrbinkTypography.bodyFamily,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 32),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _AnimatedTrophy extends StatelessWidget {
  const _AnimatedTrophy({
    required this.scaleAnim,
    required this.opacityAnim,
    required this.reduceMotion,
  });

  final Animation<double> scaleAnim;
  final Animation<double> opacityAnim;
  final bool reduceMotion;

  @override
  Widget build(BuildContext context) {
    final scale = reduceMotion ? 1.0 : 0.5 + scaleAnim.value * 0.5;
    final opacity = reduceMotion ? 1.0 : opacityAnim.value;

    return Opacity(
      opacity: opacity,
      child: Transform.scale(
        scale: scale,
        child: Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _kGoldColor.withValues(alpha: 0.15),
            border: Border.all(
              color: _kGoldColor.withValues(alpha: 0.5),
              width: 2,
            ),
          ),
          child: const Center(
            child: Text('🏆', style: TextStyle(fontSize: 52)),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------

/// Affiche [QuartierCelebrationOverlay] via [showGeneralDialog] (rootNavigator).
///
/// Retourne `true` si l'utilisateur a tapé "Partager", `false` sinon.
Future<bool> showQuartierCelebration({
  required BuildContext context,
  required String quartierName,
  required String secretLocal,
}) async {
  bool shared = false;

  await showGeneralDialog<void>(
    context: context,
    useRootNavigator: true,
    barrierDismissible: false,
    barrierColor: Colors.transparent,
    pageBuilder: (ctx, _, _) => QuartierCelebrationOverlay(
      quartierName: quartierName,
      secretLocal: secretLocal,
      onShare: () {
        shared = true;
        Navigator.of(ctx, rootNavigator: true).pop();
      },
      onContinue: () => Navigator.of(ctx, rootNavigator: true).pop(),
    ),
    transitionDuration: Duration.zero,
  );

  return shared;
}
