import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urbink/features/map/providers/map_layers_provider.dart';
import 'package:urbink/features/map/providers/monument_category_filter_provider.dart';
import 'package:urbink/features/map/providers/monuments_provider.dart';
import 'package:urbink/shared/constants/colors.dart';

// Zoom minimum — visible seulement au niveau quartier/rue (≥ 14)
const double _kMonumentsMinZoom = 14.0;

/// Couche flutter_map affichant les monuments filtrés par catégorie et sous-type.
///
/// Un monument est rendu si :
///   1. Le toggle "Monuments" du bottom sheet est activé (mapLayersProvider)
///   2. Le zoom est ≥ 14
///   3. [monumentVisibilityPredicateProvider] retourne true (catégorie + sous-type)
///   4. Il est dans le viewport courant (viewport culling via MapCamera)
///
/// À placer dans les `children` de [FlutterMap] après [MapZonesOverlay].
class MapMonumentsOverlay extends ConsumerWidget {
  const MapMonumentsOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final layers = ref.watch(mapLayersProvider);
    if (!(layers['monuments'] ?? true)) return const SizedBox.shrink();

    // MapCamera.of(context) crée une dépendance inherited :
    // rebuild automatique à chaque pan/zoom.
    final camera = MapCamera.of(context);
    if (camera.zoom < _kMonumentsMinZoom) return const SizedBox.shrink();

    final hasFilters = ref.watch(hasActiveMonumentFiltersProvider);
    if (!hasFilters) return const SizedBox.shrink();

    final isVisible = ref.watch(monumentVisibilityPredicateProvider);
    final monumentsAsync = ref.watch(monumentsProvider);

    return monumentsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (monuments) {
        final bounds = camera.visibleBounds;
        final circles = <CircleMarker>[];

        for (final m in monuments) {
          if (!isVisible(m)) continue;
          if (!bounds.contains(m.position)) continue;
          circles.add(CircleMarker(
            point: m.position,
            radius: 5.0,
            color: UrbinkColors.accent.withValues(alpha: 0.75),
            borderColor: Colors.white.withValues(alpha: 0.9),
            borderStrokeWidth: 1.0,
            useRadiusInMeter: false,
          ));
        }

        return CircleLayer(circles: circles);
      },
    );
  }
}
