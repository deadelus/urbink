import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urbink/features/map/providers/streets_visible_provider.dart';
import 'package:urbink/shared/constants/colors.dart';
import 'package:urbink/shared/constants/typography.dart';

/// Pill flottant bas-gauche — "Voir les zones explorées" (FR10b).
///
/// Direction UI : fond vert primaire, icône + label, ombre douce,
/// tap scale 0.97 — 200ms ease-out.
class ZonesTogglePill extends ConsumerWidget {
  const ZonesTogglePill({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visible = ref.watch(streetsVisibleProvider);

    return Semantics(
      label: visible ? 'Masquer les zones explorées' : 'Voir les zones explorées',
      button: true,
      child: _ScaleTap(
        onTap: () => ref.read(streetsVisibleProvider.notifier).state = !visible,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: visible ? UrbinkColors.primary : UrbinkColors.surface,
            borderRadius: BorderRadius.circular(50),
            border: Border.all(
              color: visible
                  ? UrbinkColors.primary
                  : UrbinkColors.border,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                visible ? Icons.layers_rounded : Icons.layers_outlined,
                color: visible ? Colors.white : UrbinkColors.primary,
                size: 18,
              ),
              const SizedBox(width: 6),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontFamily: UrbinkTypography.bodyFamily,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: visible ? Colors.white : UrbinkColors.primary,
                ),
                child: Text(
                  visible ? 'Cacher les zones explorées' : 'Voir les zones explorées',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tap scale helper
// ---------------------------------------------------------------------------

class _ScaleTap extends StatefulWidget {
  const _ScaleTap({required this.child, required this.onTap});

  final Widget child;
  final VoidCallback onTap;

  @override
  State<_ScaleTap> createState() => _ScaleTapState();
}

class _ScaleTapState extends State<_ScaleTap>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 200),
      lowerBound: 0.97,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final disable = MediaQuery.of(context).disableAnimations;
    return GestureDetector(
      onTapDown: disable ? null : (_) => _ctrl.reverse(),
      onTapUp: disable
          ? null
          : (_) {
              _ctrl.forward();
              widget.onTap();
            },
      onTapCancel: disable ? null : () => _ctrl.forward(),
      onTap: disable ? widget.onTap : null,
      child: ScaleTransition(
        scale: disable ? const AlwaysStoppedAnimation(1.0) : _ctrl,
        child: widget.child,
      ),
    );
  }
}
