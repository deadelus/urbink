import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urbink/features/map/providers/map_state_provider.dart';
import 'package:urbink/shared/constants/map_constants.dart';
import 'package:urbink/shared/widgets/urbink_snack_bar.dart';
import 'package:vector_map_tiles/vector_map_tiles.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  late final MapController _mapController;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;

  Style? _mapStyle;
  bool _styleLoading = true;
  String? _styleError;

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
          message: 'Mode hors-ligne — carte limitée au cache',
          type: UrbinkSnackBarType.info,
        );
      }
    });
  }

  Future<void> _loadStyle() async {
    try {
      final style = await StyleReader(
        uri: MapConstants.mapTilerStyleUrl,
      ).read();
      if (mounted) setState(() { _mapStyle = style; _styleLoading = false; });
    } catch (e, s) {
      // Log only the exception type — never e.toString() which may include
      // the MapTiler API key embedded in the style URL.
      debugPrint('MapStyle loading error: ${e.runtimeType}');
      // Crashlytics is disabled in debug (see FirebaseService._setupCrashlytics),
      // so this call is a no-op locally and only reports in staging/prod.
      FirebaseCrashlytics.instance.recordError(e, s,
          reason: 'MapStyle loading error', fatal: false);
      if (mounted) {
        setState(() {
          _styleError = 'Impossible de charger le style de la carte.';
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
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_styleError != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Erreur chargement style :\n$_styleError'),
          ),
        ),
      );
    }

    return Scaffold(
      body: FlutterMap(
        mapController: _mapController,
        options: const MapOptions(
          initialCenter: MapConstants.initialCenter,
          initialZoom: MapConstants.initialZoom,
          minZoom: MapConstants.minZoom,
          maxZoom: MapConstants.maxZoom,
        ),
        children: [
          VectorTileLayer(
            tileProviders: _mapStyle!.providers,
            theme: _mapStyle!.theme,
            sprites: _mapStyle!.sprites,
          ),
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
                  child: Text('© MapTiler © OSM', style: TextStyle(fontSize: 9)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
