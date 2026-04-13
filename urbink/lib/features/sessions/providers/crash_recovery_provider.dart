import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urbink/features/sessions/providers/session_db_provider.dart';
import 'package:urbink/features/sessions/services/crash_recovery_service.dart';

final crashRecoveryServiceProvider = Provider<CrashRecoveryService>((ref) {
  final cache = ref.watch(sessionLocalCacheProvider);
  return CrashRecoveryService(cache);
});
