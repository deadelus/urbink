import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:urbink/core/router/app_router.dart';
import 'package:urbink/features/gamification/models/monument_badge.dart';
import 'package:urbink/features/map/models/monument.dart';
import 'package:urbink/features/map/providers/map_focus_provider.dart';
import 'package:urbink/features/map/providers/monument_proximity_provider.dart';
import 'package:urbink/shared/constants/colors.dart';
import 'package:urbink/shared/constants/spacing.dart';

const _kGold = Color(0xFFF59E0B);
const _kGoldLight = Color(0xFFFEF3C7);
const _kGoldBorder = Color(0xFFFDE68A);
const _kGoldText = Color(0xFF92400E);

// ---------------------------------------------------------------------------
// BadgeGrid — grille 4 colonnes monuments (locked / unlocked)
// ---------------------------------------------------------------------------

/// Grille 4 colonnes affichant les badges monuments débloqués et verrouillés.
///
/// - Débloqués : emoji en couleur + date d'obtention
/// - Verrouillés : opacité 40% + indice court
/// - Nouveau badge : animation scale-in + chip "Nouveau !" pendant 3 secondes
class BadgeGrid extends ConsumerStatefulWidget {
  const BadgeGrid({super.key, required this.monuments, required this.badges});

  /// Liste de monuments à afficher (filtrée à ~197 emblématiques).
  final List<Monument> monuments;

  /// Badges monument déjà débloqués par l'utilisateur.
  final List<MonumentBadge> badges;

  @override
  ConsumerState<BadgeGrid> createState() => _BadgeGridState();
}

class _BadgeGridState extends ConsumerState<BadgeGrid> {
  /// Ids des badges connus depuis le dernier build — pour détecter les nouveaux.
  final _knownBadgeIds = <String>{};

  /// Ids des badges en cours d'animation "Nouveau !".
  final _newBadgeIds = <String>{};

  @override
  void initState() {
    super.initState();
    // Initialise sans animation au premier chargement.
    for (final b in widget.badges) {
      _knownBadgeIds.add(b.monumentId);
    }
  }

  @override
  void didUpdateWidget(BadgeGrid old) {
    super.didUpdateWidget(old);
    for (final b in widget.badges) {
      if (!_knownBadgeIds.contains(b.monumentId)) {
        _knownBadgeIds.add(b.monumentId);
        _triggerNew(b.monumentId);
      }
    }
  }

  void _triggerNew(String monumentId) {
    if (!mounted) return;
    setState(() => _newBadgeIds.add(monumentId));
    Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _newBadgeIds.remove(monumentId));
    });
  }

  @override
  Widget build(BuildContext context) {
    final unlockedById = {for (final b in widget.badges) b.monumentId: b};

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: UrbinkSpacing.md),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: UrbinkSpacing.sm,
        crossAxisSpacing: UrbinkSpacing.sm,
        childAspectRatio: 0.75,
      ),
      itemCount: widget.monuments.length,
      itemBuilder: (context, index) {
        final monument = widget.monuments[index];
        final badge = unlockedById[monument.id];
        final isNew = _newBadgeIds.contains(monument.id);

        if (badge != null) {
          return _UnlockedBadgeCell(
            monument: monument,
            badge: badge,
            isNew: isNew,
          );
        }
        return _LockedBadgeCell(monument: monument);
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Cellule — badge débloqué
// ---------------------------------------------------------------------------

class _UnlockedBadgeCell extends StatefulWidget {
  const _UnlockedBadgeCell({
    required this.monument,
    required this.badge,
    required this.isNew,
  });

  final Monument monument;
  final MonumentBadge badge;
  final bool isNew;

  @override
  State<_UnlockedBadgeCell> createState() => _UnlockedBadgeCellState();
}

class _UnlockedBadgeCellState extends State<_UnlockedBadgeCell>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack);
    if (widget.isNew) {
      _ctrl.forward();
    } else {
      _ctrl.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(_UnlockedBadgeCell old) {
    super.didUpdateWidget(old);
    if (widget.isNew && !old.isNew) {
      _ctrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel = _formatDate(widget.badge.unlockedAt);

    return ScaleTransition(
      scale: _scale,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            decoration: BoxDecoration(
              color: _kGoldLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _kGoldBorder, width: 1.5),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(widget.badge.emoji, style: const TextStyle(fontSize: 28)),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    widget.monument.name,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: _kGoldText,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  dateLabel,
                  style: const TextStyle(fontSize: 8, color: _kGold),
                ),
              ],
            ),
          ),
          if (widget.isNew)
            Positioned(
              top: -6,
              right: -6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: UrbinkColors.primary,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Nouveau !',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 7,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }
}

// ---------------------------------------------------------------------------
// Cellule — badge verrouillé
// ---------------------------------------------------------------------------

class _LockedBadgeCell extends ConsumerWidget {
  const _LockedBadgeCell({required this.monument});

  final Monument monument;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => _showLockedSheet(context, ref),
      child: Opacity(
        opacity: 0.4,
        child: Container(
          decoration: BoxDecoration(
            color: UrbinkColors.ghost,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(monument.categoryIcon, style: const TextStyle(fontSize: 28)),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  monument.name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 2),
              const Text('🔒', style: TextStyle(fontSize: 10)),
            ],
          ),
        ),
      ),
    );
  }

  void _showLockedSheet(BuildContext context, WidgetRef ref) {
    final radius = kMonumentProximityRadiusMeters.toInt();
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(
          UrbinkSpacing.lg,
          UrbinkSpacing.lg,
          UrbinkSpacing.lg,
          UrbinkSpacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(monument.categoryIcon,
                    style: const TextStyle(fontSize: 32)),
                const SizedBox(width: UrbinkSpacing.sm),
                Expanded(
                  child: Text(
                    monument.name,
                    style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: UrbinkSpacing.sm),
            Text(
              'Passe à $radius mètres pour débloquer ce badge.',
              style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                    color: UrbinkColors.navInactive,
                  ),
            ),
            const SizedBox(height: UrbinkSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  ref.read(mapFocusProvider.notifier).state =
                      monument.position;
                  context.go(AppRoutes.map);
                },
                icon: const Icon(Icons.map_outlined),
                label: const Text('Voir sur carte'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
