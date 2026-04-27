import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:urbink/features/gamification/models/celebration_event.dart';
import 'package:urbink/features/gamification/widgets/golden_particles.dart';
import 'package:urbink/l10n/app_localizations.dart';
import 'package:urbink/shared/constants/typography.dart';

const _kScrim = Color(0xD90F172A);
const _kGold = Color(0xFFF59E0B);
const _kGoldDark = Color(0xFFB45309);
const _kDistrictAutoDismiss = 5;

/// Overlay plein écran unifié pour les célébrations badge et district.
///
/// Utilisé via [showCelebrationOverlay].
/// - Mode [CelebrationMode.badge] : scale-in 300ms, tap pour dismiss.
/// - Mode [CelebrationMode.district] : secret local + Partager, auto-dismiss 5s.
/// - Si [MediaQuery.disableAnimations] : fade 150ms + annonce VoiceOver.
class CelebrationOverlay extends StatefulWidget {
  final CelebrationEvent event;
  final VoidCallback onDone;

  const CelebrationOverlay({
    super.key,
    required this.event,
    required this.onDone,
  });

  @override
  State<CelebrationOverlay> createState() => _CelebrationOverlayState();
}

class _CelebrationOverlayState extends State<CelebrationOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _overlayFade;
  late Animation<double> _iconScale;
  late Animation<double> _iconOpacity;
  late Animation<double> _titleFade;
  late Animation<double> _titleSlide;
  late Animation<double> _subtitleFade;
  late Animation<double> _actionsFade;

  bool _exiting = false;
  Timer? _autoDismissTimer;
  Timer? _hapticTimer;
  int _countdown = _kDistrictAutoDismiss;
  Timer? _countdownTimer;

  bool get _isDistrict => widget.event.mode == CelebrationMode.district;

  @override
  void initState() {
    super.initState();

    final animDuration = _isDistrict
        ? const Duration(milliseconds: 1000)
        : const Duration(milliseconds: 800);

    _ctrl = AnimationController(vsync: this, duration: animDuration);

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
    _subtitleFade = CurvedAnimation(
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

    if (_isDistrict) {
      _autoDismissTimer = Timer(
        const Duration(seconds: _kDistrictAutoDismiss),
        () { if (mounted) _dismiss(null); },
      );
      _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (!mounted) { t.cancel(); return; }
        setState(() => _countdown--);
        if (_countdown <= 0) t.cancel();
      });
    }

    // Annonce VoiceOver après le premier frame (réducteur d'animations ou non).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      final announcement = _isDistrict
          ? l10n.celeb_district_semantics(widget.event.title)
          : '${l10n.celeb_title} ${widget.event.title}';
      SemanticsService.sendAnnouncement(
        View.of(context), announcement, TextDirection.ltr);
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

  Future<void> _dismiss(VoidCallback? callback) async {
    if (_exiting) return;
    setState(() => _exiting = true);
    _autoDismissTimer?.cancel();
    _hapticTimer?.cancel();
    _countdownTimer?.cancel();

    final reduceMotion = MediaQuery.of(context).disableAnimations;
    await _ctrl.animateBack(
      0,
      duration: Duration(milliseconds: reduceMotion ? 150 : 250),
      curve: Curves.easeIn,
    );
    callback?.call();
    widget.onDone();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    return Material(
      type: MaterialType.transparency,
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (_, _) => _dismiss(null),
        child: Semantics(
          liveRegion: true,
          child: GestureDetector(
            onTap: () => _dismiss(null),
            child: AnimatedBuilder(
              animation: _ctrl,
              builder: (context, _) {
                final fade = reduceMotion ? 1.0 : _overlayFade.value;
                return Opacity(
                  opacity: fade,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                        child: Container(color: _kScrim),
                      ),
                      const GoldenParticles(),
                      SafeArea(
                        child: GestureDetector(
                          onTap: () {},
                          behavior: HitTestBehavior.opaque,
                          child: Column(
                            children: [
                              const Spacer(),
                              _AnimatedIcon(
                                emoji: widget.event.iconEmoji,
                                scaleAnim: _iconScale,
                                opacityAnim: _iconOpacity,
                                reduceMotion: reduceMotion,
                              ),
                              const SizedBox(height: 24),
                              _FadingSlide(
                                fadeAnim: _titleFade,
                                slideAnim: _titleSlide,
                                reduceMotion: reduceMotion,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 32),
                                  child: Text(
                                    _isDistrict
                                        ? l10n.celeb_district_title(widget.event.title)
                                        : '${l10n.celeb_title}\n${widget.event.title}',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontFamily: UrbinkTypography.displayFamily,
                                      fontSize: 26,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      height: 1.3,
                                    ),
                                  ),
                                ),
                              ),
                              if (widget.event.subtitle case final sub?)
                                _buildSubtitle(sub, reduceMotion),
                              const Spacer(),
                              _buildActions(l10n, reduceMotion),
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

  Widget _buildSubtitle(String subtitle, bool reduceMotion) {
    if (_isDistrict) {
      return Opacity(
        opacity: reduceMotion ? 1.0 : _subtitleFade.value,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _kGold.withValues(alpha: 0.4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const Text('🗝️', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 6),
                  Text(
                    AppLocalizations.of(context).celeb_secret_local_label,
                    style: const TextStyle(
                      fontFamily: UrbinkTypography.bodyFamily,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _kGold,
                      letterSpacing: 0.8,
                    ),
                  ),
                ]),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontFamily: UrbinkTypography.bodyFamily,
                    fontSize: 13,
                    color: Color(0xCCFFFFFF),
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Badge mode : description sous le titre
    return Opacity(
      opacity: reduceMotion ? 1.0 : _subtitleFade.value,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 12, 32, 0),
        child: Text(
          subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: UrbinkTypography.bodyFamily,
            fontSize: 13,
            color: Color(0xB3FFFFFF),
            height: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildActions(AppLocalizations l10n, bool reduceMotion) {
    return Opacity(
      opacity: reduceMotion ? 1.0 : _actionsFade.value,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
        child: Column(
          children: [
            if (_isDistrict && widget.event.onShare != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton(
                    onPressed: () => _dismiss(widget.event.onShare),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _kGold,
                      side: const BorderSide(color: _kGold, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      l10n.celeb_share,
                      style: const TextStyle(
                        fontFamily: UrbinkTypography.bodyFamily,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: () => _dismiss(null),
                style: FilledButton.styleFrom(
                  backgroundColor: _isDistrict ? _kGoldDark : const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  _isDistrict && _countdown > 0
                      ? '${l10n.celeb_continue} ($_countdown)'
                      : l10n.celeb_continue,
                  style: const TextStyle(
                    fontFamily: UrbinkTypography.bodyFamily,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _AnimatedIcon extends StatelessWidget {
  const _AnimatedIcon({
    required this.emoji,
    required this.scaleAnim,
    required this.opacityAnim,
    required this.reduceMotion,
  });

  final String emoji;
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
            color: _kGold.withValues(alpha: 0.15),
            border: Border.all(color: _kGold.withValues(alpha: 0.5), width: 2),
          ),
          child: Center(
            child: Text(emoji, style: const TextStyle(fontSize: 52)),
          ),
        ),
      ),
    );
  }
}

class _FadingSlide extends StatelessWidget {
  const _FadingSlide({
    required this.fadeAnim,
    required this.slideAnim,
    required this.reduceMotion,
    required this.child,
  });

  final Animation<double> fadeAnim;
  final Animation<double> slideAnim;
  final bool reduceMotion;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: reduceMotion ? 1.0 : fadeAnim.value,
      child: Transform.translate(
        offset: Offset(0, reduceMotion ? 0 : (1.0 - slideAnim.value) * 12),
        child: child,
      ),
    );
  }
}

// ---------------------------------------------------------------------------

/// Affiche [CelebrationOverlay] via [showGeneralDialog] (rootNavigator).
Future<void> showCelebrationOverlay({
  required BuildContext context,
  required CelebrationEvent event,
  required VoidCallback onDone,
}) {
  return showGeneralDialog<void>(
    context: context,
    useRootNavigator: true,
    barrierDismissible: false,
    barrierColor: Colors.transparent,
    transitionDuration: Duration.zero,
    pageBuilder: (ctx, _, _) => CelebrationOverlay(
      event: event,
      onDone: () {
        Navigator.of(ctx, rootNavigator: true).pop();
        onDone();
      },
    ),
  );
}
