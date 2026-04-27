import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:urbink/features/gamification/models/celebration_event.dart';
import 'package:urbink/features/gamification/providers/celebration_queue_provider.dart';

CelebrationEvent _event(String id) => CelebrationEvent(
      id: id,
      mode: CelebrationMode.badge,
      title: 'Test $id',
    );

ProviderContainer _container() => ProviderContainer();

void main() {
  group('CelebrationQueueNotifier', () {
    test('état initial vide', () {
      final c = _container();
      addTearDown(c.dispose);
      expect(c.read(celebrationQueueProvider), isEmpty);
    });

    test('push ajoute un événement', () {
      final c = _container();
      addTearDown(c.dispose);
      c.read(celebrationQueueProvider.notifier).push(_event('a'));
      expect(c.read(celebrationQueueProvider).length, 1);
      expect(c.read(celebrationQueueProvider).first.id, 'a');
    });

    test('push déduplique par id', () {
      final c = _container();
      addTearDown(c.dispose);
      c.read(celebrationQueueProvider.notifier).push(_event('a'));
      c.read(celebrationQueueProvider.notifier).push(_event('a'));
      expect(c.read(celebrationQueueProvider).length, 1);
    });

    test('push plusieurs ids distincts', () {
      final c = _container();
      addTearDown(c.dispose);
      c.read(celebrationQueueProvider.notifier).push(_event('a'));
      c.read(celebrationQueueProvider.notifier).push(_event('b'));
      expect(c.read(celebrationQueueProvider).length, 2);
      expect(c.read(celebrationQueueProvider)[0].id, 'a');
      expect(c.read(celebrationQueueProvider)[1].id, 'b');
    });

    test('pop retire le premier élément', () {
      final c = _container();
      addTearDown(c.dispose);
      c.read(celebrationQueueProvider.notifier).push(_event('a'));
      c.read(celebrationQueueProvider.notifier).push(_event('b'));
      c.read(celebrationQueueProvider.notifier).pop();
      final q = c.read(celebrationQueueProvider);
      expect(q.length, 1);
      expect(q.first.id, 'b');
    });

    test('pop sur queue vide est silencieux', () {
      final c = _container();
      addTearDown(c.dispose);
      expect(
        () => c.read(celebrationQueueProvider.notifier).pop(),
        returnsNormally,
      );
    });
  });
}
