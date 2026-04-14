import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urbink/features/map/providers/map_state_provider.dart';
import 'package:urbink/features/sessions/models/session.dart';
import 'package:urbink/features/sessions/providers/crash_recovery_provider.dart';
import 'package:urbink/features/sessions/providers/session_lifecycle_provider.dart';
import 'package:urbink/shared/constants/map_constants.dart';
import 'package:urbink/shared/widgets/map_street_overlay.dart';
import 'package:urbink/shared/widgets/session_counter.dart';
import 'package:urbink/shared/widgets/urbink_snack_bar.dart';
import 'package:urbink/shared/widgets/zones_toggle_pill.dart';
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

    // Crash recovery — vérification au premier rendu
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

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Reprendre la session précédente ?'),
        content: Text(
          '$distanceLabel · $durationLabel\n'
          'Une session a été interrompue. Tu peux la reprendre ou l\'abandonner.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Abandonner'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Reprendre'),
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
      final style = await StyleReader(
        uri: MapConstants.mapTilerStyleUrl,
      ).read();
      if (mounted) setState(() { _mapStyle = style; _styleLoading = false; });
    } catch (e, s) {
      debugPrint('MapStyle loading error: ${e.runtimeType}');
      if (!kDebugMode) {
        FirebaseCrashlytics.instance.recordError(e, s,
            reason: 'MapStyle loading error', fatal: false);
      }
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
      body: Stack(
        children: [
          FlutterMap(
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
              const MapStreetOverlay(),
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
          const SessionCounter(),
          // Pill Zones bas-gauche — toggle affichage rues explorées (FR10b)
          const Positioned(
            left: 16,
            bottom: 16,
            child: ZonesTogglePill(),
          ),
        ],
      ),
    );
  }
}
