import 'dart:ui' show ImageFilter;

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:urbink/core/router/app_router.dart';
import 'package:urbink/features/map/providers/bottom_sheet_state_provider.dart';
import 'package:urbink/features/map/providers/map_layers_provider.dart';
import 'package:urbink/features/map/providers/zones_layer_provider.dart';
import 'package:urbink/features/map/widgets/map_layers_section.dart';
import 'package:urbink/features/session_end/controllers/session_end_flow.dart';
import 'package:urbink/features/session_end/models/badge_unlock.dart';
import 'package:urbink/features/session_end/services/badge_detector.dart';
import 'package:urbink/features/sessions/models/session_data.dart';
import 'package:urbink/features/sessions/providers/gps_tracking_provider.dart';
import 'package:urbink/features/sessions/providers/session_lifecycle_provider.dart';
import 'package:urbink/features/sessions/providers/session_metrics_provider.dart';
import 'package:urbink/features/sessions/session_state_provider.dart';
import 'package:urbink/features/sessions/widgets/session_monitor.dart';
import 'package:urbink/l10n/app_localizations.dart';
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

  // Hauteur parent mise en cache pour usage dans les callbacks ref.listen
  double _parentH = 0;

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

  Future<void> _stopSession() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Arrêter la session ?'),
        content: const Text('Ta progression sera sauvegardée.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Continuer'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: UrbinkColors.destructive),
            child: const Text('Arrêter'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final metrics = ref.read(sessionMetricsProvider);
    final session =
        await ref.read(sessionLifecycleProvider.notifier).stopAndSave(metrics);

    if (!mounted) return;
    ref.read(sessionStateProvider.notifier).state = SessionState.idle;

    if (session == null) return;

    final sessionData = SessionData(
      active: false,
      km: session.distanceKm,
      streets: session.streetCount,
      secs: session.duration.inSeconds,
    );
    var badges = BadgeDetector.detectUnlocks(
      exploredStreets: metrics.exploredStreetIds,
      currentBadgeIds: const [],
    );

    if (kDebugMode && badges.isEmpty) {
      badges = const [
        BadgeUnlock(id: 'dev_1', name: 'Explorateur', description: 'Tu as exploré tes premières rues !', icon: '🗺️'),
        BadgeUnlock(id: 'dev_2', name: 'Pont de la Tournelle', description: 'Premier kilomètre parcouru sur les berges.', icon: '🌉'),
      ];
    }

    if (!mounted) return;
    await SessionEndFlow.show(
      context: context,
      ref: ref,
      session: sessionData,
      badges: badges,
    );
  }

  @override
  Widget build(BuildContext context) {
    final sessionState = ref.watch(sessionStateProvider);
    final isSessionActive = sessionState == SessionState.active;

    final metrics = ref.watch(sessionMetricsProvider);
    SessionData? sessionData;
    if (isSessionActive) {
      sessionData = SessionData(
        active: true,
        km: metrics.distanceKm,
        streets: metrics.streetCount,
        secs: metrics.elapsed.inSeconds,
        sessionStartTime: metrics.sessionStartTime,
      );
    }

    ref.listen<SessionState>(sessionStateProvider, (prev, next) {
      if (prev == SessionState.idle && next == SessionState.active && mounted) {
        if (_parentH > 0) _snapTo(1.0, _parentH);
      }
      if (next == SessionState.idle && mounted) {
        setState(() {
          _view = _SheetView.selectMode;
          _selectedParcours = null;
        });
        _anim.value = 0.0;
      }
    });

    return LayoutBuilder(
      builder: (context, constraints) {
        final parentH = constraints.maxHeight;
        _parentH = parentH;

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
            sessionData: sessionData,
            onStop: _stopSession,
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
    required this.onStop,
    this.sessionData,
    this.selectedParcours,
  });

  final _SheetView view;
  final bool isSessionActive;
  final SessionData? sessionData;
  final VoidCallback onStop;
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

  @override
  void initState() {
    super.initState();
    _prevView = widget.view;
    _pushController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
      value: 1.0,
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final w = MediaQuery.sizeOf(context).width;

    final collapsedLabel = switch (widget.view) {
      _SheetView.selectMode      => l10n.exit_start_session,
      _SheetView.parcoursList    => l10n.my_itineraries,
      _SheetView.itinerairesList => l10n.btn_create_itinerary,
    };

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

            // Content
            if (widget.isSessionActive)
              _SessionActiveContent(
                isExpanded: widget.isExpanded,
                session: widget.sessionData!,
                onStop: widget.onStop,
              )
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
                          widget.isExpanded ? l10n.btn_close : collapsedLabel,
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
// Contenu sheet quand session active
// ---------------------------------------------------------------------------

class _SessionActiveContent extends StatelessWidget {
  const _SessionActiveContent({
    required this.isExpanded,
    required this.session,
    required this.onStop,
  });

  final bool isExpanded;
  final SessionData session;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: UrbinkSpacing.sm),
        const _DragHandle(),
        if (isExpanded)
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: UrbinkSpacing.lg),
              child: SessionMonitor(
                session: session,
                mode: 'libre',
                expanded: true,
                onStop: onStop,
              ),
            ),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Vue sélection du mode (Circuit libre / Itinéraire)
// ---------------------------------------------------------------------------

class _SelectModeBody extends ConsumerStatefulWidget {
  const _SelectModeBody({
    required this.onSelectItineraire,
    required this.onStart,
  });

  final VoidCallback onSelectItineraire;
  final VoidCallback onStart;

  @override
  ConsumerState<_SelectModeBody> createState() => _SelectModeBodyState();
}

class _SelectModeBodyState extends ConsumerState<_SelectModeBody> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final layers = ref.watch(mapLayersProvider);
    final quartiersVisible = ref.watch(zonesLayerVisibleProvider);
    final layerValues = {...layers, 'quartiers': quartiersVisible};

    return ListView(
      padding: const EdgeInsets.only(
          top: UrbinkSpacing.lg, bottom: UrbinkSpacing.lg),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: UrbinkSpacing.md),
          child: Text(
            l10n.exit_start_session,
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
              Expanded(
                child: _ModeCard(
                  icon: Icons.directions_walk_rounded,
                  title: l10n.mode_free_circuit,
                  subtitle: l10n.mode_free_default,
                  isSelected: true,
                  onTap: null,
                ),
              ),
              const SizedBox(width: UrbinkSpacing.sm),
              Expanded(
                child: _ModeCard(
                  icon: Icons.map_outlined,
                  title: l10n.mode_itinerary,
                  subtitle: l10n.mode_itinerary_choose,
                  isSelected: false,
                  onTap: widget.onSelectItineraire,
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
            label: l10n.exit_start_session_cta,
            icon: Icons.play_arrow_rounded,
            color: UrbinkColors.primary,
            onTap: widget.onStart,
          ),
        ),
        const SizedBox(height: UrbinkSpacing.md),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: UrbinkSpacing.md),
          child: MapLayersSection(
            values: layerValues,
            onChanged: (v) {
              ref.read(mapLayersProvider.notifier).state = {
                'monuments': v['monuments'] ?? true,
                'photos': v['photos'] ?? false,
                'quartiers': v['quartiers'] ?? false,
              };
              ref.read(zonesLayerVisibleProvider.notifier).state =
                  v['quartiers'] ?? false;
            },
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

  List<_NavOption> _buildNavOptions(AppLocalizations l10n) => [
    _NavOption(icon: Icons.gps_fixed_rounded,   title: l10n.nav_gps_integrated, subtitle: l10n.nav_gps_recommended),
    _NavOption(icon: Icons.map_outlined,         title: l10n.nav_apple_plans,    subtitle: l10n.nav_apple_maps_app),
    _NavOption(icon: Icons.directions_rounded,   title: l10n.nav_google_maps,    subtitle: l10n.nav_external_app),
    _NavOption(icon: Icons.alt_route_rounded,    title: l10n.nav_waze,           subtitle: l10n.nav_car_only),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final navOptions = _buildNavOptions(l10n);

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
                label: Text(l10n.btn_back),
                style: TextButton.styleFrom(foregroundColor: UrbinkColors.onSurface),
              ),
              TextButton.icon(
                onPressed: widget.onCreateItineraire,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: Text(l10n.btn_create),
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
            l10n.navigate_with_title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700, color: UrbinkColors.onSurface),
          ),
        ),
        const SizedBox(height: UrbinkSpacing.sm + 4),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: UrbinkSpacing.md),
            itemCount: navOptions.length,
            itemBuilder: (_, i) => Padding(
              padding: const EdgeInsets.only(bottom: UrbinkSpacing.sm),
              child: _NavOptionCard(
                option: navOptions[i],
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
            label: l10n.btn_lets_go,
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
// Card option de navigation
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
// CTA bouton principal
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
    final l10n = AppLocalizations.of(context);

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
            l10n.gps_mode_ready,
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
    final l10n = AppLocalizations.of(context);

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
                label: Text(l10n.btn_back),
                style: TextButton.styleFrom(foregroundColor: UrbinkColors.onSurface),
              ),
              TextButton.icon(
                onPressed: onCreateItineraire,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: Text(l10n.btn_create),
                style: TextButton.styleFrom(foregroundColor: UrbinkColors.primary),
              ),
            ],
          ),
        ),
        const SizedBox(height: UrbinkSpacing.xs),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: UrbinkSpacing.md),
          child: Text(
            l10n.my_itineraries,
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
// Drag handle
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
