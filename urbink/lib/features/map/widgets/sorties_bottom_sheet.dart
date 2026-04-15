import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:urbink/core/router/app_router.dart';
import 'package:urbink/features/sessions/providers/gps_tracking_provider.dart';
import 'package:urbink/features/sessions/session_state_provider.dart';
import 'package:urbink/shared/constants/colors.dart';
import 'package:urbink/shared/constants/spacing.dart';

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

  @override
  ConsumerState<SortiesBottomSheet> createState() => _SortiesBottomSheetState();
}

enum _SheetView { selectMode, itinerairesList }

class _SortiesBottomSheetState extends ConsumerState<SortiesBottomSheet> {
  final DraggableScrollableController _controller =
      DraggableScrollableController();
  _SheetView _view = _SheetView.selectMode;

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
      await _showGpsDeniedDialog(context);
      return;
    }
    final granted = await gpsService.requestPermission();
    if (!context.mounted) return;
    if (!granted) {
      await _showGpsDeniedDialog(context);
      return;
    }
    ref.read(sessionStateProvider.notifier).state = SessionState.active;
  }

  static Future<void> _showGpsDeniedDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('GPS requis'),
        content: const Text(
          'Le GPS est requis pour colorier tes rues.\n'
          'Active-le dans les Réglages pour continuer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              openAppSettings();
            },
            child: const Text('Ouvrir les réglages'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sessionState = ref.watch(sessionStateProvider);
    final isSessionActive = sessionState != SessionState.idle;

    ref.listen<SessionState>(sessionStateProvider, (prev, next) {
      if (next != SessionState.idle && _controller.isAttached) {
        final screenH = MediaQuery.of(context).size.height;
        _controller.animateTo(
          (72 / screenH).clamp(0.0, 1.0),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
        if (mounted) setState(() => _view = _SheetView.selectMode);
      }
    });

    return LayoutBuilder(
      builder: (context, constraints) {
        final parentH = constraints.maxHeight;
        final minSize = (72 / parentH).clamp(0.0, 1.0);
        final peekSize = (260 / parentH).clamp(minSize, 0.64);
        const maxSize = 0.65;

        return IgnorePointer(
          ignoring: isSessionActive,
          child: DraggableScrollableSheet(
            controller: _controller,
            initialChildSize: minSize,
            minChildSize: minSize,
            maxChildSize: maxSize,
            snap: true,
            snapSizes: [peekSize],
            builder: (ctx, scrollController) {
              return _SheetContainer(
                scrollController: scrollController,
                view: _view,
                isSessionActive: isSessionActive,
                onSelectItineraire: () =>
                    setState(() => _view = _SheetView.itinerairesList),
                onBack: () => setState(() => _view = _SheetView.selectMode),
                onStart: () => _startSession(context),
                onCreateItineraire: () =>
                    context.push(AppRoutes.createItineraire),
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

class _SheetContainer extends StatelessWidget {
  const _SheetContainer({
    required this.scrollController,
    required this.view,
    required this.isSessionActive,
    required this.onSelectItineraire,
    required this.onBack,
    required this.onStart,
    required this.onCreateItineraire,
  });

  final ScrollController scrollController;
  final _SheetView view;
  final bool isSessionActive;
  final VoidCallback onSelectItineraire;
  final VoidCallback onBack;
  final VoidCallback onStart;
  final VoidCallback onCreateItineraire;

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: isSessionActive
          ? const _CollapsedLockedContent()
          : AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (child, animation) {
                final offsetAnim = Tween<Offset>(
                  begin: const Offset(1, 0),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeOut),
                );
                return SlideTransition(position: offsetAnim, child: child);
              },
              child: view == _SheetView.selectMode
                  ? _SelectModeContent(
                      key: const ValueKey('selectMode'),
                      scrollController: scrollController,
                      onSelectItineraire: onSelectItineraire,
                      onStart: onStart,
                    )
                  : _ItinerairesListContent(
                      key: const ValueKey('itinerairesList'),
                      scrollController: scrollController,
                      onBack: onBack,
                      onCreateItineraire: onCreateItineraire,
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
    super.key,
    required this.scrollController,
    required this.onSelectItineraire,
    required this.onStart,
  });

  final ScrollController scrollController;
  final VoidCallback onSelectItineraire;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: scrollController,
      padding: EdgeInsets.zero,
      children: [
        const SizedBox(height: UrbinkSpacing.sm),
        const _DragHandle(),
        const SizedBox(height: UrbinkSpacing.sm),
        // Hint visible quand collapsed
        const Padding(
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
                  onTap: null, // déjà sélectionné
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
    super.key,
    required this.scrollController,
    required this.onBack,
    required this.onCreateItineraire,
  });

  final ScrollController scrollController;
  final VoidCallback onBack;
  final VoidCallback onCreateItineraire;

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: scrollController,
      padding: EdgeInsets.zero,
      children: [
        const SizedBox(height: UrbinkSpacing.sm),
        const _DragHandle(),
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
              const Text(
                '🗺️',
                style: TextStyle(fontSize: 40),
              ),
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
        borderRadius: BorderRadius.all(Radius.circular(UrbinkSpacing.radiusChip)),
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
// Drag handle
// ---------------------------------------------------------------------------

class _DragHandle extends StatelessWidget {
  const _DragHandle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 36,
        height: 4,
        decoration: BoxDecoration(
          color: UrbinkColors.sheetDragPill,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}
