import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Fournit une instance stable de [MapController] pour toute la vie de l'app.
///
/// Utilisé par [MapScreen] pour contrôler la carte programmatiquement
/// (déplacer, zoomer) dans les stories suivantes (2.3, 2.4, 2.5).
final mapControllerProvider = Provider<MapController>((ref) {
  return MapController();
});
