import 'dart:math' show min, max;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:urbink/core/providers/city_config_provider.dart';
import 'package:urbink/features/map/models/zone_data.dart';
import 'package:urbink/features/map/providers/zones_layer_provider.dart';
import 'package:urbink/features/map/providers/zones_provider.dart';
import 'package:urbink/features/map/providers/zones_zoom_provider.dart';

// Couleurs spec V1 — #0F172A @ 35% opacité
const Color _kStroke = Color(0x590F172A);
// Labels — #64748B (token muted)
const Color _kLabel = Color(0xFF64748B);

/// Couche flutter_map affichant les délimitations de zones géographiques.
///
/// Les niveaux et seuils de zoom sont définis par [CityConfig.zoneLevels],
/// ce qui rend ce widget agnostique à la ville et à ses subdivisions.
///
/// À placer dans les `children` de [FlutterMap] après [VectorTileLayer].
class MapZonesOverlay extends ConsumerWidget {
  const MapZonesOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(zonesLayerVisibleProvider)) return const SizedBox.shrink();

    final zoom = ref.watch(zonesZoomProvider);
    final cityConfig = ref.watch(cityConfigProvider);
    final level = cityConfig.activeLevelFor(zoom);

    if (level == null) return const SizedBox.shrink();

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: _ZonesLayer(
        key: ValueKey(level.assetKey),
        provider: zonesProviderFamily(level.assetKey),
        strokeWidth: level.strokeWidth,
        labelSize: level.labelSize,
        dynamicWidth: level.dynamicWidth,
        labelBuilder: level.labelBuilder != null
            ? (z) => level.labelBuilder!(z.name)
            : (z) => z.name,
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _ZonesLayer extends ConsumerWidget {
  final ProviderListenable<AsyncValue<List<ZoneData>>> provider;
  final double strokeWidth;
  final double labelSize;
  final bool dynamicWidth;
  final String Function(ZoneData) labelBuilder;

  const _ZonesLayer({
    super.key,
    required this.provider,
    required this.strokeWidth,
    required this.labelSize,
    required this.dynamicWidth,
    required this.labelBuilder,
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
