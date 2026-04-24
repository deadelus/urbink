import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

const _kKey = 'local_anon_uid';
const _uuid = Uuid();

String? _cached;

/// UID local anonyme — généré au 1er lancement sans réseau, persisté dans
/// SharedPreferences. Mis à jour avec le vrai Firebase UID dès que l'auth réussit
/// ([updateLocalAnonUid]), ce qui garantit la continuité des données SQLite→Firestore.
///
/// Toujours non-null après [initLocalAnonUid].
String get localAnonUid {
  assert(_cached != null, 'initLocalAnonUid() must be called before runApp()');
  return _cached!;
}

/// Initialise (ou restaure) le UID local. À appeler une fois dans main(),
/// avant Firebase et avant runApp().
Future<void> initLocalAnonUid() async {
  final prefs = await SharedPreferences.getInstance();
  _cached = prefs.getString(_kKey);
  if (_cached == null) {
    _cached = _uuid.v4();
    await prefs.setString(_kKey, _cached!);
  }
}

/// Met à jour le UID local avec le Firebase UID une fois l'auth réussie.
/// Persiste immédiatement dans SharedPreferences — les relances ultérieures
/// chargent directement le Firebase UID, même sans réseau.
Future<void> updateLocalAnonUid(String firebaseUid) async {
  if (_cached == firebaseUid) return;
  _cached = firebaseUid;
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_kKey, firebaseUid);
}
