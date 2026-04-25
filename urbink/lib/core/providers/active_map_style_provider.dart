import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urbink/core/config/map_style_config.dart';

/// Style de carte actif — par défaut le premier de [mapStylesRegistry].
///
/// L'UI de sélection (settings) mettra à jour ce provider.
/// La persistance en SharedPreferences sera ajoutée dans une story dédiée.
final activeMapStyleProvider = StateProvider<MapStyleConfig>((ref) {
  return mapStylesRegistry.first;
});
