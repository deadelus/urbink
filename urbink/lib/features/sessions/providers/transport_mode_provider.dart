import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:urbink/features/sessions/models/transport_mode.dart';

class TransportModeNotifier extends Notifier<TransportMode> {
  static const _prefsKey = 'urbink_transport_mode';
  var _disposed = false;

  // Exposé pour les tests : permet d'attendre la fin du chargement initial
  // sans recourir à un délai fixe.
  late Future<void> initialized;

  @override
  TransportMode build() {
    _disposed = false;
    ref.onDispose(() => _disposed = true);
    initialized = _loadFromPrefs();
    return TransportMode.walking;
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (_disposed) return;
    final stored = prefs.getString(_prefsKey);
    if (stored == null) return;
    try {
      state = TransportMode.values.firstWhere((m) => m.name == stored);
    } catch (_) {
      // Valeur inconnue — on reste sur walking
    }
  }

  /// Sélectionne un mode de transport et le persiste dans SharedPreferences.
  Future<void> select(TransportMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, mode.name);
  }
}

final transportModeProvider =
    NotifierProvider<TransportModeNotifier, TransportMode>(
  TransportModeNotifier.new,
);
