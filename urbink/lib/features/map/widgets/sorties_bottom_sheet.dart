import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:urbink/core/router/app_router.dart';
import 'package:urbink/features/sessions/providers/gps_tracking_provider.dart';
import 'package:urbink/features/sessions/session_state_provider.dart';
import 'package:urbink/shared/constants/colors.dart';
import 'package:urbink/shared/constants/spacing.dart';
import 'package:urbink/shared/widgets/gps_required_dialog.dart';

/// Bottom sheet "Carte & Sorties" — Story 2.9
///
/// DraggableScrollableSheet avec 3 snap points :
/// - 72px  (collapsed — handle + hint)
/// - ~260px (peek — section Démarrer une sortie)
/// - 65%   (expanded — contenu complet)
///
/// Quand une session est active, le sheet est collapsed et non déroulable.
class SortiesBottomSheet extends ConsumerStatefulWidget {
  const SortiesBottomSheet({super.key});

  /// Hauteur collapsed du sheet (72px). Utilisé par les parents pour
  /// repositionner les widgets au-dessus (ex. ZonesTogglePill bottom offset).
  static const double collapsedHeight = 72;

  @override
  ConsumerState<SortiesBottomSheet> createState() => _SortiesBottomSheetState();
}

enum _SheetView { selectMode, itinerairesList }

class _SortiesBottomSheetState extends ConsumerState<SortiesBottomSheet> {
  final DraggableScrollableController _controller =
      DraggableScrollableController();
  _SheetView _view = _SheetView.selectMode;
  bool _goingForward = true;
  // Dernière valeur calculée par LayoutBuilder — lue par ref.listen sans rebuild.
  double _minSize = 0.0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _startSession(BuildContext context) async {
    final gpsService = ref.read(gpsTrackingServiceProvider);
    final serviceEnabled = await gpsService.isServiceEnabled();
    if (!context.mounted) return;
    if (!serviceEnabled) {
      await showGpsRequiredDialog(context);
      return;
    }
    final granted = await gpsService.requestPermission();
    if (!context.mounted) return;
    if (!granted) {
      await showGpsRequiredDialog(context);
      return;
    }
    ref.read(sessionStateProvider.notifier).state = SessionState.active;
  }

  @override
  Widget build(BuildContext context) {
    final sessionState = ref.watch(sessionStateProvider);
    final isSessionActive = sessionState == SessionState.active;

    ref.listen<SessionState>(sessionStateProvider, (prev, next) {
      if (next == SessionState.active && _controller.isAttached) {
        _controller.animateTo(
          _minSize,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
        if (mounted) setState(() => _view = _SheetView.selectMode);
      }
    });

    return LayoutBuilder(
      builder: (context, constraints) {
        final parentH = constraints.maxHeight;
        final minSize = (SortiesBottomSheet.collapsedHeight / parentH).clamp(0.0, 1.0);
        final peekSize = (260 / parentH).clamp(minSize, 0.64);
        const maxSize = 0.65;
        _minSize = minSize; // mis à jour à chaque rebuild — lu par ref.listen

        // Callbacks velocity-based pour snap au flick
        void snapUp() => _controller.animateTo(
              peekSize,
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOut,
            );
        void snapDown() => _controller.animateTo(
              minSize,
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOut,
            );
        void snapToggle() {
          if (!_controller.isAttached) return;
          final current = _controller.size;
          if (current > minSize + 0.02) {
            _controller.animateTo(minSize,
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOut);
          } else {
            _controller.animateTo(peekSize,
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOut);
          }
        }

        return IgnorePointer(
          ignoring: isSessionActive,
          child: DraggableScrollableSheet(
            controller: _controller,
            initialChildSize: minSize,
            minChildSize: minSize,
            maxChildSize: maxSize,
            snap: true,
            snapSizes: [peekSize, maxSize],
            builder: (ctx, scrollController) {
              return _SheetContainer(
                scrollController: scrollController,
                view: _view,
                isSessionActive: isSessionActive,
                onSelectItineraire: () => setState(() {
                  _goingForward = true;
                  _view = _SheetView.itinerairesList;
                }),
                onBack: () => setState(() {
                  _goingForward = false;
                  _view = _SheetView.selectMode;
                }),
                onStart: () => _startSession(context),
                onCreateItineraire: () =>
                    context.push(AppRoutes.createItineraire),
                goingForward: _goingForward,
                onSnapUp: snapUp,
                onSnapDown: snapDown,
                onSnapToggle: snapToggle,
              );
            },
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Conteneur principal du sheet
// ---------------------------------------------------------------------------

class _SheetContainer extends StatefulWidget {
  const _SheetContainer({
    required this.scrollController,
    required this.view,
    required this.isSessionActive,
    required this.goingForward,
    required this.onSelectItineraire,
    required this.onBack,
    required this.onStart,
    required this.onCreateItineraire,
    required this.onSnapUp,
    required this.onSnapDown,
    required this.onSnapToggle,
  });

  final ScrollController scrollController;
  final _SheetView view;
  final bool isSessionActive;
  final bool goingForward;
  final VoidCallback onSelectItineraire;
  final VoidCallback onBack;
  final VoidCallback onStart;
  final VoidCallback onCreateItineraire;
  final VoidCallback onSnapUp;
  final VoidCallback onSnapDown;
  final VoidCallback onSnapToggle;

  @override
  State<_SheetContainer> createState() => _SheetContainerState();
}

class _SheetContainerState extends State<_SheetContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _pushController;
  late Animation<double> _pushAnim;
  late _SheetView _prevView;
  // Dummy controller for the exiting view — avoids double-attach error.
  final ScrollController _exitScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _prevView = widget.view;
    _pushController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
      value: 1.0, // Déjà complet au premier rendu
    );
    _pushAnim =
        CurvedAnimation(parent: _pushController, curve: Curves.easeOut);
  }

  @override
  void didUpdateWidget(_SheetContainer old) {
    super.didUpdateWidget(old);
    if (widget.view != old.view) {
      _prevView = old.view;
      _pushController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _pushController.dispose();
    _exitScrollController.dispose();
    super.dispose();
  }

  Widget _buildView(_SheetView v, ScrollController sc) => switch (v) {
        _SheetView.selectMode => _SelectModeContent(
            scrollController: sc,
            onSelectItineraire: widget.onSelectItineraire,
            onStart: widget.onStart,
            onSnapUp: widget.onSnapUp,
            onSnapDown: widget.onSnapDown,
            onSnapToggle: widget.onSnapToggle,
          ),
        _SheetView.itinerairesList => _ItinerairesListContent(
            scrollController: sc,
            onBack: widget.onBack,
            onCreateItineraire: widget.onCreateItineraire,
            onSnapUp: widget.onSnapUp,
            onSnapDown: widget.onSnapDown,
            onSnapToggle: widget.onSnapToggle,
          ),
      };

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: Container(
        decoration: const BoxDecoration(
          color: UrbinkColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          boxShadow: [
            BoxShadow(
              color: Color(0x18000000),
              blurRadius: 16,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: widget.isSessionActive
            ? const _CollapsedLockedContent()
            : AnimatedBuilder(
                animation: _pushAnim,
                builder: (context, _) {
                  final t = _pushAnim.value; // 0 → 1
                  final dir = widget.goingForward ? 1.0 : -1.0;
                  return Stack(
                    children: [
                      // Vue sortante : glisse vers dir négatif
                      if (t < 1.0)
                        Transform.translate(
                          offset: Offset(-dir * t * w, 0),
                          child: _buildView(
                              _prevView, _exitScrollController),
                        ),
                      // Vue entrante : glisse depuis dir positif → 0
                      Transform.translate(
                        offset: Offset(dir * (1.0 - t) * w, 0),
                        child: _buildView(
                            widget.view, widget.scrollController),
                      ),
                    ],
                  );
                },
              ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Vue collapsed quand session active (non déroulable)
// ---------------------------------------------------------------------------

class _CollapsedLockedContent extends StatelessWidget {
  const _CollapsedLockedContent();

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: UrbinkSpacing.sm),
        _DragHandle(),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Vue sélection du mode (Circuit libre / Itinéraire)
// ---------------------------------------------------------------------------

class _SelectModeContent extends StatelessWidget {
  const _SelectModeContent({
    required this.scrollController,
    required this.onSelectItineraire,
    required this.onStart,
    required this.onSnapUp,
    required this.onSnapDown,
    required this.onSnapToggle,
  });

  final ScrollController scrollController;
  final VoidCallback onSelectItineraire;
  final VoidCallback onStart;
  final VoidCallback onSnapUp;
  final VoidCallback onSnapDown;
  final VoidCallback onSnapToggle;

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: scrollController,
      padding: EdgeInsets.zero,
      children: [
        const SizedBox(height: UrbinkSpacing.sm),
        _DragHandle(onSwipeUp: onSnapUp, onSwipeDown: onSnapDown, onToggle: onSnapToggle),
        const SizedBox(height: UrbinkSpacing.sm),
        // Hint visible quand collapsed — toute la zone répond au swipe
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onSnapToggle,
          onVerticalDragEnd: (details) {
            final v = details.primaryVelocity ?? 0;
            if (v < -50) onSnapUp();
            if (v > 50) onSnapDown();
          },
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: UrbinkSpacing.md),
            child: Text(
              '↑ Dérouler pour démarrer une sortie',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: UrbinkColors.navInactive,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        const SizedBox(height: UrbinkSpacing.lg),
        // Section header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: UrbinkSpacing.md),
          child: Text(
            'Démarrer une sortie',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: UrbinkColors.onSurface,
                ),
          ),
        ),
        const SizedBox(height: UrbinkSpacing.sm),
        // Cards côte à côte
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: UrbinkSpacing.md),
          child: Row(
            children: [
              const Expanded(
                child: _ModeCard(
                  emoji: '🚶',
                  title: 'Circuit libre',
                  subtitle: '✓ Par défaut',
                  isSelected: true,
                  onTap: null,
                ),
              ),
              const SizedBox(width: UrbinkSpacing.sm),
              Expanded(
                child: _ModeCard(
                  emoji: '🗺️',
                  title: 'Itinéraire',
                  subtitle: 'Mode GPS →',
                  isSelected: false,
                  onTap: onSelectItineraire,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: UrbinkSpacing.sm),
        // Info chip GPS
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: UrbinkSpacing.md),
          child: _GpsInfoChip(),
        ),
        const SizedBox(height: UrbinkSpacing.md),
        // Bouton Démarrer
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: UrbinkSpacing.md),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onStart,
              style: ElevatedButton.styleFrom(
                backgroundColor: UrbinkColors.secondary,
                foregroundColor: Colors.white,
                minimumSize: const Size(
                  double.infinity,
                  UrbinkSpacing.minTapTarget,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(UrbinkSpacing.radiusButton),
                ),
              ),
              child: const Text(
                '▶ Démarrer la sortie',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
        const SizedBox(height: UrbinkSpacing.lg),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Vue liste des itinéraires (sub-slide via AnimatedSwitcher)
// ---------------------------------------------------------------------------

class _ItinerairesListContent extends StatelessWidget {
  const _ItinerairesListContent({
    required this.scrollController,
    required this.onBack,
    required this.onCreateItineraire,
    required this.onSnapUp,
    required this.onSnapDown,
    required this.onSnapToggle,
  });

  final ScrollController scrollController;
  final VoidCallback onBack;
  final VoidCallback onCreateItineraire;
  final VoidCallback onSnapUp;
  final VoidCallback onSnapDown;
  final VoidCallback onSnapToggle;

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: scrollController,
      padding: EdgeInsets.zero,
      children: [
        const SizedBox(height: UrbinkSpacing.sm),
        _DragHandle(onSwipeUp: onSnapUp, onSwipeDown: onSnapDown, onToggle: onSnapToggle),
        const SizedBox(height: UrbinkSpacing.xs),
        // Header : ← Retour | + Créer
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: UrbinkSpacing.sm),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
                label: const Text('Retour'),
                style: TextButton.styleFrom(
                  foregroundColor: UrbinkColors.onSurface,
                ),
              ),
              TextButton.icon(
                onPressed: onCreateItineraire,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Créer'),
                style: TextButton.styleFrom(
                  foregroundColor: UrbinkColors.secondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: UrbinkSpacing.sm),
        // Titre
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: UrbinkSpacing.md),
          child: Text(
            'Mes itinéraires',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: UrbinkColors.onSurface,
                ),
          ),
        ),
        const SizedBox(height: UrbinkSpacing.md),
        // État vide
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: UrbinkSpacing.md,
            vertical: UrbinkSpacing.lg,
          ),
          child: Column(
            children: [
              const Text('🗺️', style: TextStyle(fontSize: 40)),
              const SizedBox(height: UrbinkSpacing.sm),
              Text(
                'Aucun itinéraire',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: UrbinkColors.navInactive,
                    ),
              ),
              const SizedBox(height: UrbinkSpacing.xs),
              Text(
                'Crée ton premier itinéraire GPS.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: UrbinkColors.navInactive,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Card mode de sortie
// ---------------------------------------------------------------------------

class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  final String emoji;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bgColor = isSelected
        ? UrbinkColors.secondary.withValues(alpha: 0.08)
        : UrbinkColors.surfaceVariant;
    final borderColor =
        isSelected ? UrbinkColors.secondary : Colors.transparent;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: UrbinkSpacing.sm,
          vertical: UrbinkSpacing.sm + 2,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(UrbinkSpacing.radiusCard),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: UrbinkSpacing.xs),
            Text(
              title,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: UrbinkColors.onSurface,
                  ),
            ),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: isSelected
                        ? UrbinkColors.secondary
                        : UrbinkColors.navInactive,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Chip info GPS
// ---------------------------------------------------------------------------

class _GpsInfoChip extends StatelessWidget {
  const _GpsInfoChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: UrbinkSpacing.sm,
        vertical: UrbinkSpacing.xs + 2,
      ),
      decoration: const BoxDecoration(
        color: UrbinkColors.ghost,
        borderRadius:
            BorderRadius.all(Radius.circular(UrbinkSpacing.radiusChip)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🤖', style: TextStyle(fontSize: 13)),
          const SizedBox(width: UrbinkSpacing.xs),
          Text(
            'Mode auto-détecté · GPS prêt',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: UrbinkColors.onSurface,
                ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Drag handle — zone de swipe velocity-based
// ---------------------------------------------------------------------------

class _DragHandle extends StatelessWidget {
  const _DragHandle({this.onSwipeUp, this.onSwipeDown, this.onToggle});

  final VoidCallback? onSwipeUp;
  final VoidCallback? onSwipeDown;
  final VoidCallback? onToggle;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onToggle,
      onVerticalDragEnd: (details) {
        final v = details.primaryVelocity ?? 0;
        if (v < -50) onSwipeUp?.call();
        if (v > 50) onSwipeDown?.call();
      },
      child: SizedBox(
        width: double.infinity,
        height: 24,
        child: Center(
          child: Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: UrbinkColors.sheetDragPill,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
    );
  }
}
