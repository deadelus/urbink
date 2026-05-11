import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urbink/features/gamification/providers/quartier_badges_provider.dart';
import 'package:urbink/features/parcours/data/parcours_model.dart';
import 'package:urbink/features/parcours/data/parcours_repository.dart';
import 'package:urbink/features/sessions/providers/session_lifecycle_provider.dart';

final parcoursRepositoryProvider = Provider<ParcoursRepository>((ref) {
  return ParcoursRepository(ref.watch(firestoreProvider));
});

final parcoursListProvider = StreamProvider<List<Parcours>>((ref) {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) return Stream.value(const []);
  return ref.watch(parcoursRepositoryProvider).streamByUser(uid);
});
