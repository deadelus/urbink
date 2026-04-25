import 'dart:async';
import 'dart:convert' show jsonDecode;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:urbink/core/router/app_router.dart';
import 'package:urbink/features/map/providers/map_state_provider.dart';
import 'package:urbink/features/map/providers/zones_layer_provider.dart';
import 'package:urbink/features/map/providers/zones_zoom_provider.dart';
import 'package:urbink/features/map/widgets/sorties_bottom_sheet.dart';
import 'package:urbink/features/sessions/models/session.dart';
import 'package:urbink/features/sessions/providers/crash_recovery_provider.dart';
import 'package:urbink/features/sessions/providers/session_lifecycle_provider.dart';
import 'package:urbink/features/sessions/session_state_provider.dart';
import 'package:urbink/l10n/app_localizations.dart';
import 'package:urbink/shared/constants/colors.dart';
import 'package:urbink/shared/constants/map_constants.dart';
import 'package:urbink/shared/constants/spacing.dart';
import 'package:urbink/shared/constants/typography.dart';
import 'package:urbink/shared/widgets/filter_chips_row.dart';
import 'package:urbink/shared/widgets/map_street_overlay.dart';
import 'package:urbink/shared/widgets/map_zones_overlay.dart';
import 'package:urbink/shared/widgets/time_filter_select.dart';
import 'package:urbink/shared/widgets/urbink_snack_bar.dart';
import 'package:urbink/shared/widgets/zones_toggle_pill.dart';
import 'package:vector_map_tiles/vector_map_tiles.dart';
import 'package:vector_tile_renderer/vector_tile_renderer.dart' show ThemeReader;

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key, this.hideSearchBar = false, this.showBottomUi = true});

  /// When true, hides the floating search bar and filter chips.
  /// Used by _CreateItineraireScreen to avoid overlap with its own header.
  final bool hideSearchBar;

  /// When false, hides SortiesBottomSheet and ZonesTogglePill.
  /// Set to false when embedding MapScreen inside another screen that provides
  /// its own bottom sheet and pill positioning.
  final bool showBottomUi;

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  late final MapController _mapController;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;

  Style? _mapStyle;
  bool _styleLoading = true;
  bool _styleLoadFailed = false;


  @override
  void initState() {
    super.initState();
    _mapController = ref.read(mapControllerProvider);
    _loadStyle();

    _connectivitySub = Connectivity().onConnectivityChanged.listen((results) {
      if (!mounted) return;
      if (results.every((r) => r == ConnectivityResult.none)) {
        showUrbinkSnackBar(
          context,
          message: AppLocalizations.of(context).offline_mode_message,
          type: UrbinkSnackBarType.info,
        );
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final uid = ref.read(currentUidProvider);
      if (uid == null) return;
      final crashService = ref.read(crashRecoveryServiceProvider);
      final interrupted = await crashService.checkForInterruptedSession(uid);
      if (interrupted != null && mounted) {
        await _showCrashRecoveryDialog(interrupted);
      }
    });
  }

  Future<void> _showCrashRecoveryDialog(Session session) async {
    final duration = session.duration;
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds =
        duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    final durationLabel =
        duration.inHours > 0 ? '${duration.inHours}:$minutes:$seconds' : '$minutes:$seconds';
    final distanceLabel = session.distanceKm >= 1.0
        ? '${session.distanceKm.toStringAsFixed(1)} km'
        : '${session.distanceMeters.toStringAsFixed(0)} m';

    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.resume_session_title),
        content: Text('$distanceLabel · $durationLabel\n${l10n.session_interrupted_message}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.btn_discard),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.btn_resume),
          ),
        ],
      ),
    );

    if (!mounted) return;

    if (confirmed == true) {
      await ref
          .read(sessionLifecycleProvider.notifier)
          .resumeFromCrash(session);
    } else {
      await ref
          .read(sessionLifecycleProvider.notifier)
          .cancelInterrupted(session.sessionId);
    }
  }

  Future<void> _loadStyle() async {
    try {
      // Load providers + sprites via StyleReader (handles URL mapping, auth).
      final baseStyle = await StyleReader(uri: MapConstants.mapTilerStyleUrl).read();

      // Fetch raw JSON separately to scale down natural-feature label sizes.
      Style style = baseStyle;
      try {
        final response = await http
            .get(Uri.parse(MapConstants.mapTilerStyleUrl))
            .timeout(const Duration(seconds: 10));
        if (response.statusCode == 200) {
          final json = jsonDecode(response.body) as Map<String, dynamic>;
          _scaleNaturalLabelSizes(json);
          final modifiedTheme = ThemeReader().read(json);
          style = Style(
            name: baseStyle.name,
            theme: modifiedTheme,
            providers: baseStyle.providers,
            sprites: baseStyle.sprites,
            center: baseStyle.center,
            zoom: baseStyle.zoom,
          );
        }
      } catch (_) {
        // Fall back to unmodified style on any error.
      }

      if (mounted) setState(() { _mapStyle = style; _styleLoading = false; });
    } catch (e, s) {
      debugPrint('MapStyle loading error: ${e.runtimeType}');
      if (!kDebugMode) {
        FirebaseCrashlytics.instance.recordError(e, s,
            reason: 'MapStyle loading error', fatal: false);
      }
      if (mounted) {
        setState(() {
          _styleLoadFailed = true;
          _styleLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _connectivitySub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_styleLoading) {
      return const Scaffold(
        backgroundColor: UrbinkColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_styleLoadFailed) {
      final l10n = AppLocalizations.of(context);
      return Scaffold(
        backgroundColor: UrbinkColors.background,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(l10n.error_map_style),
          ),
        ),
      );
    }

    final sessionState = ref.watch(sessionStateProvider);
    final isIdle = sessionState == SessionState.idle;
    final zonesVisible = ref.watch(zonesLayerVisibleProvider);
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: UrbinkColors.background,
      body: Stack(
        children: [
          // ── Carte plein écran ──────────────────────────────────────────────
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: MapConstants.initialCenter,
              initialZoom: MapConstants.initialZoom,
              minZoom: MapConstants.minZoom,
              maxZoom: MapConstants.maxZoom,
              onMapEvent: (event) {
                ref.read(zonesZoomProvider.notifier).state =
                    event.camera.zoom;
              },
            ),
            children: [
              VectorTileLayer(
                tileProviders: _mapStyle!.providers,
                theme: _mapStyle!.theme,
                sprites: _mapStyle!.sprites,
              ),
              const MapStreetOverlay(),
              const MapZonesOverlay(),
              Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 4, bottom: 4),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      child: Text('© MapTiler © OSM',
                          style: TextStyle(fontSize: 9)),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // ── Floating search bar + chips (masqués en session ou quand hideSearchBar) ──
          if (isIdle && !widget.hideSearchBar)
            Positioned(
              top: topPadding + 10,
              left: UrbinkSpacing.md,
              right: UrbinkSpacing.md,
              child: Column(
                children: [
                  _FloatingSearchBar(),
                  const SizedBox(height: UrbinkSpacing.sm),
                  FilterChipsRow(
                    onMoreTap: () => context.push(AppRoutes.filters),
                  ),
                ],
              ),
            ),

          // ── Pill Zones + filtre temporel + Bottom sheet ──────────────
          if (widget.showBottomUi) ...[
            Positioned(
              left: UrbinkSpacing.md,
              bottom: SortiesBottomSheet.collapsedHeight + UrbinkSpacing.md,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const ZonesTogglePill(),
                  if (isIdle && zonesVisible) ...[
                    const SizedBox(width: UrbinkSpacing.sm),
                    const TimeFilterSelect(),
                  ],
                ],
              ),
            ),
            const SortiesBottomSheet(),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Style post-processing — scale down natural/water feature label sizes.
// Reduces visual clutter for large area labels (parks, lakes, forests).
// ---------------------------------------------------------------------------

// Le renderer fait floor() sur minzoom → 14.0 donne floor=14, ce qui garantit
// que les labels n'apparaissent qu'à zoom entier ≥ 14 (mode quartier uniquement).
const double _kNaturalLabelMinZoom = 14.0;

void _scaleNaturalLabelSizes(Map<String, dynamic> styleJson) {
  final layers = styleJson['layers'];
  if (layers is! List) return;
  for (final layer in layers) {
    if (layer is! Map<String, dynamic>) continue;
    if (layer['type'] != 'symbol') continue;
    final src = (layer['source-layer'] as String?) ?? '';
    final id = (layer['id'] as String?) ?? '';
    final currentMin = (layer['minzoom'] as num?)?.toDouble() ?? 0.0;

    final isNatural = _isNaturalLabelLayer(src, id);
    // Toute couche symbol visible avant zoom 12 est un label de grande zone
    // (lac, parc, forêt…) — même si son nom de couche ne correspond pas.
    final appearsVeryEarly = currentMin < 12.0;

    if (!isNatural && !appearsVeryEarly) continue;

    if (currentMin < _kNaturalLabelMinZoom) {
      layer['minzoom'] = _kNaturalLabelMinZoom;
    }

    if (isNatural) {
      final layout = layer['layout'];
      if (layout is Map<String, dynamic>) {
        final size = layout['text-size'];
        if (size != null) layout['text-size'] = _scaleTextSize(size, 0.65);
      }
    }
  }
}

bool _isNaturalLabelLayer(String src, String id) {
  const keywords = ['water', 'natural', 'park', 'landuse', 'landcover', 'land'];
  for (final kw in keywords) {
    if (src.contains(kw) || id.contains(kw)) return true;
  }
  return false;
}

dynamic _scaleTextSize(dynamic size, double factor) {
  if (size is num) return size.toDouble() * factor;
  if (size is List) {
    final r = List<dynamic>.from(size);
    if (r.isNotEmpty && r[0] == 'interpolate') {
      // ["interpolate", method, ["zoom"], z0, v0, z1, v1, ...]
      // output values at indices 4, 6, 8, …
      for (var i = 4; i < r.length; i += 2) {
        if (r[i] is num) r[i] = (r[i] as num).toDouble() * factor;
      }
      return r;
    }
  }
  return size;
}

// ---------------------------------------------------------------------------
// Floating search bar
// ---------------------------------------------------------------------------

class _FloatingSearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: UrbinkColors.surface,
        borderRadius: BorderRadius.circular(UrbinkSpacing.radiusButton),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          const Icon(Icons.search_rounded, color: UrbinkColors.navInactive, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              AppLocalizations.of(context).search_placeholder,
              style: const TextStyle(
                fontFamily: UrbinkTypography.bodyFamily,
                fontSize: 14,
                color: UrbinkColors.navInactive,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.mic_none_rounded,
                color: UrbinkColors.navInactive, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
          ),
        ],
      ),
    );
  }
}

