import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urbink/features/gamification/models/celebration_event.dart';
import 'package:urbink/features/gamification/providers/celebration_queue_provider.dart';
import 'package:urbink/features/gamification/widgets/celebration_overlay.dart';

/// Écoute la [celebrationQueueProvider] et affiche les overlays séquentiellement.
///
/// À placer une seule fois au niveau du shell (au-dessus de la bottom nav).
/// Chaque overlay est affiché via [showCelebrationOverlay] ; une fois dismissé,
/// l'événement est retiré de la queue et le suivant s'affiche.
class CelebrationQueueListener extends ConsumerStatefulWidget {
  const CelebrationQueueListener({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<CelebrationQueueListener> createState() =>
      _CelebrationQueueListenerState();
}

class _CelebrationQueueListenerState
    extends ConsumerState<CelebrationQueueListener> {
  bool _isShowing = false;

  @override
  Widget build(BuildContext context) {
    ref.listen<List<CelebrationEvent>>(celebrationQueueProvider, (_, queue) {
      if (!_isShowing && queue.isNotEmpty) {
        // Defer hors du build/notification pour éviter de pousser une route
        // pendant que le widget tree est encore en train d'être construit.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && !_isShowing) {
            final current = ref.read(celebrationQueueProvider);
            if (current.isNotEmpty) _showNext(current.first);
          }
        });
      }
    });
    return widget.child;
  }

  Future<void> _showNext(CelebrationEvent event) async {
    _isShowing = true;
    try {
      await showCelebrationOverlay(
        context: context,
        event: event,
        onDone: () {
          if (mounted) ref.read(celebrationQueueProvider.notifier).pop();
        },
      );
    } finally {
      _isShowing = false;
      if (mounted) {
        // Vérifie si d'autres events sont en attente, que l'overlay ait été
        // dismissé normalement (onDone) ou via un pop externe (navigation, etc.).
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && !_isShowing) {
            final remaining = ref.read(celebrationQueueProvider);
            if (remaining.isNotEmpty) _showNext(remaining.first);
          }
        });
      }
    }
  }
}
