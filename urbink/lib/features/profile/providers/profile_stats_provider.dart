import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urbink/features/sessions/providers/session_lifecycle_provider.dart';

/// Nombre total de sorties de l'utilisateur (Firestore count aggregate).
final profileSessionsCountProvider = FutureProvider.autoDispose<int>((ref) async {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) return 0;
  final agg = await FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('sessions')
      .count()
      .get();
  return agg.count ?? 0;
});
