import 'package:flutter/material.dart';
import 'package:urbink/features/sessions/session_state_provider.dart';
import 'package:urbink/shared/constants/colors.dart';
import 'package:urbink/shared/constants/spacing.dart';

/// Bottom navigation bar Urbink — 5 onglets avec bouton Démarrer central surélevé.
///
/// Conformité Story 1.3 :
/// - Bouton Démarrer central surélevé de 12px avec ombre Material 3
/// - Onglet sélectionné : icône + label Ocre #B8832E + underline 2px
/// - Onglets inactifs : #8C7B6A
/// - [SessionState.active] : bouton Démarrer Ocre #B8832E avec icône ⏸
/// - [SessionState.idle] / [SessionState.paused] : bouton Démarrer Vert Sauge #5A7A5A avec icône ▶
/// - Semantics VoiceOver : "Accueil, onglet 1 sur 5", etc.
class UrbinkBottomNav extends StatelessWidget {
  const UrbinkBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
    this.sessionState = SessionState.idle,
  });

  final int currentIndex;
  final ValueChanged<int> onTabSelected;

  /// [SessionState.active] → bouton ⏸ Ocre
  /// [SessionState.idle] / [SessionState.paused] → bouton ▶ Vert Sauge
  final SessionState sessionState;

  static const double _centerElevation = 12.0;
  static const double _centerButtonSize = 56.0;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    // Hauteur totale = barre + safe area + espace pour le bouton surélevé
    final totalHeight =
        UrbinkSpacing.bottomNavHeight + bottomPadding + _centerElevation;

    return SizedBox(
      height: totalHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Fond de la barre + 4 onglets normaux
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _BottomNavBar(
              currentIndex: currentIndex,
              onTabSelected: onTabSelected,
              height: UrbinkSpacing.bottomNavHeight + bottomPadding,
              bottomPadding: bottomPadding,
            ),
          ),
          // Bouton Démarrer central surélevé de 12px
          Positioned(
            bottom: bottomPadding +
                (UrbinkSpacing.bottomNavHeight - _centerButtonSize) / 2 +
                _centerElevation,
            left: 0,
            right: 0,
            child: Center(
              child: _StartButton(
                isSelected: currentIndex == 2,
                sessionState: sessionState,
                onTap: () => onTabSelected(2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Barre de navigation avec les 4 onglets (slot central vide pour le bouton)
// ---------------------------------------------------------------------------

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar({
    required this.currentIndex,
    required this.onTabSelected,
    required this.height,
    required this.bottomPadding,
  });

  final int currentIndex;
  final ValueChanged<int> onTabSelected;
  final double height;
  final double bottomPadding;

  static const _items = [
    _TabItem(0, Icons.home_outlined, 'Accueil'),
    _TabItem(1, Icons.map_outlined, 'Carte'),
    _TabItem(3, Icons.emoji_events_outlined, 'Challenges'),
    _TabItem(4, Icons.person_outline, 'Vous'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: UrbinkColors.onSurface.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomPadding),
        child: Row(
          children: [
            // Onglets 0 et 1 (Accueil, Carte)
            _buildTab(context, _items[0]),
            _buildTab(context, _items[1]),
            // Slot vide central pour laisser place au bouton surélevé
            const Expanded(child: SizedBox()),
            // Onglets 3 et 4 (Challenges, Vous)
            _buildTab(context, _items[2]),
            _buildTab(context, _items[3]),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(BuildContext context, _TabItem item) {
    final isSelected = currentIndex == item.index;
    final disableAnimations = MediaQuery.of(context).disableAnimations;

    return Expanded(
      child: Semantics(
        label: '${item.label}, onglet ${item.index + 1} sur 5',
        button: true,
        selected: isSelected,
        excludeSemantics: true,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => onTabSelected(item.index),
          child: SizedBox(
            height: double.infinity,
            // Cap textScaler à 1.3x : évite l'overflow vertical dans la nav bar
            // (espace fixe ~60px — WCAG 2.1 AA autorise ce cap sur les éléments de navigation)
            child: MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: MediaQuery.of(context).textScaler.clamp(
                  minScaleFactor: 0.0,
                  maxScaleFactor: 1.3,
                ),
              ),
              child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  item.icon,
                  size: 24,
                  color: isSelected ? UrbinkColors.primary : UrbinkColors.navInactive,
                ),
                const SizedBox(height: 4),
                // Dynamic Type : labelSmall du thème, textScaler capé à 1.3x pour éviter overflow
                Text(
                  item.label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: isSelected ? UrbinkColors.primary : UrbinkColors.navInactive,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                // Underline : fade si "Réduire les animations" activé, sinon animation de largeur
                if (disableAnimations)
                  AnimatedOpacity(
                    opacity: isSelected ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 150),
                    child: Container(
                      height: 2,
                      width: 24,
                      decoration: BoxDecoration(
                        color: UrbinkColors.primary,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  )
                else
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    height: 2,
                    width: isSelected ? 24 : 0,
                    decoration: BoxDecoration(
                      color: UrbinkColors.primary,
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
              ],
            ),
            ), // MediaQuery
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Bouton Démarrer — FAB circulaire surélevé au centre
// ---------------------------------------------------------------------------

class _StartButton extends StatelessWidget {
  const _StartButton({
    required this.isSelected,
    required this.sessionState,
    required this.onTap,
  });

  final bool isSelected;
  final SessionState sessionState;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Repos/pause → Vert Sauge ▶ ; session active → Ocre ⏸
    final isActive = sessionState == SessionState.active;
    final color = isActive ? UrbinkColors.primary : UrbinkColors.secondary;
    final icon = isActive ? Icons.pause : Icons.play_arrow;
    final semanticLabel = switch (sessionState) {
      SessionState.idle => 'Démarrer, onglet 3 sur 5',
      SessionState.active => 'Pause session, onglet 3 sur 5',
      SessionState.paused => 'Reprendre session, onglet 3 sur 5',
    };

    // Réduire les animations : transitions instant (couleur) + fade court (icône)
    final disableAnimations = MediaQuery.of(context).disableAnimations;
    final colorDuration =
        disableAnimations ? Duration.zero : const Duration(milliseconds: 200);
    final iconDuration = disableAnimations
        ? const Duration(milliseconds: 150)
        : const Duration(milliseconds: 200);

    return Semantics(
      label: semanticLabel,
      button: true,
      selected: isSelected,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: colorDuration,
          width: UrbinkBottomNav._centerButtonSize,
          height: UrbinkBottomNav._centerButtonSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.30),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: UrbinkColors.onSurface.withValues(alpha: 0.10),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: AnimatedSwitcher(
            duration: iconDuration,
            // FadeTransition explicite — compatible "Réduire les animations"
            transitionBuilder: (child, animation) =>
                FadeTransition(opacity: animation, child: child),
            child: Icon(
              icon,
              key: ValueKey(icon),
              color: Colors.white,
              size: 28,
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
  const _TabItem(this.index, this.icon, this.label);

  final int index;
  final IconData icon;
  final String label;
}
