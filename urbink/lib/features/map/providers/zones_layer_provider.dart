import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Visibilité de la couche zones (arrondissements / quartiers) sur la carte.
/// Contrôlé par [ZonesTogglePill] et le toggle "Délimitation quartier" en bottom sheet.
final zonesLayerVisibleProvider = StateProvider<bool>((ref) => false);
