import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urbink/features/map/providers/map_layers_provider.dart';
import 'package:urbink/features/map/providers/monument_category_filter_provider.dart';
import 'package:urbink/features/map/providers/monuments_provider.dart';
import 'package:urbink/shared/constants/colors.dart';

// Zoom minimum pour afficher les monuments.
// En-dessous, trop de POIs seraient visibles sur la vue complète de Paris.
const double _kMonumentsMinZoom = 14.0;

/// Couche flutter_map affichant les monuments parisiens sous forme de cercles.
///
/// Trois mécanismes de réduction du nombre de points rendus :
/// 1. Seuil de zoom — masqué si zoom < 14 (trop de points à vue d'ensemble)
/// 2. Filtre catégories — [monumentHiddenCategoriesProvider] (bâtiments/hôtels masqués par défaut)
/// 3. Viewport culling — seuls les monuments dans les bounds visibles sont rendu
///
/// À placer dans les `children` de [FlutterMap] après [MapZonesOverlay].
class MapMonumentsOverlay extends ConsumerWidget {
  const MapMonumentsOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final layers = ref.watch(mapLayersProvider);
    if (!(layers['monuments'] ?? true)) return const SizedBox.shrink();

    // MapCamera.of(context) crée une dépendance sur l'inherited model :
    // le widget se reconstruit automatiquement à chaque pan/zoom.
    final camera = MapCamera.of(context);
    if (camera.zoom < _kMonumentsMinZoom) return const SizedBox.shrink();

    final hiddenCategories = ref.watch(monumentHiddenCategoriesProvider);
    final monumentsAsync = ref.watch(monumentsProvider);

    return monumentsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (monuments) {
        final bounds = camera.visibleBounds;
        final circles = <CircleMarker>[];

        for (final m in monuments) {
          if (hiddenCategories.contains(m.category)) continue;
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
