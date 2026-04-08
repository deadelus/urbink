import 'package:flutter/material.dart';
import 'package:urbink/shared/constants/colors.dart';

/// Bottom navigation bar Urbink — 5 onglets avec bouton Démarrer central surélevé.
///
/// Conformité Story 1.3 :
/// - Bouton Démarrer central surélevé de 12px avec ombre Material 3
/// - Onglet sélectionné : icône + label Ocre #B8832E + underline 2px
/// - Onglets inactifs : #8C7B6A
/// - Session active : bouton Démarrer passe en Vert Sauge #5A7A5A avec icône ⏸
/// - Semantics VoiceOver : "Accueil, onglet 1 sur 5", etc.
class UrbinkBottomNav extends StatelessWidget {
  const UrbinkBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
    this.isSessionActive = false,
  });

  final int currentIndex;
  final ValueChanged<int> onTabSelected;
  /// true → session en cours (bouton ⏸ Vert Sauge), false → repos (bouton ▶ Ocre)
  final bool isSessionActive;

  static const double _barHeight = 64.0;
  static const double _centerElevation = 12.0;
  static const double _centerButtonSize = 56.0;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    // Hauteur totale = barre + safe area + espace pour le bouton surélevé
    final totalHeight = _barHeight + bottomPadding + _centerElevation;

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
              height: _barHeight + bottomPadding,
              bottomPadding: bottomPadding,
            ),
          ),
          // Bouton Démarrer central surélevé de 12px
          Positioned(
            bottom: bottomPadding + (_barHeight - _centerButtonSize) / 2 + _centerElevation,
            left: 0,
            right: 0,
            child: Center(
              child: _StartButton(
                isSelected: currentIndex == 2,
                isSessionActive: isSessionActive,
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  item.icon,
                  size: 24,
                  color: isSelected ? UrbinkColors.primary : UrbinkColors.navInactive,
                ),
                const SizedBox(height: 4),
                Text(
                  item.label,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? UrbinkColors.primary : UrbinkColors.navInactive,
                  ),
                ),
                const SizedBox(height: 4),
                // Underline 2px visible uniquement si sélectionné
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
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Bouton Démarrer — FAB circulaire Ocre surélevé au centre
// ---------------------------------------------------------------------------

class _StartButton extends StatelessWidget {
  const _StartButton({
    required this.isSelected,
    required this.isSessionActive,
    required this.onTap,
  });

  final bool isSelected;
  final bool isSessionActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Repos → Vert Sauge + icône play ; session active → Ocre + icône pause
    final color = isSessionActive ? UrbinkColors.primary : UrbinkColors.secondary;
    final icon = isSessionActive ? Icons.pause : Icons.play_arrow;
    final semanticLabel = isSessionActive
        ? 'Pause session, onglet 3 sur 5'
        : 'Démarrer, onglet 3 sur 5';

    return Semantics(
      label: semanticLabel,
      button: true,
      selected: isSelected,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            boxShadow: [
              // Ombre Material 3
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
            duration: const Duration(milliseconds: 200),
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
