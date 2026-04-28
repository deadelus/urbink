import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

/// Position demandée pour centrer la carte programmatiquement.
///
/// Mis à jour par tout écran souhaitant déplacer le viewport (ex: "Voir sur carte"
/// depuis l'écran Challenges). MapScreen observe ce provider et appelle
/// `mapController.move()` puis remet la valeur à null.
final mapFocusProvider = StateProvider<LatLng?>((ref) => null);
