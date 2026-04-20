import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urbink/features/map/providers/historical_streets_provider.dart';
import 'package:urbink/features/map/providers/map_street_overlay_provider.dart';
import 'package:urbink/features/map/providers/streets_visible_provider.dart';
import 'package:urbink/shared/constants/colors.dart';

/// Couche flutter_map affichant les rues explorées en Vert Sauge.
///
/// Deux couches superposées :
/// - **Historique** (`historicalStreetsProvider`) : rues des sessions précédentes,
///   alpha 0.4 — fond permanent même sans session active (état idle, FR7).
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
    final historicalStreets = ref.watch(historicalStreetsProvider).valueOrNull ?? {};

    final hasHistorical = historicalStreets.isNotEmpty;
    final hasLive = !liveState.isEmpty;

    if (!hasHistorical && !hasLive) return const SizedBox.shrink();

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

    return PolylineLayer(polylines: [...historicalPolylines, ...livePolylines]);
  }
}
