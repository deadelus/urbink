import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urbink/features/map/providers/map_layers_provider.dart';
import 'package:urbink/features/map/providers/monuments_provider.dart';
import 'package:urbink/features/map/providers/zones_zoom_provider.dart';
import 'package:urbink/shared/constants/colors.dart';

// Minimum zoom pour afficher les monuments (évite le clutter à vue d'ensemble)
const double _kMonumentsMinZoom = 12.0;

/// Couche flutter_map affichant les 1999 monuments parisiens sous forme de
/// cercles colorés. Visible uniquement si le toggle "Monuments" est activé
/// et que le zoom est ≥ 12.
///
/// À placer dans les `children` de [FlutterMap] après [MapZonesOverlay].
class MapMonumentsOverlay extends ConsumerWidget {
  const MapMonumentsOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final layers = ref.watch(mapLayersProvider);
    if (!(layers['monuments'] ?? true)) return const SizedBox.shrink();

    final zoom = ref.watch(zonesZoomProvider);
    if (zoom < _kMonumentsMinZoom) return const SizedBox.shrink();

    final monumentsAsync = ref.watch(monumentsProvider);
    return monumentsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (monuments) {
        final circles = monuments
            .map((m) => CircleMarker(
                  point: m.position,
                  radius: 5.0,
                  color: UrbinkColors.accent.withValues(alpha: 0.75),
                  borderColor: Colors.white.withValues(alpha: 0.9),
                  borderStrokeWidth: 1.0,
                  useRadiusInMeter: false,
                ))
            .toList();
        return CircleLayer(circles: circles);
      },
    );
  }
}
