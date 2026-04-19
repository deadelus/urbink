import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:urbink/core/router/app_router.dart';
import 'package:urbink/features/map/providers/bottom_sheet_state_provider.dart';
import 'package:urbink/features/sessions/providers/gps_tracking_provider.dart';
import 'package:urbink/features/sessions/session_state_provider.dart';
import 'package:urbink/shared/constants/colors.dart';
import 'package:urbink/shared/constants/spacing.dart';
import 'package:urbink/shared/widgets/gps_required_dialog.dart';

/// Bottom sheet "Carte & Sorties"
///
/// Implémentation manuelle (GestureDetector + AnimationController) :
/// - PARTIAL (72px  — handle + hint visible, default resting state)
/// - OPEN    (65%   — contenu complet, CTA visible)
///
/// Swipe up → OPEN, swipe down → PARTIAL.
/// Quand une session est active, le sheet est masqué via Offstage.
class SortiesBottomSheet extends ConsumerStatefulWidget {
  const SortiesBottomSheet({super.key});

  static const double collapsedHeight = 72;
  static const double peekHeight = 320;
  static const double maxFraction = 0.65;

  @override
  ConsumerState<SortiesBottomSheet> createState() => _SortiesBottomSheetState();
}

enum _SheetView { selectMode, parcoursList, itinerairesList }

// ---------------------------------------------------------------------------
// Modèle parcours (données mockées)
// ---------------------------------------------------------------------------

class _Parcours {
  const _Parcours({
    required this.id,
    required this.name,
    required this.distance,
    required this.duration,
    required this.stepsCount,
    required this.emoji,
  });

  final String id;
  final String name;
  final String distance;
  final String duration;
  final int stepsCount;
  final String emoji;
}

const _sampleParcours = <_Parcours>[
  _Parcours(id: '1', name: 'Tour de Montmartre',  distance: '4,2 km', duration: '55 min', stepsCount: 5, emoji: '🗺️'),
  _Parcours(id: '2', name: 'Quartier Latin',       distance: '3,1 km', duration: '40 min', stepsCount: 4, emoji: '📚'),
  _Parcours(id: '3', name: 'Berges de la Seine',   distance: '6,8 km', duration: '1h20',   stepsCount: 6, emoji: '🌊'),
  _Parcours(id: '4', name: 'Marais & Archives',    distance: '2,8 km', duration: '35 min', stepsCount: 3, emoji: '🏛️'),
];

class _SortiesBottomSheetState extends ConsumerState<SortiesBottomSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _anim;
  _SheetView _view = _SheetView.selectMode;
  _Parcours? _selectedParcours;
  bool _goingForward = true;
  bool _isExpanded = false;

  // 0.0 = PARTIAL, 1.0 = OPEN
  double _dragFraction = 0.0;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
      value: 0.0, // start PARTIAL
    )..addListener(_onAnimUpdate);
  }

  void _onAnimUpdate() {
    final expanded = _anim.value > 0.4;
    if (expanded != _isExpanded) setState(() => _isExpanded = expanded);
  }

  double _sheetHeight(double parentH) {
    const partial = SortiesBottomSheet.collapsedHeight;
    final max = parentH * SortiesBottomSheet.maxFraction;
    return partial + (max - partial) * _anim.value;
  }

  void _reportSize(double parentH) {
    final h = _sheetHeight(parentH);
    ref.read(bottomSheetSizeProvider.notifier).state = h / parentH;
  }

  void _onDragUpdate(DragUpdateDetails details, double parentH) {
    const partial = SortiesBottomSheet.collapsedHeight;
    final max = parentH * SortiesBottomSheet.maxFraction;
    final range = max - partial;
    // Negative delta = drag up = open
    final delta = -details.primaryDelta! / range;
    _dragFraction = (_anim.value + delta).clamp(0.0, 1.0);
    _anim.value = _dragFraction;
    _reportSize(parentH);
  }

  void _onDragEnd(DragEndDetails details, double parentH) {
    final velocity = details.primaryVelocity ?? 0;
    // Fast fling: velocity > 300 px/s
    if (velocity < -300) {
      _snapTo(1.0, parentH);
      return;
    }
    if (velocity > 300) {
      _snapTo(0.0, parentH);
      return;
    }
    // Slow drag: threshold at 35%
    _snapTo(_anim.value > 0.35 ? 1.0 : 0.0, parentH);
  }

  void _snapTo(double target, double parentH) {
    _anim.animateTo(target,
        duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
    // Report final size after animation
    const partial = SortiesBottomSheet.collapsedHeight;
    final max = parentH * SortiesBottomSheet.maxFraction;
    final h = partial + (max - partial) * target;
    // Use post-frame to avoid updating during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(bottomSheetSizeProvider.notifier).state = h / parentH;
    });
  }

  @override
  void dispose() {
    _anim.dispose();
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

    // When hidden, report size 0 for floating button positioning.
    if (isSessionActive) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) ref.read(bottomSheetSizeProvider.notifier).state = 0;
      });
    }

    // Reset view when session ends
    ref.listen<SessionState>(sessionStateProvider, (prev, next) {
      if (next == SessionState.idle && mounted) {
        setState(() {
          _view = _SheetView.selectMode;
          _selectedParcours = null;
        });
        _anim.value = 0.0;
      }
    });

    return Offstage(
      offstage: isSessionActive,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final parentH = constraints.maxHeight;

          return AnimatedBuilder(
            animation: _anim,
            builder: (context, child) {
              final height = _sheetHeight(parentH);
              return Align(
                alignment: Alignment.bottomCenter,
                child: GestureDetector(
                  onVerticalDragUpdate: (d) => _onDragUpdate(d, parentH),
                  onVerticalDragEnd: (d) => _onDragEnd(d, parentH),
                  child: SizedBox(
                    width: double.infinity,
                    height: height,
                    child: child,
                  ),
                ),
              );
            },
            child: _SheetContainer(
              view: _view,
              isSessionActive: isSessionActive,
              selectedParcours: _selectedParcours,
              onSelectItineraire: () => setState(() {
                _goingForward = true;
                _view = _SheetView.parcoursList;
              }),
              onSelectParcours: (p) => setState(() {
                _goingForward = true;
                _selectedParcours = p;
                _view = _SheetView.itinerairesList;
              }),
              onBack: () => setState(() {
                _goingForward = false;
                _view = _view == _SheetView.itinerairesList
                    ? _SheetView.parcoursList
                    : _SheetView.selectMode;
              }),
              onStart: () => _startSession(context),
              onCreateItineraire: () {
                if (context.mounted) context.push(AppRoutes.createItineraire);
              },
              goingForward: _goingForward,
              isExpanded: _isExpanded,
            ),
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Conteneur principal du sheet
// ---------------------------------------------------------------------------

class _SheetContainer extends StatefulWidget {
  const _SheetContainer({
    required this.view,
    required this.isSessionActive,
    required this.isExpanded,
    required this.goingForward,
    required this.onSelectItineraire,
    required this.onSelectParcours,
    required this.onBack,
    required this.onStart,
    required this.onCreateItineraire,
    this.selectedParcours,
  });

  final _SheetView view;
  final bool isSessionActive;
  final bool isExpanded;
  final bool goingForward;
  final VoidCallback onSelectItineraire;
  final ValueChanged<_Parcours> onSelectParcours;
  final VoidCallback onBack;
  final VoidCallback onStart;
  final VoidCallback onCreateItineraire;
  final _Parcours? selectedParcours;

  @override
  State<_SheetContainer> createState() => _SheetContainerState();
}

class _SheetContainerState extends State<_SheetContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _pushController;
  late Animation<double> _pushAnim;
  late _SheetView _prevView;
  // Dummy controller for the exiting view — avoids double-attach error.

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
    super.dispose();
  }

  Widget _buildBody(_SheetView v) => switch (v) {
        _SheetView.selectMode => _SelectModeBody(
            onSelectItineraire: widget.onSelectItineraire,
            onStart: widget.onStart,
          ),
        _SheetView.parcoursList => _ParcourListBody(
            onBack: widget.onBack,
            onSelectParcours: widget.onSelectParcours,
            onCreateItineraire: widget.onCreateItineraire,
          ),
        _SheetView.itinerairesList => _ItinerairesListBody(
            onBack: widget.onBack,
            onCreateItineraire: widget.onCreateItineraire,
            selectedParcours: widget.selectedParcours,
          ),
      };

  String get _collapsedLabel => switch (widget.view) {
        _SheetView.selectMode     => 'Démarrer une sortie',
        _SheetView.parcoursList   => 'Mes itinéraires',
        _SheetView.itinerairesList => 'Créer un itinéraire',
      };

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;

    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(UrbinkSpacing.radiusSheet)),
        boxShadow: [
          BoxShadow(color: Color(0x14000000), blurRadius: 24, offset: Offset(0, -6)),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(UrbinkSpacing.radiusSheet)),
        child: Stack(
          fit: StackFit.expand,
          clipBehavior: Clip.hardEdge,
          children: [
            // Background: opaque when closed, glass when open
            if (widget.isExpanded)
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.0, 0.30, 1.0],
                      colors: [
                        UrbinkColors.surface,
                        UrbinkColors.surface.withValues(alpha: 0.90),
                        UrbinkColors.surface.withValues(alpha: 0.72),
                      ],
                    ),
                  ),
                ),
              )
            else
              Container(color: UrbinkColors.surface),

            // Content — handle + hint toujours visibles, body uniquement si expanded
            if (widget.isSessionActive)
              const _CollapsedLockedContent()
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: UrbinkSpacing.sm),
                  const _DragHandle(),
                  const SizedBox(height: UrbinkSpacing.xs),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: UrbinkSpacing.md),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          widget.isExpanded
                              ? Icons.keyboard_arrow_down_rounded
                              : Icons.keyboard_arrow_up_rounded,
                          size: 16,
                          color: UrbinkColors.navInactive,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.isExpanded ? 'Fermer' : _collapsedLabel,
                          style: const TextStyle(
                            color: UrbinkColors.navInactive,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (widget.isExpanded)
                    Expanded(
                      child: AnimatedBuilder(
                        animation: _pushAnim,
                        builder: (context, _) {
                          final t = _pushAnim.value;
                          final dir = widget.goingForward ? 1.0 : -1.0;
                          return Stack(
                            fit: StackFit.expand,
                            children: [
                              if (t < 1.0)
                                Transform.translate(
                                  offset: Offset(-dir * t * w, 0),
                                  child: _buildBody(_prevView),
                                ),
                              Transform.translate(
                                offset: Offset(dir * (1.0 - t) * w, 0),
                                child: _buildBody(widget.view),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                ],
              ),
          ],
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

class _SelectModeBody extends StatelessWidget {
  const _SelectModeBody({
    required this.onSelectItineraire,
    required this.onStart,
  });

  final VoidCallback onSelectItineraire;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(
          top: UrbinkSpacing.lg, bottom: UrbinkSpacing.lg),
      children: [
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
        const SizedBox(height: UrbinkSpacing.sm + 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: UrbinkSpacing.md),
          child: Row(
            children: [
              const Expanded(
                child: _ModeCard(
                  icon: Icons.directions_walk_rounded,
                  title: 'Circuit libre',
                  subtitle: 'Par défaut',
                  isSelected: true,
                  onTap: null,
                ),
              ),
              const SizedBox(width: UrbinkSpacing.sm),
              Expanded(
                child: _ModeCard(
                  icon: Icons.map_outlined,
                  title: 'Itinéraire',
                  subtitle: 'Choisir →',
                  isSelected: false,
                  onTap: onSelectItineraire,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: UrbinkSpacing.sm),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: UrbinkSpacing.md),
          child: _GpsInfoChip(),
        ),
        const SizedBox(height: UrbinkSpacing.md),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: UrbinkSpacing.md),
          child: _PrimaryCTA(
            label: 'Démarrer la sortie',
            icon: Icons.play_arrow_rounded,
            color: UrbinkColors.primary,
            onTap: onStart,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Vue "Naviguer avec…" (itinéraires)
// ---------------------------------------------------------------------------

class _ItinerairesListBody extends StatefulWidget {
  const _ItinerairesListBody({
    required this.onBack,
    required this.onCreateItineraire,
    this.selectedParcours,
  });

  final VoidCallback onBack;
  final VoidCallback onCreateItineraire;
  final _Parcours? selectedParcours;

  @override
  State<_ItinerairesListBody> createState() => _ItinerairesListBodyState();
}

class _ItinerairesListBodyState extends State<_ItinerairesListBody> {
  int _selectedNav = 0;

  static const _navOptions = [
    _NavOption(icon: Icons.gps_fixed_rounded,   title: 'GPS intégré',   subtitle: 'Recommandé'),
    _NavOption(icon: Icons.map_outlined,         title: 'Apple Plans',   subtitle: 'Application Maps'),
    _NavOption(icon: Icons.directions_rounded,   title: 'Google Maps',   subtitle: 'Application externe'),
    _NavOption(icon: Icons.alt_route_rounded,    title: 'Waze',          subtitle: 'Voiture uniquement'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: UrbinkSpacing.sm),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: widget.onBack,
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
                label: const Text('Retour'),
                style: TextButton.styleFrom(foregroundColor: UrbinkColors.onSurface),
              ),
              TextButton.icon(
                onPressed: widget.onCreateItineraire,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Créer'),
                style: TextButton.styleFrom(foregroundColor: UrbinkColors.primary),
              ),
            ],
          ),
        ),
        const SizedBox(height: UrbinkSpacing.xs),
        if (widget.selectedParcours != null) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: UrbinkSpacing.md),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: UrbinkSpacing.md, vertical: UrbinkSpacing.sm),
              decoration: BoxDecoration(
                color: UrbinkColors.accent.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(UrbinkSpacing.radiusChip),
                border: Border.all(color: UrbinkColors.accent.withValues(alpha: 0.30)),
              ),
              child: Row(
                children: [
                  Text(widget.selectedParcours!.emoji,
                      style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: UrbinkSpacing.sm),
                  Expanded(
                    child: Text(widget.selectedParcours!.name,
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: UrbinkColors.onSurface)),
                  ),
                  Text(
                    '${widget.selectedParcours!.distance} · ${widget.selectedParcours!.duration}',
                    style: const TextStyle(fontSize: 11, color: UrbinkColors.navInactive),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: UrbinkSpacing.sm),
        ],
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: UrbinkSpacing.md),
          child: Text(
            'Naviguer avec…',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700, color: UrbinkColors.onSurface),
          ),
        ),
        const SizedBox(height: UrbinkSpacing.sm + 4),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: UrbinkSpacing.md),
            itemCount: _navOptions.length,
            itemBuilder: (_, i) => Padding(
              padding: const EdgeInsets.only(bottom: UrbinkSpacing.sm),
              child: _NavOptionCard(
                option: _navOptions[i],
                isSelected: _selectedNav == i,
                onTap: () => setState(() => _selectedNav = i),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
              UrbinkSpacing.md, UrbinkSpacing.xs, UrbinkSpacing.md, UrbinkSpacing.md),
          child: _PrimaryCTA(
            label: "C'est parti !",
            icon: Icons.navigation_rounded,
            color: UrbinkColors.accent,
            onTap: widget.onCreateItineraire,
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
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bgColor = isSelected
        ? UrbinkColors.primary.withValues(alpha: 0.07)
        : UrbinkColors.surface;
    final borderColor =
        isSelected ? UrbinkColors.primary : UrbinkColors.border;
    final borderWidth = isSelected ? 1.5 : 1.0;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.all(UrbinkSpacing.md),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(UrbinkSpacing.radiusCard),
          border: Border.all(color: borderColor, width: borderWidth),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isSelected
                    ? UrbinkColors.primary.withValues(alpha: 0.12)
                    : UrbinkColors.surfaceVariant,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon,
                  size: 20,
                  color: isSelected
                      ? UrbinkColors.primary
                      : UrbinkColors.navInactive),
            ),
            const SizedBox(height: UrbinkSpacing.sm),
            Text(
              title,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: UrbinkColors.onSurface,
                  ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: isSelected
                        ? UrbinkColors.primary
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
// Card option de navigation (Naviguer avec…)
// ---------------------------------------------------------------------------

class _NavOption {
  const _NavOption({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;
}

class _NavOptionCard extends StatelessWidget {
  const _NavOptionCard({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  final _NavOption option;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(
          horizontal: UrbinkSpacing.md,
          vertical: UrbinkSpacing.sm + 2,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? UrbinkColors.primary.withValues(alpha: 0.06)
              : UrbinkColors.surface,
          borderRadius: BorderRadius.circular(UrbinkSpacing.radiusCard),
          border: Border.all(
            color: isSelected ? UrbinkColors.primary : UrbinkColors.border,
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected
                    ? UrbinkColors.primary.withValues(alpha: 0.10)
                    : UrbinkColors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(option.icon,
                  size: 20,
                  color: isSelected
                      ? UrbinkColors.primary
                      : UrbinkColors.navInactive),
            ),
            const SizedBox(width: UrbinkSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(option.title,
                      style:
                          Theme.of(context).textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: UrbinkColors.onSurface,
                              )),
                  Text(option.subtitle,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: UrbinkColors.navInactive,
                          )),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded,
                  size: 20, color: UrbinkColors.primary)
            else
              const Icon(Icons.radio_button_unchecked_rounded,
                  size: 20, color: UrbinkColors.border),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// CTA bouton principal — vert (circuit libre) ou amber (itinéraire)
// ---------------------------------------------------------------------------

class _PrimaryCTA extends StatelessWidget {
  const _PrimaryCTA({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: UrbinkSpacing.minTapTarget + 8,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 20),
        label: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 3,
          shadowColor: color.withValues(alpha: 0.40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(UrbinkSpacing.radiusButton),
          ),
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
        horizontal: UrbinkSpacing.sm + 2,
        vertical: UrbinkSpacing.xs + 2,
      ),
      decoration: BoxDecoration(
        color: UrbinkColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(UrbinkSpacing.radiusChip),
        border: Border.all(
          color: UrbinkColors.primary.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.gps_fixed_rounded,
              size: 14, color: UrbinkColors.primary),
          const SizedBox(width: UrbinkSpacing.xs),
          Text(
            'Mode auto-détecté · GPS prêt',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: UrbinkColors.primary,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Vue sélection d'un parcours existant
// ---------------------------------------------------------------------------

class _ParcourListBody extends StatelessWidget {
  const _ParcourListBody({
    required this.onBack,
    required this.onSelectParcours,
    required this.onCreateItineraire,
  });

  final VoidCallback onBack;
  final ValueChanged<_Parcours> onSelectParcours;
  final VoidCallback onCreateItineraire;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: UrbinkSpacing.sm),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
                label: const Text('Retour'),
                style: TextButton.styleFrom(foregroundColor: UrbinkColors.onSurface),
              ),
              TextButton.icon(
                onPressed: onCreateItineraire,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Créer'),
                style: TextButton.styleFrom(foregroundColor: UrbinkColors.primary),
              ),
            ],
          ),
        ),
        const SizedBox(height: UrbinkSpacing.xs),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: UrbinkSpacing.md),
          child: Text(
            'Mes itinéraires',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700, color: UrbinkColors.onSurface),
          ),
        ),
        const SizedBox(height: UrbinkSpacing.sm + 4),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(
                left: UrbinkSpacing.md,
                right: UrbinkSpacing.md,
                bottom: UrbinkSpacing.md),
            itemCount: _sampleParcours.length,
            itemBuilder: (_, i) => Padding(
              padding: const EdgeInsets.only(bottom: UrbinkSpacing.sm),
              child: _ParcoursCard(
                parcours: _sampleParcours[i],
                onTap: () => onSelectParcours(_sampleParcours[i]),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ParcoursCard extends StatelessWidget {
  const _ParcoursCard({required this.parcours, required this.onTap});

  final _Parcours parcours;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: UrbinkSpacing.md, vertical: UrbinkSpacing.sm + 2),
        decoration: BoxDecoration(
          color: UrbinkColors.surface,
          borderRadius: BorderRadius.circular(UrbinkSpacing.radiusCard),
          border: Border.all(color: UrbinkColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: UrbinkColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(parcours.emoji,
                    style: const TextStyle(fontSize: 20)),
              ),
            ),
            const SizedBox(width: UrbinkSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    parcours.name,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: UrbinkColors.onSurface,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${parcours.distance} · ${parcours.duration} · ${parcours.stepsCount} étapes',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: UrbinkColors.navInactive,
                        ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: UrbinkColors.navInactive, size: 20),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Drag handle — zone de swipe velocity-based
// ---------------------------------------------------------------------------

class _DragHandle extends StatelessWidget {
  const _DragHandle();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 24,
      child: Center(
        child: Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: UrbinkColors.sheetDragPill,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}
