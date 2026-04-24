import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:urbink/features/session_end/models/badge_unlock.dart';
import 'package:urbink/features/session_end/widgets/badge_medal.dart';
import 'package:urbink/features/session_end/widgets/celebration_particles.dart';
import 'package:urbink/l10n/app_localizations.dart';
import 'package:urbink/shared/constants/colors.dart';
import 'package:urbink/shared/constants/typography.dart';

const _kScrimStrong = Color(0xD90F172A); // rgba(15,23,42,.85)

/// Overlay plein écran animé célébrant un badge débloqué.
///
/// Affiché via [showGeneralDialog] (rootNavigator: true) pour passer
/// au-dessus du bottom nav et de la carte.
///
/// [onDone] est appelé une fois l'animation de sortie terminée (250ms fade).
class BadgeCelebration extends StatefulWidget {
  final BadgeUnlock badge;
  final int currentIndex;
  final int total;
  final VoidCallback onDone;
  final VoidCallback? onSkipAll;

  const BadgeCelebration({
    super.key,
    required this.badge,
    required this.currentIndex,
    required this.total,
    required this.onDone,
    this.onSkipAll,
  });

  @override
  State<BadgeCelebration> createState() => _BadgeCelebrationState();
}

class _BadgeCelebrationState extends State<BadgeCelebration>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  // Animations d'entrée
  late Animation<double> _overlayFade;
  late Animation<double> _badgeScale;
  late Animation<double> _badgeOpacity;
  late Animation<double> _titleSlide;
  late Animation<double> _titleFade;
  late Animation<double> _nameFade;
  late Animation<double> _descFade;
  late Animation<double> _actionsFade;

  bool _exiting = false;
  Timer? _hapticTimer;
  Timer? _focusTimer;

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
    // Badge pop: overshoot cubic — scale 0.5→1.0
    _badgeOpacity = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.1, 0.7, curve: Curves.easeOut),
    );
    _badgeScale = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(
        0.1,
        0.7,
        curve: Cubic(0.34, 1.56, 0.64, 1),
      ),
    );

    _titleFade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.3, 0.7, curve: Curves.easeOut),
    );
    _titleSlide = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.3, 0.7, curve: Curves.easeOut),
    );
    _nameFade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.45, 0.8, curve: Curves.easeOut),
    );
    _descFade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.6, 0.9, curve: Curves.easeOut),
    );
    _actionsFade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.8, 1.0, curve: Curves.easeOut),
    );

    _ctrl.forward();

    // Haptique au mount
    HapticFeedback.heavyImpact();
    _hapticTimer = Timer(const Duration(milliseconds: 400), () {
      if (mounted) HapticFeedback.mediumImpact();
    });

    // Auto-focus sur le CTA après 800ms
    _focusTimer = Timer(const Duration(milliseconds: 700), () {
      if (mounted) _ctaFocusNode.requestFocus();
    });
  }

  final _ctaFocusNode = FocusNode();

  @override
  void dispose() {
    _hapticTimer?.cancel();
    _focusTimer?.cancel();
    _ctrl.dispose();
    _ctaFocusNode.dispose();
    super.dispose();
  }

  Future<void> _dismiss() async {
    if (_exiting) return;
    setState(() => _exiting = true);
    await _ctrl.animateBack(0,
        duration: const Duration(milliseconds: 250), curve: Curves.easeIn);
    widget.onDone();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    return Material(
      type: MaterialType.transparency,
      child: PopScope(
        onPopInvokedWithResult: (_, _) => _dismiss(),
        child: GestureDetector(
        onTap: _dismiss,
        child: Semantics(
          liveRegion: true,
          label: '${l10n.celeb_title} ${widget.badge.name}. ${widget.badge.description}',
          child: AnimatedBuilder(
            animation: _ctrl,
            builder: (context, child) {
              final opacity = reduceMotion ? 1.0 : _overlayFade.value;
              return Opacity(
                opacity: opacity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Scrim + blur
                    BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                      child: Container(color: _kScrimStrong),
                    ),

                    // CelebrationParticles gère disableAnimations en interne (SizedBox.shrink)
                    const CelebrationParticles(),

                    // Contenu centré (absorbe les taps pour ne pas dismiss sur le contenu)
                    SafeArea(
                      child: GestureDetector(
                        onTap: () {},
                        behavior: HitTestBehavior.opaque,
                        child: Column(
                          children: [
                            // Indicateur de progression (si plusieurs badges)
                            if (widget.total > 1)
                              Padding(
                                padding: const EdgeInsets.only(top: 60),
                                child: Text(
                                  l10n.celeb_progress(widget.currentIndex, widget.total),
                                  style: const TextStyle(
                                    fontFamily: UrbinkTypography.bodyFamily,
                                    fontSize: 12,
                                    color: Color(0x80FFFFFF),
                                  ),
                                ),
                              ),

                            const Spacer(),

                            // Badge médaille animée
                            _AnimatedBadge(
                              badge: widget.badge,
                              scaleAnim: _badgeScale,
                              opacityAnim: _badgeOpacity,
                              reduceMotion: reduceMotion,
                            ),

                            const SizedBox(height: 28),

                            // Textes staggered
                            Opacity(
                              opacity: reduceMotion ? 1.0 : _titleFade.value,
                              child: Transform.translate(
                                offset: Offset(
                                  0,
                                  reduceMotion ? 0 : (1.0 - _titleSlide.value) * 12,
                                ),
                                child: Text(
                                  l10n.celeb_title,
                                  style: const TextStyle(
                                    fontFamily: UrbinkTypography.displayFamily,
                                    fontSize: 30,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Opacity(
                              opacity: reduceMotion ? 1.0 : _nameFade.value,
                              child: Text(
                                widget.badge.name,
                                style: const TextStyle(
                                  fontFamily: UrbinkTypography.bodyFamily,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: UrbinkColors.accent,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Opacity(
                              opacity: reduceMotion ? 1.0 : _descFade.value,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 32),
                                child: Text(
                                  widget.badge.description,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontFamily: UrbinkTypography.bodyFamily,
                                    fontSize: 13,
                                    color: Color(0xB3FFFFFF),
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ),

                            const Spacer(),

                            // Actions
                            Opacity(
                              opacity: reduceMotion ? 1.0 : _actionsFade.value,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 24),
                                child: Column(
                                  children: [
                                    SizedBox(
                                      width: double.infinity,
                                      height: 52,
                                      child: FilledButton(
                                        focusNode: _ctaFocusNode,
                                        onPressed: _dismiss,
                                        style: FilledButton.styleFrom(
                                          backgroundColor: UrbinkColors.primary,
                                          foregroundColor: Colors.white,
                                          elevation: 4,
                                          shadowColor: UrbinkColors.primary.withValues(alpha: 0.35),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                        ),
                                        child: Text(
                                          l10n.celeb_continue,
                                          style: const TextStyle(
                                            fontFamily: UrbinkTypography.bodyFamily,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    GestureDetector(
                                      onTap: widget.onSkipAll ?? _dismiss,
                                      child: Text(
                                        l10n.celeb_skip,
                                        style: const TextStyle(
                                          fontFamily: UrbinkTypography.bodyFamily,
                                          fontSize: 13,
                                          color: Color(0x80FFFFFF),
                                        ),
                                      ),
                                    ),
                                  ],
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
              );
            },
          ),
        ),
      ),
    ),
    );
  }
}

// ---------------------------------------------------------------------------

class _AnimatedBadge extends StatelessWidget {
  const _AnimatedBadge({
    required this.badge,
    required this.scaleAnim,
    required this.opacityAnim,
    required this.reduceMotion,
  });

  final BadgeUnlock badge;
  final Animation<double> scaleAnim;
  final Animation<double> opacityAnim;
  final bool reduceMotion;

  @override
  Widget build(BuildContext context) {
    final scale = reduceMotion
        ? 1.0
        : 0.5 + scaleAnim.value * 0.5; // 0.5 → 1.0
    final opacity = reduceMotion ? 1.0 : opacityAnim.value;

    return Opacity(
      opacity: opacity,
      child: Transform.scale(
        scale: scale,
        child: BadgeMedal(badge: badge),
      ),
    );
  }
}
