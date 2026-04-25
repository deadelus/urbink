import 'dart:math' show min, max;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
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
              dynamicWidth: false,
            )
          : _ZonesLayer(
              key: const ValueKey('qrt'),
              provider: quartiersProvider,
              strokeWidth: 1.4,
              labelSize: 9.5,
              uppercase: true,
              labelBuilder: _qrtLabel,
              dynamicWidth: true,
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
  final bool dynamicWidth;
  final String Function(ZoneData) labelBuilder;

  const _ZonesLayer({
    super.key,
    required this.provider,
    required this.strokeWidth,
    required this.labelSize,
    required this.uppercase,
    required this.labelBuilder,
    required this.dynamicWidth,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final camera = MapCamera.of(context);
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
            markers: zones.map((z) {
              final (w, h) = dynamicWidth
                  ? _zoneBounds(camera, z.polygon)
                  : (90.0, 22.0);
              return Marker(
                point: z.centroid,
                width: w,
                height: h,
                alignment: Alignment.center,
                child: Text(
                  labelBuilder(z),
                  textAlign: TextAlign.center,
                  softWrap: dynamicWidth,
                  overflow: dynamicWidth
                      ? TextOverflow.visible
                      : TextOverflow.ellipsis,
                  maxLines: dynamicWidth ? 3 : 1,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    fontSize: labelSize,
                    color: _kLabel,
                    letterSpacing: 0.4,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}

/// Computes the screen-space bounding box of a polygon at the current camera.
/// Width is clamped to [60, 220], height to [20, 80].
(double, double) _zoneBounds(MapCamera camera, List<LatLng> polygon) {
  if (polygon.isEmpty) return (80.0, 30.0);
  var minLat = polygon[0].latitude;
  var maxLat = minLat;
  var minLng = polygon[0].longitude;
  var maxLng = minLng;
  for (final p in polygon) {
    minLat = min(minLat, p.latitude);
    maxLat = max(maxLat, p.latitude);
    minLng = min(minLng, p.longitude);
    maxLng = max(maxLng, p.longitude);
  }
  final sw = camera.latLngToScreenPoint(LatLng(minLat, minLng));
  final ne = camera.latLngToScreenPoint(LatLng(maxLat, maxLng));
  final w = (ne.x - sw.x).abs().clamp(60.0, 220.0);
  final h = (sw.y - ne.y).abs().clamp(20.0, 80.0);
  return (w, h);
}
