import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urbink/features/gamification/models/celebration_event.dart';

class CelebrationQueueNotifier extends Notifier<List<CelebrationEvent>> {
  @override
  List<CelebrationEvent> build() => const [];

  /// Ajoute un événement en queue. Déduplique par [CelebrationEvent.id].
  void push(CelebrationEvent event) {
    if (state.any((e) => e.id == event.id)) return;
    state = [...state, event];
  }

  /// Retire le premier élément de la queue.
  void pop() {
    if (state.isEmpty) return;
    state = state.sublist(1);
  }
}

final celebrationQueueProvider =
    NotifierProvider<CelebrationQueueNotifier, List<CelebrationEvent>>(
  CelebrationQueueNotifier.new,
);
