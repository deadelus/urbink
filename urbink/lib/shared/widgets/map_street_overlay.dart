import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urbink/features/map/providers/map_street_overlay_provider.dart';
import 'package:urbink/shared/constants/colors.dart';

/// Couche flutter_map affichant les rues explorées en Vert Sauge.
///
/// - Rues explorées : [UrbinkColors.streetExplored] (#5A7A5A), opacité 0.75
/// - Rue en cours d'exploration : [UrbinkColors.streetRecording] (#6A9A6A),
///   trait légèrement plus épais pour signaler l'activité
///
/// À ajouter dans les `children` de [FlutterMap] après [VectorTileLayer].
class MapStreetOverlay extends ConsumerWidget {
  const MapStreetOverlay({super.key});

  static const double _strokeWidth = 4.0;
  static const double _strokeWidthRecording = 5.5;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overlayState = ref.watch(mapStreetOverlayProvider);

    if (overlayState.isEmpty) return const SizedBox.shrink();

    final polylines = overlayState.exploredStreets.entries
        .where((e) => e.value.length >= 2)
        .map((e) {
          final isRecording = e.key == overlayState.currentStreetId;
          return Polyline(
            points: e.value,
            color: isRecording
                ? UrbinkColors.streetRecording
                : UrbinkColors.streetExplored.withValues(alpha: 0.75),
            strokeWidth:
                isRecording ? _strokeWidthRecording : _strokeWidth,
            strokeCap: StrokeCap.round,
            strokeJoin: StrokeJoin.round,
          );
        })
        .toList();

    return PolylineLayer(polylines: polylines);
  }
}
