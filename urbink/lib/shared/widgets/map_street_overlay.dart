import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urbink/features/map/providers/aggregation_provider.dart';
import 'package:urbink/features/map/providers/historical_streets_provider.dart';
import 'package:urbink/features/map/providers/map_street_overlay_provider.dart';
import 'package:urbink/features/map/providers/streets_visible_provider.dart';
import 'package:urbink/shared/constants/colors.dart';

/// Couche flutter_map affichant les rues explorées en Vert Sauge.
///
/// Deux couches superposées :
/// - **Historique** (`historicalStreetsProvider` filtré par `aggregationProvider`) :
///   rues des sessions précédentes, alpha 0.4 — fond permanent état idle (FR7).
///   `aggregationProvider` est la source de vérité des IDs à afficher ; en Story 3.2
///   il sera filtré par date sans modifier ce widget.
/// - **Live** (`mapStreetOverlayProvider`) : rues de la session courante,
///   alpha 0.75 + rue en cours en [UrbinkColors.streetRecording].
///
/// L'affichage est contrôlé par [streetsVisibleProvider] (toggle Zones).
/// Le tracking passif continue en arrière-plan indépendamment du toggle.
///
/// À ajouter dans les `children` de [FlutterMap] après [VectorTileLayer].
class MapStreetOverlay extends ConsumerWidget {
  const MapStreetOverlay({super.key});

  static const double _strokeWidth = 4.0;
  static const double _strokeWidthRecording = 5.5;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Toggle Zones : si masqué, retourner vide sans stopper le tracking
    if (!ref.watch(streetsVisibleProvider)) return const SizedBox.shrink();

    final liveState = ref.watch(mapStreetOverlayProvider);
    final aggregationAsync = ref.watch(aggregationProvider);
    final aggregatedIds = aggregationAsync.valueOrNull ?? const <String>{};
    final allHistoricalStreets = ref.watch(historicalStreetsProvider).valueOrNull ?? {};

    final historicalStreets = {
      for (final e in allHistoricalStreets.entries)
        if (aggregatedIds.contains(e.key)) e.key: e.value,
    };

    // Rues historiques (fond) — exclut celles déjà dans l'état live pour éviter doublons
    final historicalPolylines = historicalStreets.entries
        .where((e) => e.value.length >= 2 && !liveState.exploredStreets.containsKey(e.key))
        .map(
          (e) => Polyline(
            points: e.value,
            color: UrbinkColors.streetExplored.withValues(alpha: 0.4),
            strokeWidth: _strokeWidth,
            strokeCap: StrokeCap.round,
            strokeJoin: StrokeJoin.round,
          ),
        )
        .toList();

    // Rues live (dessus) — session courante + rue en cours d'enregistrement
    final livePolylines = liveState.exploredStreets.entries
        .where((e) => e.value.length >= 2)
        .map((e) {
          final isRecording = e.key == liveState.currentStreetId;
          return Polyline(
            points: e.value,
            color: isRecording
                ? UrbinkColors.streetRecording
                : UrbinkColors.streetExplored.withValues(alpha: 0.75),
            strokeWidth: isRecording ? _strokeWidthRecording : _strokeWidth,
            strokeCap: StrokeCap.round,
            strokeJoin: StrokeJoin.round,
          );
        })
        .toList();

    if (historicalPolylines.isEmpty && livePolylines.isEmpty) return const SizedBox.shrink();

    return Stack(
      children: [
        if (historicalPolylines.isNotEmpty)
          AnimatedOpacity(
            opacity: aggregationAsync.isLoading ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 250),
            child: PolylineLayer(polylines: historicalPolylines),
          ),
        if (livePolylines.isNotEmpty) PolylineLayer(polylines: livePolylines),
      ],
    );
  }
}
