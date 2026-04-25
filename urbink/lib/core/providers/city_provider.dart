import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Ville active — détermine les assets geo chargés (`assets/geo/{city}/`).
///
/// Valeur par défaut : 'paris'. La géolocalisation automatique et la
/// sélection manuelle seront branchées ici dans une story multi-ville dédiée.
final currentCityProvider = StateProvider<String>((ref) => 'paris');
