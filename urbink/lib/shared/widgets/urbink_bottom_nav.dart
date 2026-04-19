import 'package:flutter/material.dart';
import 'package:urbink/features/sessions/session_state_provider.dart';
import 'package:urbink/shared/constants/colors.dart';
import 'package:urbink/shared/constants/spacing.dart';
import 'package:urbink/shared/constants/typography.dart';

/// Bottom navigation bar Urbink v4 — 5 onglets plats, iOS-inspired.
///
/// Conformité Story 2.10 + direction UI :
/// - Icônes Material outline 22px (stroke style proche Lucide)
/// - Indicateur actif : trait 20×2px au-dessus de l'icône, deep green
/// - Session active : indicateur deep green (même couleur)
/// - Tap scale 0.97 — 200ms ease-out
class UrbinkBottomNav extends StatelessWidget {
  const UrbinkBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
    this.sessionState = SessionState.idle,
  });

  final int currentIndex;
  final ValueChanged<int> onTabSelected;
  final SessionState sessionState;

  static const _tabs = [
    _TabItem(icon: Icons.map_outlined,            label: 'Carte'),
    _TabItem(icon: Icons.route_outlined,           label: 'Parcours'),
    _TabItem(icon: Icons.people_outline,           label: 'Social'),
    _TabItem(icon: Icons.emoji_events_outlined,    label: 'Badges'),
    _TabItem(icon: Icons.person_outline_rounded,   label: 'Profil'),
  ];

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      height: UrbinkSpacing.bottomNavHeight + bottomPadding,
      decoration: BoxDecoration(
        color: UrbinkColors.surface,
        border: const Border(
          top: BorderSide(color: UrbinkColors.border),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomPadding),
        child: Row(
          children: [
            for (var i = 0; i < _tabs.length; i++)
              _NavTab(
                item: _tabs[i],
                index: i,
                isSelected: currentIndex == i,
                onTap: () => onTabSelected(i),
              ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Onglet individuel avec tap scale
// ---------------------------------------------------------------------------

class _NavTab extends StatefulWidget {
  const _NavTab({
    required this.item,
    required this.index,
    required this.isSelected,
    required this.onTap,
  });

  final _TabItem item;
  final int index;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<_NavTab> createState() => _NavTabState();
}

class _NavTabState extends State<_NavTab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scaleController;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 200),
      lowerBound: 0.97,
      upperBound: 1.0,
      value: 1.0,
    );
    _scaleAnim = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _onTapDown(_) => _scaleController.reverse();
  void _onTapUp(_) {
    _scaleController.forward();
    widget.onTap();
  }
  void _onTapCancel() => _scaleController.forward();

  @override
  Widget build(BuildContext context) {
    final disableAnimations = MediaQuery.of(context).disableAnimations;
    const activeColor = UrbinkColors.primary;
    const inactiveColor = UrbinkColors.navInactive;

    return Expanded(
      child: Semantics(
        label: '${widget.item.label}, onglet ${widget.index + 1} sur 5',
        button: true,
        selected: widget.isSelected,
        excludeSemantics: true,
        onTap: widget.onTap,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: disableAnimations ? null : _onTapDown,
          onTapUp: disableAnimations ? null : _onTapUp,
          onTapCancel: disableAnimations ? null : _onTapCancel,
          onTap: disableAnimations ? widget.onTap : null,
          child: ScaleTransition(
            scale: disableAnimations
                ? const AlwaysStoppedAnimation(1.0)
                : _scaleAnim,
            child: MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: MediaQuery.of(context).textScaler.clamp(
                      minScaleFactor: 0.0,
                      maxScaleFactor: 1.3,
                    ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  // Indicateur actif — trait 20×2px au-dessus de l'icône
                  if (disableAnimations)
                    AnimatedOpacity(
                      opacity: widget.isSelected ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 150),
                      child: Container(
                        height: 2,
                        width: 20,
                        decoration: BoxDecoration(
                          color: activeColor,
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    )
                  else
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                      height: 2,
                      width: widget.isSelected ? 20 : 0,
                      decoration: BoxDecoration(
                        color: activeColor,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  const SizedBox(height: 4),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder: (child, anim) =>
                        FadeTransition(opacity: anim, child: child),
                    child: Icon(
                      widget.item.icon,
                      key: ValueKey(widget.isSelected),
                      size: 22,
                      color: widget.isSelected ? activeColor : inactiveColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.item.label,
                    style: TextStyle(
                      fontFamily: UrbinkTypography.bodyFamily,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: widget.isSelected ? activeColor : inactiveColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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

// ---------------------------------------------------------------------------
// Modèle d'onglet
// ---------------------------------------------------------------------------

class _TabItem {
  const _TabItem({required this.icon, required this.label});

  final IconData icon;
  final String label;
}
