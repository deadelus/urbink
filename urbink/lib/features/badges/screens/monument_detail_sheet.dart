import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:urbink/features/badges/data/collection_model.dart';
import 'package:urbink/features/badges/widgets/mini_map.dart';
import 'package:urbink/features/map/providers/map_focus_provider.dart';
import 'package:urbink/l10n/app_localizations.dart';
import 'package:urbink/shared/constants/colors.dart';

// ---------------------------------------------------------------------------
// MonumentDetailSheet — bottom sheet de détail d'un monument
//
// Ouverture :
//   MonumentDetailSheet.show(context, monument, collection, onShowOnMap: …)
//
// onShowOnMap est fourni par CollectionDetailScreen ; il ferme l'overlay
// collection puis navigue vers l'onglet Carte.
// ---------------------------------------------------------------------------

class MonumentDetailSheet {
  MonumentDetailSheet._();

  static void show(
    BuildContext context, {
    required CollectionMonument monument,
    required MonumentCollection collection,
    required VoidCallback onShowOnMap,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: const Color(0x800F172A),
      builder: (ctx) => Consumer(
        builder: (ctx, ref, _) => _MonumentDetailContent(
          monument: monument,
          collection: collection,
          onShowOnMap: () {
            if (monument.location != null) {
              ref.read(mapFocusProvider.notifier).state = monument.location;
            }
            onShowOnMap();
          },
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _MonumentDetailContent — widget principal de la sheet
// ---------------------------------------------------------------------------

class _MonumentDetailContent extends StatelessWidget {
  const _MonumentDetailContent({
    required this.monument,
    required this.collection,
    required this.onShowOnMap,
  });

  final CollectionMonument monument;
  final MonumentCollection collection;
  final VoidCallback onShowOnMap;

  @override
  Widget build(BuildContext context) {
    final col = collection.color;

    return Semantics(
      label: 'Détail du monument ${monument.name}',
      container: true,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.78,
        ),
        child: Container(
          decoration: const BoxDecoration(
            color: UrbinkColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Color(0x40000000),
                blurRadius: 30,
                offset: Offset(0, -8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              const _DragHandle(),

              // Contenu scrollable
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Mini-carte
                      MiniMap(
                        monument: monument.location,
                        accentColor: col,
                        arrondissement: monument.arrondissement,
                        unlocked: !monument.locked,
                      ),

                      // Header : emoji + nom + collection pill + époque + ×
                      _MonumentHeader(
                        monument: monument,
                        collection: collection,
                      ),

                      // Description
                      if (monument.description.isNotEmpty)
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(16, 4, 16, 14),
                          child: Text(
                            monument.description,
                            style: const TextStyle(
                              fontSize: 13,
                              color: UrbinkColors.onSurface,
                              height: 1.5,
                            ),
                          ),
                        ),

                      // Status card
                      _StatusCard(
                        monument: monument,
                        collectionColor: col,
                      ),

                      // Actions
                      _ActionsRow(
                        monument: monument,
                        collectionColor: col,
                        onShowOnMap: onShowOnMap,
                      ),

                      // Padding bas (safe area)
                      const SizedBox(height: 24),
                    ],
                  ),
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
// _DragHandle
// ---------------------------------------------------------------------------

class _DragHandle extends StatelessWidget {
  const _DragHandle();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 4),
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: UrbinkColors.sheetDragPill,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _MonumentHeader
// ---------------------------------------------------------------------------

class _MonumentHeader extends StatelessWidget {
  const _MonumentHeader({
    required this.monument,
    required this.collection,
  });

  final CollectionMonument monument;
  final MonumentCollection collection;

  @override
  Widget build(BuildContext context) {
    final col = collection.color;
    final isLocked = monument.locked;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Emoji container 54×54
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: isLocked
                  ? UrbinkColors.surfaceVariant
                  : col.withValues(alpha: 0.094),
            ),
            child: Center(
              child: ColorFiltered(
                colorFilter: isLocked
                    ? const ColorFilter.matrix([
                        0.2126, 0.7152, 0.0722, 0, 0,
                        0.2126, 0.7152, 0.0722, 0, 0,
                        0.2126, 0.7152, 0.0722, 0, 0,
                        0, 0, 0, 1, 0,
                      ])
                    : const ColorFilter.mode(
                        Colors.transparent, BlendMode.dst),
                child: Text(
                  monument.emoji,
                  style: const TextStyle(fontSize: 30),
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Nom + pills
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  monument.name,
                  style: const TextStyle(
                    fontFamily: 'CrimsonPro',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: UrbinkColors.onSurface,
                    height: 1.15,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    // Pill collection
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: col.withValues(alpha: 0.094),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${collection.icon} ${collection.name}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: col,
                        ),
                      ),
                    ),
                    // Époque
                    if (monument.era.isNotEmpty)
                      Text(
                        '· ${monument.era}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: UrbinkColors.navInactive,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // Bouton ×
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 30,
              height: 30,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: UrbinkColors.surfaceVariant,
              ),
              child: const Center(
                child: Text(
                  '×',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: UrbinkColors.navInactive,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _StatusCard
// ---------------------------------------------------------------------------

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.monument,
    required this.collectionColor,
  });

  final CollectionMonument monument;
  final Color collectionColor;

  @override
  Widget build(BuildContext context) {
    final isLocked = monument.locked;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isLocked
              ? UrbinkColors.surfaceVariant
              : collectionColor.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isLocked
                ? UrbinkColors.border
                : collectionColor.withValues(alpha: 0.19),
          ),
        ),
        child: Row(
          children: [
            Text(
              isLocked ? '🔒' : '🏆',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isLocked ? AppLocalizations.of(context).mon_locked : AppLocalizations.of(context).mon_visited,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isLocked
                          ? UrbinkColors.navInactive
                          : collectionColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isLocked
                        ? AppLocalizations.of(context).mon_locked_sub
                        : AppLocalizations.of(context).mon_visited_sub,
                    style: const TextStyle(
                      fontSize: 11,
                      color: UrbinkColors.navInactive,
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

// ---------------------------------------------------------------------------
// _ActionsRow
// ---------------------------------------------------------------------------

class _ActionsRow extends StatelessWidget {
  const _ActionsRow({
    required this.monument,
    required this.collectionColor,
    required this.onShowOnMap,
  });

  final CollectionMonument monument;
  final Color collectionColor;
  final VoidCallback onShowOnMap;

  void _share() {
    final parts = <String>[monument.name];
    if (monument.era.isNotEmpty) parts.add(monument.era);
    if (monument.arrondissement.isNotEmpty) parts.add('${monument.arrondissement} arr.');
    final header = parts.join(' · ');
    final body = monument.description.isNotEmpty
        ? '\n${monument.description}\n\n'
        : '\n\n';
    Share.share(
      '$header$body Découvert avec Urbink — https://urbink.app',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Bouton Partager
          Expanded(
            child: SizedBox(
              height: 48,
              child: OutlinedButton.icon(
                onPressed: _share,
                icon: const Icon(Icons.share_outlined, size: 16),
                label: Text(
                  AppLocalizations.of(context).btn_share,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(
                      color: UrbinkColors.border, width: 1.5),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  foregroundColor: UrbinkColors.onSurface,
                ),
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Bouton Voir sur la carte
          Expanded(
            flex: 2,
            child: SizedBox(
              height: 48,
              child: FilledButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  onShowOnMap();
                },
                icon: const Text('🧭',
                    style: TextStyle(fontSize: 14)),
                label: Text(
                  AppLocalizations.of(context).btn_show_on_map,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: collectionColor,
                  elevation: 4,
                  shadowColor: collectionColor.withValues(alpha: 0.33),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
