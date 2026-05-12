import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:urbink/features/parcours/data/parcours_model.dart';
import 'package:urbink/features/parcours/data/parcours_repository.dart';
import 'package:urbink/features/parcours/providers/parcours_provider.dart';
import 'package:urbink/features/parcours/services/parcours_generation_service.dart';
import 'package:urbink/features/sessions/models/transport_mode.dart';

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

sealed class ParcoursGenerationState {
  const ParcoursGenerationState();
}

class ParcoursGenerationIdle extends ParcoursGenerationState {
  const ParcoursGenerationIdle();
}

class ParcoursGenerationLoading extends ParcoursGenerationState {
  const ParcoursGenerationLoading();
}

class ParcoursGenerationSuccess extends ParcoursGenerationState {
  const ParcoursGenerationSuccess({
    required this.parcours,
    required this.newStreetsCount,
  });

  final Parcours parcours;
  final int newStreetsCount;
}

class ParcoursGenerationError extends ParcoursGenerationState {
  const ParcoursGenerationError({required this.message});

  final String message;
}

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

/// HTTP client partagé — injectable en test.
final httpClientProvider = Provider<http.Client>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return client;
});

/// Fournit le token Firebase Auth ID — injectable en test.
final authTokenProvider =
    Provider<Future<String?> Function()>((ref) {
  return () async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    return user.getIdToken();
  };
});

/// Service de génération — injectable en test.
final parcoursGenerationServiceProvider =
    Provider<ParcoursGenerationService>((ref) {
  return ParcoursGenerationService(
    httpClient: ref.watch(httpClientProvider),
    getIdToken: ref.watch(authTokenProvider),
  );
});

/// Notifier qui orchestre la génération de parcours automatique.
class ParcoursGenerationNotifier
    extends StateNotifier<ParcoursGenerationState> {
  ParcoursGenerationNotifier({
    required ParcoursGenerationService service,
    required ParcoursRepository repository,
  }) : super(const ParcoursGenerationIdle()) {
    _service = service;
    _repository = repository;
  }

  /// Constructeur réservé aux tests — les champs [_service] et [_repository]
  /// ne sont jamais accédés car [generate] et [saveParcours] sont surchargés.
  @visibleForTesting
  ParcoursGenerationNotifier.forTest(super.initialState);

  late final ParcoursGenerationService _service;
  late final ParcoursRepository _repository;

  Future<void> generate({
    required String uid,
    required double lat,
    required double lng,
    required int durationMinutes,
    required TransportMode mode,
  }) async {
    state = const ParcoursGenerationLoading();
    try {
      final result = await _service.generate(
        uid: uid,
        lat: lat,
        lng: lng,
        durationMinutes: durationMinutes,
        mode: mode,
      );
      state = ParcoursGenerationSuccess(
        parcours: result.parcours,
        newStreetsCount: result.newStreetsCount,
      );
    } on ParcoursGenerationException catch (e) {
      state = ParcoursGenerationError(message: e.message);
    } catch (_) {
      state = const ParcoursGenerationError(
        message: "Impossible de générer un parcours pour l'instant, réessaie dans quelques instants",
      );
    }
  }

  /// Sauvegarde le parcours généré dans Firestore et retourne son ID.
  Future<String?> saveParcours({required String uid, required Parcours parcours}) async {
    try {
      return await _repository.create(uid: uid, parcours: parcours);
    } catch (_) {
      return null;
    }
  }

  void reset() => state = const ParcoursGenerationIdle();
}

final parcoursGenerationNotifierProvider = StateNotifierProvider<
    ParcoursGenerationNotifier, ParcoursGenerationState>((ref) {
  return ParcoursGenerationNotifier(
    service: ref.watch(parcoursGenerationServiceProvider),
    repository: ref.watch(parcoursRepositoryProvider),
  );
});

/// Dernière position GPS connue (passive stream) — utilisée comme point de
/// départ du circuit. Fallback sur Paris centre si non disponible.
final lastKnownPositionProvider = FutureProvider<(double lat, double lng)>((ref) async {
  try {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return _parisCenter;
    }
    final pos = await Geolocator.getLastKnownPosition();
    if (pos != null) return (pos.latitude, pos.longitude);
    return _parisCenter;
  } catch (_) {
    return _parisCenter;
  }
});

const _parisCenter = (48.8566, 2.3522);
