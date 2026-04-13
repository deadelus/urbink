import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urbink/features/sessions/services/session_local_cache.dart';

/// Provider singleton pour le cache local sqflite.
final sessionLocalCacheProvider = Provider<SessionLocalCache>((ref) {
  final cache = SessionLocalCache();
  ref.onDispose(cache.close);
  return cache;
});
