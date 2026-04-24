import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urbink/features/map/models/zone_data.dart';
import 'package:urbink/features/map/providers/arrondissements_provider.dart';
import 'package:urbink/features/map/providers/quartiers_provider.dart';
import 'package:urbink/features/map/providers/zones_layer_provider.dart';
import 'package:urbink/features/map/providers/zones_zoom_provider.dart';

// Seuil de bascule arrondissements ↔ quartiers (spec V1)
const double _kZoomThreshold = 13.5;

// Couleurs spec V1 — #0F172A @ 35% opacité
const Color _kStroke = Color(0x590F172A);
// Labels — #64748B (token muted)
const Color _kLabel = Color(0xFF64748B);

/// Couche flutter_map affichant les délimitations de zones parisiennes.
///
/// - Zoom < 13.5 → 20 arrondissements, strokeWidth 1.2, labels numériques
/// - Zoom ≥ 13.5 → ~110 quartiers, strokeWidth 1.4, labels en MAJUSCULES
///
/// Contour pointillé (StrokePattern.dashed [3, 2.5]), aucun remplissage.
/// Crossfade 250ms à la bascule de zoom.
/// Aucune interaction (purement informatif).
///
/// À placer dans les `children` de [FlutterMap] après [VectorTileLayer].
class MapZonesOverlay extends ConsumerWidget {
  const MapZonesOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(zonesLayerVisibleProvider)) return const SizedBox.shrink();

    final zoom = ref.watch(zonesZoomProvider);
    final isArrondissement = zoom < _kZoomThreshold;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: isArrondissement
          ? _ZonesLayer(
              key: const ValueKey('arr'),
              provider: arrondissementsProvider,
              strokeWidth: 1.2,
              labelSize: 11.0,
              uppercase: false,
              labelBuilder: _arrLabel,
            )
          : _ZonesLayer(
              key: const ValueKey('qrt'),
              provider: quartiersProvider,
              strokeWidth: 1.4,
              labelSize: 9.0,
              uppercase: true,
              labelBuilder: _qrtLabel,
            ),
    );
  }

  static String _arrLabel(ZoneData z) =>
      z.name.replaceAll(RegExp(r'[erème]+$'), '');

  static String _qrtLabel(ZoneData z) => z.name.toUpperCase();
}

// ---------------------------------------------------------------------------

class _ZonesLayer extends ConsumerWidget {
  final ProviderListenable<AsyncValue<List<ZoneData>>> provider;
  final double strokeWidth;
  final double labelSize;
  final bool uppercase;
  final String Function(ZoneData) labelBuilder;

  const _ZonesLayer({
    super.key,
    required this.provider,
    required this.strokeWidth,
    required this.labelSize,
    required this.uppercase,
    required this.labelBuilder,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final zonesAsync = ref.watch(provider);
    return zonesAsync.when(
      data: (zones) => Stack(
        children: [
          PolygonLayer(
            polygons: zones
                .map(
                  (z) => Polygon(
                    points: z.polygon,
                    color: Colors.transparent,
                    borderColor: _kStroke,
                    borderStrokeWidth: strokeWidth,
                    pattern: StrokePattern.dashed(segments: [3.0, 2.5]),
                  ),
                )
                .toList(),
          ),
          MarkerLayer(
            rotate: true,
            markers: zones
                .map(
                  (z) => Marker(
                    point: z.centroid,
                    width: 90,
                    height: 22,
                    alignment: Alignment.center,
                    child: Text(
                      labelBuilder(z),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                        fontSize: labelSize,
                        color: _kLabel,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}
