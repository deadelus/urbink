import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

/// Service de tracking GPS temps réel.
///
/// Émet les positions GPS filtrées : une nouvelle position n'est émise
/// que si l'utilisateur s'est déplacé d'au moins [minDistanceMeters].
///
/// Gère les permissions iOS (WhenInUse → Always) et le mode arrière-plan.
class GpsTrackingService {
  static const double minDistanceMeters = 10.0;

  Position? _lastPosition;

  /// Demande la permission GPS.
  ///
  /// Sur iOS, tente d'obtenir "Toujours autoriser" pour le tracking arrière-plan.
  /// Retourne `true` si la permission est accordée (WhenInUse ou Always).
  Future<bool> requestPermission() async {
    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever ||
        permission == LocationPermission.denied) {
      return false;
    }

    // Sur iOS, demander "Toujours autoriser" pour le tracking arrière-plan
    if (Platform.isIOS && permission == LocationPermission.whileInUse) {
      permission = await Geolocator.requestPermission();
    }

    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  /// Stream de positions GPS filtrées (émis toutes les ~[minDistanceMeters] mètres).
  ///
  /// Le stream est actif tant qu'il est écouté.
  /// Continue en arrière-plan sur iOS grâce au background mode `location`
  /// configuré dans `Info.plist`.
  Stream<Position> positionStream() {
    _lastPosition = null;
    return Geolocator.getPositionStream(
      locationSettings: _locationSettings(),
    ).where(_hasMovedEnough);
  }

  LocationSettings _locationSettings() {
    if (Platform.isIOS) {
      return AppleSettings(
        accuracy: LocationAccuracy.high,
        activityType: ActivityType.fitness,
        distanceFilter: 5, // filtre bas-niveau geolocator, double-filtrage à 10m dans hasMovedEnough
        pauseLocationUpdatesAutomatically: false,
        showBackgroundLocationIndicator: true,
      );
    }
    return const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5,
    );
  }

  bool _hasMovedEnough(Position position) {
    final last = _lastPosition;
    if (last == null) {
      _lastPosition = position;
      return true;
    }

    final distance = Geolocator.distanceBetween(
      last.latitude,
      last.longitude,
      position.latitude,
      position.longitude,
    );

    if (distance >= minDistanceMeters) {
      _lastPosition = position;
      return true;
    }
    return false;
  }

  /// Calcule si deux positions sont suffisamment éloignées pour être émises.
  ///
  /// Exposé pour les tests unitaires.
  @visibleForTesting
  static bool hasMovedEnoughBetween(Position last, Position current) {
    final distance = Geolocator.distanceBetween(
      last.latitude,
      last.longitude,
      current.latitude,
      current.longitude,
    );
    return distance >= minDistanceMeters;
  }
}
