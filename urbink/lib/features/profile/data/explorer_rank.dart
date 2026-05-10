import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// ExplorerRank — rang d'explorateur basé sur les monuments débloqués (XP)
// ---------------------------------------------------------------------------

class ExplorerRank {
  final int index;
  final String id;
  final String name;
  final Color haloColor;
  final int xpMin;
  final int? xpNext;
  final String initial;

  const ExplorerRank({
    required this.index,
    required this.id,
    required this.name,
    required this.haloColor,
    required this.xpMin,
    required this.xpNext,
    required this.initial,
  });

  /// Progression dans le rang actuel (0.0 → 1.0). 1.0 si rang max.
  double progressTo(int currentXp) {
    if (xpNext == null) return 1.0;
    final range = xpNext! - xpMin;
    if (range <= 0) return 1.0;
    return ((currentXp - xpMin) / range).clamp(0.0, 1.0);
  }

  /// XP cumulés dans ce rang (currentXp - xpMin).
  int xpInRank(int currentXp) => (currentXp - xpMin).clamp(0, xpNext != null ? xpNext! - xpMin : currentXp);

  /// XP nécessaires pour le rang suivant.
  int? get xpNeeded => xpNext != null ? xpNext! - xpMin : null;

  @override
  bool operator ==(Object other) => other is ExplorerRank && other.index == index;

  @override
  int get hashCode => index.hashCode;
}

// ---------------------------------------------------------------------------
// kExplorerRanks — les 11 rangs (seuils identiques à gems.jsx)
// ---------------------------------------------------------------------------

const List<ExplorerRank> kExplorerRanks = [
  ExplorerRank(index: 0,  id: 'cristal',    name: 'Cristal',    haloColor: Color(0xFFA8C4D6), xpMin: 0,    xpNext: 5,    initial: 'C'),
  ExplorerRank(index: 1,  id: 'opale',      name: 'Opale',      haloColor: Color(0xFFD4B5E8), xpMin: 5,    xpNext: 15,   initial: 'O'),
  ExplorerRank(index: 2,  id: 'turquoise',  name: 'Turquoise',  haloColor: Color(0xFF3FB8B0), xpMin: 15,   xpNext: 35,   initial: 'T'),
  ExplorerRank(index: 3,  id: 'ambre',      name: 'Ambre',      haloColor: Color(0xFFE89B3F), xpMin: 35,   xpNext: 75,   initial: 'A'),
  ExplorerRank(index: 4,  id: 'topaze',     name: 'Topaze',     haloColor: Color(0xFFE8C547), xpMin: 75,   xpNext: 140,  initial: 'T'),
  ExplorerRank(index: 5,  id: 'jade',       name: 'Jade',       haloColor: Color(0xFF3D9B6E), xpMin: 140,  xpNext: 240,  initial: 'J'),
  ExplorerRank(index: 6,  id: 'saphir',     name: 'Saphir',     haloColor: Color(0xFF3461C9), xpMin: 240,  xpNext: 380,  initial: 'S'),
  ExplorerRank(index: 7,  id: 'rubis',      name: 'Rubis',      haloColor: Color(0xFFC9344B), xpMin: 380,  xpNext: 560,  initial: 'R'),
  ExplorerRank(index: 8,  id: 'emeraude',   name: 'Émeraude',   haloColor: Color(0xFF1F8A5B), xpMin: 560,  xpNext: 800,  initial: 'É'),
  ExplorerRank(index: 9,  id: 'diamant',    name: 'Diamant',    haloColor: Color(0xFFC8E0F0), xpMin: 800,  xpNext: 1100, initial: 'D'),
  ExplorerRank(index: 10, id: 'legendaire', name: 'Légendaire', haloColor: Color(0xFFD4A642), xpMin: 1100, xpNext: null, initial: '★'),
];

// ---------------------------------------------------------------------------
// rankForXp — retourne le rang correspondant au XP total
// ---------------------------------------------------------------------------

ExplorerRank rankForXp(int xp) {
  for (int i = kExplorerRanks.length - 1; i >= 0; i--) {
    if (xp >= kExplorerRanks[i].xpMin) return kExplorerRanks[i];
  }
  return kExplorerRanks.first;
}
