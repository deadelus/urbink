import 'package:flutter_test/flutter_test.dart';
import 'package:urbink/core/firebase/startup_auth.dart';

void main() {
  group('ensureAnonymousAuth', () {
    test('appelle signInAnonymously quand non connecté', () async {
      int callCount = 0;
      await ensureAnonymousAuth(
        isSignedIn: () => false,
        signInAnonymously: () async => callCount++,
      );
      expect(callCount, equals(1));
    });

    test('ne rappelle pas signInAnonymously si déjà connecté', () async {
      int callCount = 0;
      await ensureAnonymousAuth(
        isSignedIn: () => true,
        signInAnonymously: () async => callCount++,
      );
      expect(callCount, equals(0));
    });

    test('restaure silencieusement — UID iOS Keychain inchangé', () async {
      final calls = <String>[];
      await ensureAnonymousAuth(
        isSignedIn: () => true,
        signInAnonymously: () async => calls.add('signIn'),
      );
      expect(calls, isEmpty);
    });
  });
}
