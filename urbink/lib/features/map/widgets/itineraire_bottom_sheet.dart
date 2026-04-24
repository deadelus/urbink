import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:urbink/l10n/app_localizations.dart';
import 'package:urbink/shared/constants/colors.dart';
import 'package:urbink/shared/constants/spacing.dart';

// ---------------------------------------------------------------------------
// Modèles
// ---------------------------------------------------------------------------

class ItinerairePoi {
  const ItinerairePoi({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.icon,
  });

  final String id;
  final String name;
  final String subtitle;
  final IconData icon;
}

const _mockPois = <ItinerairePoi>[
  ItinerairePoi(id: '1', name: 'Tour Eiffel',          subtitle: 'Monument · 7ème arr.',  icon: Icons.account_balance_rounded),
  ItinerairePoi(id: '2', name: 'Musée du Louvre',      subtitle: 'Musée · 1er arr.',      icon: Icons.museum_rounded),
  ItinerairePoi(id: '3', name: 'Jardin des Tuileries', subtitle: 'Parc · 1er arr.',       icon: Icons.park_rounded),
  ItinerairePoi(id: '4', name: 'Arc de Triomphe',      subtitle: 'Monument · 8ème arr.',  icon: Icons.account_balance_rounded),
  ItinerairePoi(id: '5', name: 'Café de Flore',        subtitle: 'Café · 6ème arr.',      icon: Icons.local_cafe_rounded),
];

// ---------------------------------------------------------------------------
// Données mock pour génération automatique
// ---------------------------------------------------------------------------

class _AutoGenResult {
  const _AutoGenResult({
    required this.pois,
    required this.distance,
    required this.estimatedDuration,
    required this.newStreets,
  });

  final List<ItinerairePoi> pois;
  final String distance;
  final String estimatedDuration;
  final int newStreets;
}

const _autoGenData = <int, _AutoGenResult>{
  15: _AutoGenResult(
    pois: [
      ItinerairePoi(id: 'a1', name: 'Place du Tertre',  subtitle: 'Place · Montmartre',   icon: Icons.landscape_rounded),
      ItinerairePoi(id: 'a2', name: 'Sacré-Cœur',       subtitle: 'Monument · 18ème arr.', icon: Icons.account_balance_rounded),
    ],
    distance: '1,2 km',
    estimatedDuration: '15 min',
    newStreets: 8,
  ),
  30: _AutoGenResult(
    pois: [
      ItinerairePoi(id: 'b1', name: 'Canal Saint-Martin', subtitle: 'Parc · 10ème arr.',       icon: Icons.water_rounded),
      ItinerairePoi(id: 'b2', name: 'Marché d\'Aligre',   subtitle: 'Marché · 12ème arr.',     icon: Icons.storefront_rounded),
      ItinerairePoi(id: 'b3', name: 'Coulée Verte',       subtitle: 'Promenade · 12ème arr.',  icon: Icons.park_rounded),
    ],
    distance: '2,8 km',
    estimatedDuration: '35 min',
    newStreets: 18,
  ),
  45: _AutoGenResult(
    pois: [
      ItinerairePoi(id: 'c1', name: 'Palais Royal',       subtitle: 'Jardin · 1er arr.',  icon: Icons.account_balance_rounded),
      ItinerairePoi(id: 'c2', name: 'Galerie Vivienne',   subtitle: 'Galerie · 2ème arr.', icon: Icons.store_rounded),
      ItinerairePoi(id: 'c3', name: 'Bourse de Commerce', subtitle: 'Musée · 1er arr.',   icon: Icons.museum_rounded),
      ItinerairePoi(id: 'c4', name: 'Les Halles',         subtitle: 'Centre · 1er arr.',  icon: Icons.shopping_bag_rounded),
    ],
    distance: '4,1 km',
    estimatedDuration: '50 min',
    newStreets: 27,
  ),
  60: _AutoGenResult(
    pois: [
      ItinerairePoi(id: 'd1', name: 'Père Lachaise',        subtitle: 'Cimetière · 20ème arr.', icon: Icons.landscape_rounded),
      ItinerairePoi(id: 'd2', name: 'Belleville',           subtitle: 'Quartier · 20ème arr.',  icon: Icons.location_city_rounded),
      ItinerairePoi(id: 'd3', name: 'Buttes-Chaumont',      subtitle: 'Parc · 19ème arr.',      icon: Icons.park_rounded),
      ItinerairePoi(id: 'd4', name: 'Bassin de la Villette',subtitle: 'Lac · 19ème arr.',       icon: Icons.water_rounded),
      ItinerairePoi(id: 'd5', name: 'Philharmonie de Paris',subtitle: 'Concert · 19ème arr.',   icon: Icons.music_note_rounded),
    ],
    distance: '6,3 km',
    estimatedDuration: '1h15',
    newStreets: 41,
  ),
};

enum _ItineraireView { manual, autoGenerate }

// ---------------------------------------------------------------------------
// Bottom sheet principale
// ---------------------------------------------------------------------------

class ItineraireBottomSheet extends StatefulWidget {
  const ItineraireBottomSheet({super.key});

  static const double collapsedHeight = 80.0;
  static const double maxFraction = 0.65;

  @override
  State<ItineraireBottomSheet> createState() => _ItineraireBottomSheetState();
}

class _ItineraireBottomSheetState extends State<ItineraireBottomSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _anim;
  bool _isExpanded = false;
  final List<ItinerairePoi> _pois = List.from(_mockPois);
  final TextEditingController _nameController = TextEditingController();
  _ItineraireView _view = _ItineraireView.manual;
  bool _goingForward = true;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
      value: 0.0,
    )..addListener(() {
        final expanded = _anim.value > 0.4;
        if (expanded != _isExpanded) setState(() => _isExpanded = expanded);
      });
  }

  @override
  void dispose() {
    _anim.dispose();
    _nameController.dispose();
    super.dispose();
  }

  double _sheetHeight(double parentH) {
    const partial = ItineraireBottomSheet.collapsedHeight;
    final max = parentH * ItineraireBottomSheet.maxFraction;
    return partial + (max - partial) * _anim.value;
  }

  void _onDragUpdate(DragUpdateDetails d, double parentH) {
    const partial = ItineraireBottomSheet.collapsedHeight;
    final max = parentH * ItineraireBottomSheet.maxFraction;
    final range = max - partial;
    final delta = -d.primaryDelta! / range;
    _anim.value = (_anim.value + delta).clamp(0.0, 1.0);
  }

  void _onDragEnd(DragEndDetails d, double parentH) {
    final v = d.primaryVelocity ?? 0;
    if (v < -300) { _snapTo(1.0); return; }
    if (v > 300) { _snapTo(0.0); return; }
    _snapTo(_anim.value > 0.35 ? 1.0 : 0.0);
  }

  void _snapTo(double target) {
    _anim.animateTo(target,
        duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
  }

  void _removeItem(String id) =>
      setState(() => _pois.removeWhere((p) => p.id == id));

  void _reorderItems(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final item = _pois.removeAt(oldIndex);
      _pois.insert(newIndex, item);
    });
  }

  void _applyGenerated(List<ItinerairePoi> generated) {
    setState(() {
      _pois
        ..clear()
        ..addAll(generated);
      _goingForward = false;
      _view = _ItineraireView.manual;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return LayoutBuilder(
      builder: (context, constraints) {
        final parentH = constraints.maxHeight;

        return AnimatedBuilder(
          animation: _anim,
          builder: (context, _) {
            final height = _sheetHeight(parentH);
            return Align(
              alignment: Alignment.bottomCenter,
              child: GestureDetector(
                onVerticalDragUpdate: (d) => _onDragUpdate(d, parentH),
                onVerticalDragEnd: (d) => _onDragEnd(d, parentH),
                child: SizedBox(
                  width: double.infinity,
                  height: height,
                  child: _SheetContent(
                    isExpanded: _isExpanded,
                    pois: _pois,
                    onRemove: _removeItem,
                    onReorder: _reorderItems,
                    bottomPadding: bottomPadding,
                    nameController: _nameController,
                    view: _view,
                    goingForward: _goingForward,
                    onSwitchToAuto: () => setState(() {
                      _goingForward = true;
                      _view = _ItineraireView.autoGenerate;
                    }),
                    onSwitchToManual: () => setState(() {
                      _goingForward = false;
                      _view = _ItineraireView.manual;
                    }),
                    onApplyGenerated: _applyGenerated,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Contenu du sheet
// ---------------------------------------------------------------------------

class _SheetContent extends StatelessWidget {
  const _SheetContent({
    required this.isExpanded,
    required this.pois,
    required this.onRemove,
    required this.onReorder,
    required this.bottomPadding,
    required this.nameController,
    required this.view,
    required this.goingForward,
    required this.onSwitchToAuto,
    required this.onSwitchToManual,
    required this.onApplyGenerated,
  });

  final bool isExpanded;
  final List<ItinerairePoi> pois;
  final ValueChanged<String> onRemove;
  final ReorderCallback onReorder;
  final double bottomPadding;
  final TextEditingController nameController;
  final _ItineraireView view;
  final bool goingForward;
  final VoidCallback onSwitchToAuto;
  final VoidCallback onSwitchToManual;
  final ValueChanged<List<ItinerairePoi>> onApplyGenerated;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(UrbinkSpacing.radiusSheet)),
        boxShadow: [
          BoxShadow(color: Color(0x14000000), blurRadius: 24, offset: Offset(0, -6)),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(
            top: Radius.circular(UrbinkSpacing.radiusSheet)),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background
            if (isExpanded)
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

            // Contenu — LayoutBuilder pour détecter la hauteur réelle
            // (évite l'overflow d'1 frame quand isExpanded lag derrière l'animation)
            LayoutBuilder(
              builder: (context, constraints) {
                final showBody = constraints.maxHeight > 120;
                return Column(
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
                            isExpanded
                                ? Icons.keyboard_arrow_down_rounded
                                : Icons.keyboard_arrow_up_rounded,
                            size: 16,
                            color: UrbinkColors.navInactive,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isExpanded
                                ? l10n.btn_close
                                : pois.isEmpty
                                    ? l10n.add_steps
                                    : l10n.step_count(pois.length),
                            style: const TextStyle(
                              fontSize: 12,
                              color: UrbinkColors.navInactive,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (showBody) ...[
                      const SizedBox(height: UrbinkSpacing.md),

                      // Toggle Manuel / Auto
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: UrbinkSpacing.md),
                        child: Row(
                          children: [
                            Expanded(
                              child: _ModeTab(
                                label: l10n.tab_manual,
                                icon: Icons.edit_location_alt_rounded,
                                isActive: view == _ItineraireView.manual,
                                onTap: onSwitchToManual,
                              ),
                            ),
                            const SizedBox(width: UrbinkSpacing.sm),
                            Expanded(
                              child: _ModeTab(
                                label: l10n.tab_auto,
                                icon: Icons.auto_awesome_rounded,
                                isActive: view == _ItineraireView.autoGenerate,
                                onTap: onSwitchToAuto,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: UrbinkSpacing.sm),

                      // Vue animée — slide directionnel sans croisement
                      Expanded(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 260),
                          transitionBuilder: (child, anim) {
                            final dir = goingForward ? 1.0 : -1.0;
                            final isEntering = child.key ==
                                ValueKey(view == _ItineraireView.manual ? 'manual' : 'auto');
                            final beginOffset =
                                isEntering ? Offset(dir, 0) : Offset(-dir, 0);
                            final slide = Tween<Offset>(
                              begin: beginOffset,
                              end: Offset.zero,
                            ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut));
                            return ClipRect(
                              child: SlideTransition(position: slide, child: child),
                            );
                          },
                          child: view == _ItineraireView.manual
                              ? _ManualContent(
                                  key: const ValueKey('manual'),
                                  pois: pois,
                                  onRemove: onRemove,
                                  onReorder: onReorder,
                                  bottomPadding: bottomPadding,
                                  nameController: nameController,
                                )
                              : _AutoGenerateContent(
                                  key: const ValueKey('auto'),
                                  bottomPadding: bottomPadding,
                                  onApply: onApplyGenerated,
                                ),
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),

            // Fondu bas quand réduit
            if (!isExpanded)
              Positioned(
                left: 0, right: 0, bottom: 0,
                child: IgnorePointer(
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          UrbinkColors.surface.withValues(alpha: 0),
                          UrbinkColors.surface.withValues(alpha: 0.96),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Onglet de mode
// ---------------------------------------------------------------------------

class _ModeTab extends StatelessWidget {
  const _ModeTab({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(vertical: UrbinkSpacing.sm),
        decoration: BoxDecoration(
          color: isActive
              ? UrbinkColors.primary.withValues(alpha: 0.10)
              : UrbinkColors.surfaceVariant,
          borderRadius: BorderRadius.circular(UrbinkSpacing.radiusChip),
          border: Border.all(
            color: isActive ? UrbinkColors.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14,
                color: isActive ? UrbinkColors.primary : UrbinkColors.navInactive),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isActive ? UrbinkColors.primary : UrbinkColors.navInactive,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Vue manuelle (liste POI réorganisable)
// ---------------------------------------------------------------------------

class _ManualContent extends StatelessWidget {
  const _ManualContent({
    super.key,
    required this.pois,
    required this.onRemove,
    required this.onReorder,
    required this.bottomPadding,
    required this.nameController,
  });

  final List<ItinerairePoi> pois;
  final ValueChanged<String> onRemove;
  final ReorderCallback onReorder;
  final double bottomPadding;
  final TextEditingController nameController;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxHeight < 230) return const SizedBox.expand();
        return _buildContent(context);
      },
    );
  }

  Widget _buildContent(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // En-tête
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: UrbinkSpacing.md),
          child: Row(
            children: [
              Flexible(
                child: Text(
                  l10n.steps_title,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: UrbinkColors.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (pois.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: UrbinkColors.primary.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(UrbinkSpacing.radiusChip),
                  ),
                  child: Text(
                    l10n.step_counter_badge(pois.length),
                    style: const TextStyle(
                      fontSize: 11,
                      color: UrbinkColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: UrbinkSpacing.sm),

        // Nom optionnel
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: UrbinkSpacing.md),
          child: TextField(
            controller: nameController,
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w500, color: UrbinkColors.onSurface),
            decoration: InputDecoration(
              hintText: l10n.itinerary_name_hint,
              hintStyle: const TextStyle(fontSize: 14, color: UrbinkColors.navInactive),
              prefixIcon: const Icon(Icons.drive_file_rename_outline_rounded,
                  size: 18, color: UrbinkColors.navInactive),
              filled: true,
              fillColor: UrbinkColors.surfaceVariant,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: UrbinkSpacing.md, vertical: UrbinkSpacing.sm + 2),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(UrbinkSpacing.radiusChip),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(UrbinkSpacing.radiusChip),
                borderSide: const BorderSide(color: UrbinkColors.primary, width: 1.5),
              ),
            ),
          ),
        ),
        const SizedBox(height: UrbinkSpacing.sm),

        // Liste ou état vide
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: pois.isEmpty
                ? const _EmptyState(key: ValueKey('empty'))
                : ReorderableListView.builder(
                    key: const ValueKey('list'),
                    padding: const EdgeInsets.symmetric(horizontal: UrbinkSpacing.md),
                    itemCount: pois.length,
                    onReorder: onReorder,
                    proxyDecorator: (child, index, animation) =>
                        Material(color: Colors.transparent, elevation: 6, child: child),
                    itemBuilder: (context, i) => _PoiTile(
                      key: ValueKey(pois[i].id),
                      poi: pois[i],
                      index: i,
                      onRemove: () => onRemove(pois[i].id),
                    ),
                  ),
          ),
        ),

        // CTA Créer — visible si ≥ 3 POI
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          transitionBuilder: (child, anim) => SizeTransition(
            sizeFactor: CurvedAnimation(parent: anim, curve: Curves.easeOut),
            child: FadeTransition(opacity: anim, child: child),
          ),
          child: pois.length >= 3
              ? Padding(
                  key: const ValueKey('cta_visible'),
                  padding: EdgeInsets.fromLTRB(
                    UrbinkSpacing.md, UrbinkSpacing.sm,
                    UrbinkSpacing.md, UrbinkSpacing.md + bottomPadding,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: UrbinkSpacing.minTapTarget + 8,
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.route_rounded, size: 20),
                      label: Text(
                        l10n.btn_create_itinerary,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: UrbinkColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 3,
                        shadowColor: UrbinkColors.primary.withValues(alpha: 0.40),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(UrbinkSpacing.radiusButton),
                        ),
                      ),
                    ),
                  ),
                )
              : SizedBox(
                  key: const ValueKey('cta_hidden'),
                  height: bottomPadding + UrbinkSpacing.md,
                ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Vue génération automatique (StatefulWidget — gère loading + résultat)
// ---------------------------------------------------------------------------

class _AutoGenerateContent extends StatefulWidget {
  const _AutoGenerateContent({
    super.key,
    required this.bottomPadding,
    required this.onApply,
  });

  final double bottomPadding;
  final ValueChanged<List<ItinerairePoi>> onApply;

  @override
  State<_AutoGenerateContent> createState() => _AutoGenerateContentState();
}

class _AutoGenerateContentState extends State<_AutoGenerateContent> {
  int _selectedDuration = 30;
  bool _isGenerating = false;
  _AutoGenResult? _result;

  Future<void> _generate() async {
    setState(() {
      _isGenerating = true;
      _result = null;
    });
    // Simule l'appel Cloud Function generate_parcours.go
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    setState(() {
      _isGenerating = false;
      _result = _autoGenData[_selectedDuration];
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxHeight < 300) return const SizedBox.expand();
        return _buildContent(context);
      },
    );
  }

  Widget _buildContent(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (_isGenerating) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: UrbinkColors.primary, strokeWidth: 3),
            const SizedBox(height: UrbinkSpacing.md),
            Text(
              l10n.generating_loading,
              style: const TextStyle(
                  fontSize: 13,
                  color: UrbinkColors.navInactive,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
    }

    if (_result != null) {
      return _AutoGenResultView(
        result: _result!,
        bottomPadding: widget.bottomPadding,
        onApply: () => widget.onApply(_result!.pois),
        onRegenerate: _generate,
      );
    }

    return _DurationSelector(
      selectedDuration: _selectedDuration,
      onSelectDuration: (d) => setState(() => _selectedDuration = d),
      onGenerate: _generate,
      bottomPadding: widget.bottomPadding,
    );
  }
}

// ---------------------------------------------------------------------------
// Sélecteur de durée + CTA Générer
// ---------------------------------------------------------------------------

class _DurationSelector extends StatelessWidget {
  const _DurationSelector({
    required this.selectedDuration,
    required this.onSelectDuration,
    required this.onGenerate,
    required this.bottomPadding,
  });

  final int selectedDuration;
  final ValueChanged<int> onSelectDuration;
  final VoidCallback onGenerate;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: UrbinkSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.auto_gen_title,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: UrbinkColors.onSurface),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.auto_gen_description,
                style: const TextStyle(fontSize: 12, color: UrbinkColors.navInactive),
              ),
            ],
          ),
        ),
        const SizedBox(height: UrbinkSpacing.md),

        // Chips durée
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: UrbinkSpacing.md),
          child: Row(
            children: [15, 30, 45, 60].map((d) {
              final isSelected = d == selectedDuration;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: d != 60 ? UrbinkSpacing.xs : 0),
                  child: GestureDetector(
                    onTap: () => onSelectDuration(d),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                          vertical: UrbinkSpacing.sm + 2),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? UrbinkColors.primary
                            : UrbinkColors.surfaceVariant,
                        borderRadius:
                            BorderRadius.circular(UrbinkSpacing.radiusChip),
                        border: Border.all(
                          color: isSelected
                              ? UrbinkColors.primary
                              : Colors.transparent,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '$d',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: isSelected
                                  ? Colors.white
                                  : UrbinkColors.onSurface,
                            ),
                          ),
                          Text(
                            l10n.time_unit_minutes,
                            style: TextStyle(
                              fontSize: 10,
                              color: isSelected
                                  ? Colors.white.withValues(alpha: 0.80)
                                  : UrbinkColors.navInactive,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: UrbinkSpacing.md),

        // Aperçu stats estimées
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: UrbinkSpacing.md),
          child: _StatsRow(
            duration: selectedDuration,
            color: UrbinkColors.primary,
          ),
        ),

        const Spacer(),

        // CTA Générer
        Padding(
          padding: EdgeInsets.fromLTRB(
            UrbinkSpacing.md,
            UrbinkSpacing.sm,
            UrbinkSpacing.md,
            UrbinkSpacing.md + bottomPadding,
          ),
          child: SizedBox(
            width: double.infinity,
            height: UrbinkSpacing.minTapTarget + 8,
            child: ElevatedButton.icon(
              onPressed: onGenerate,
              icon: const Icon(Icons.auto_awesome_rounded, size: 20),
              label: Text(
                l10n.btn_generate_itinerary,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: UrbinkColors.accent,
                foregroundColor: Colors.white,
                elevation: 3,
                shadowColor: UrbinkColors.accent.withValues(alpha: 0.40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(UrbinkSpacing.radiusButton),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Bandeau stats (estimées ou réelles)
// ---------------------------------------------------------------------------

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.duration, required this.color});

  final int duration;
  final Color color;

  String get _distance => switch (duration) {
        15 => '~1,2 km',
        30 => '~2,8 km',
        45 => '~4,1 km',
        _ => '~6,3 km',
      };

  String get _streets => switch (duration) {
        15 => '~8 rues',
        30 => '~18 rues',
        45 => '~27 rues',
        _ => '~41 rues',
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bgColor = color.withValues(alpha: 0.07);
    final borderColor = color.withValues(alpha: 0.18);
    final divColor = color.withValues(alpha: 0.18);

    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: UrbinkSpacing.md, vertical: UrbinkSpacing.sm + 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(UrbinkSpacing.radiusChip),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(icon: Icons.straighten_rounded, label: _distance, color: color),
          Container(width: 1, height: 20, color: divColor),
          _StatItem(icon: Icons.timer_outlined, label: '$duration ${l10n.time_unit_minutes}', color: color),
          Container(width: 1, height: 20, color: divColor),
          _StatItem(icon: Icons.route_rounded, label: _streets, color: color),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w600, color: color),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Vue résultat de génération
// ---------------------------------------------------------------------------

class _AutoGenResultView extends StatelessWidget {
  const _AutoGenResultView({
    required this.result,
    required this.bottomPadding,
    required this.onApply,
    required this.onRegenerate,
  });

  final _AutoGenResult result;
  final double bottomPadding;
  final VoidCallback onApply;
  final VoidCallback onRegenerate;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Bandeau stats réel (avec temps estimé)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: UrbinkSpacing.md),
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: UrbinkSpacing.md, vertical: UrbinkSpacing.sm + 2),
            decoration: BoxDecoration(
              color: UrbinkColors.accent.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(UrbinkSpacing.radiusChip),
              border: Border.all(
                  color: UrbinkColors.accent.withValues(alpha: 0.22)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatItem(
                    icon: Icons.straighten_rounded,
                    label: result.distance,
                    color: UrbinkColors.accent),
                Container(
                    width: 1,
                    height: 20,
                    color: UrbinkColors.accent.withValues(alpha: 0.22)),
                _StatItem(
                    icon: Icons.timer_outlined,
                    label: result.estimatedDuration,
                    color: UrbinkColors.accent),
                Container(
                    width: 1,
                    height: 20,
                    color: UrbinkColors.accent.withValues(alpha: 0.22)),
                _StatItem(
                    icon: Icons.route_rounded,
                    label: '${result.newStreets} rues',
                    color: UrbinkColors.accent),
              ],
            ),
          ),
        ),
        const SizedBox(height: UrbinkSpacing.sm),

        // Liste générée (lecture seule)
        Expanded(
          child: ListView.builder(
            padding:
                const EdgeInsets.symmetric(horizontal: UrbinkSpacing.md),
            itemCount: result.pois.length,
            itemBuilder: (_, i) => Padding(
              padding: const EdgeInsets.only(bottom: UrbinkSpacing.sm),
              child: _PoiTileReadOnly(poi: result.pois[i], index: i),
            ),
          ),
        ),

        // Actions: Regénérer | Utiliser
        Padding(
          padding: EdgeInsets.fromLTRB(
            UrbinkSpacing.md,
            UrbinkSpacing.xs,
            UrbinkSpacing.md,
            UrbinkSpacing.md + bottomPadding,
          ),
          child: Row(
            children: [
              SizedBox(
                height: UrbinkSpacing.minTapTarget + 8,
                child: OutlinedButton.icon(
                  onPressed: onRegenerate,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: Text(l10n.btn_regenerate),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: UrbinkColors.onSurface,
                    side: const BorderSide(color: UrbinkColors.border),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(UrbinkSpacing.radiusButton),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: UrbinkSpacing.sm),
              Expanded(
                child: SizedBox(
                  height: UrbinkSpacing.minTapTarget + 8,
                  child: ElevatedButton.icon(
                    onPressed: onApply,
                    icon: const Icon(Icons.check_rounded, size: 20),
                    label: Text(
                      l10n.btn_use_itinerary,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: UrbinkColors.accent,
                      foregroundColor: Colors.white,
                      elevation: 3,
                      shadowColor: UrbinkColors.accent.withValues(alpha: 0.40),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(UrbinkSpacing.radiusButton),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Tile POI lecture seule (résultat auto-gen)
// ---------------------------------------------------------------------------

class _PoiTileReadOnly extends StatelessWidget {
  const _PoiTileReadOnly({required this.poi, required this.index});

  final ItinerairePoi poi;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: UrbinkSpacing.sm + 4, vertical: UrbinkSpacing.sm + 2),
      decoration: BoxDecoration(
        color: UrbinkColors.surface,
        borderRadius: BorderRadius.circular(UrbinkSpacing.radiusCard),
        border: Border.all(color: UrbinkColors.border),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 1)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 26, height: 26,
            decoration: BoxDecoration(
                color: UrbinkColors.accent,
                borderRadius: BorderRadius.circular(7)),
            child: Center(
              child: Text('${index + 1}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(width: UrbinkSpacing.sm),
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
                color: UrbinkColors.accent.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10)),
            child: Icon(poi.icon, size: 18, color: UrbinkColors.accent),
          ),
          const SizedBox(width: UrbinkSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(poi.name,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: UrbinkColors.onSurface)),
                Text(poi.subtitle,
                    style: const TextStyle(
                        fontSize: 11, color: UrbinkColors.navInactive)),
              ],
            ),
          ),
          const Icon(Icons.auto_awesome_rounded,
              size: 14, color: UrbinkColors.accent),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tile POI réorganisable (mode manuel)
// ---------------------------------------------------------------------------

class _PoiTile extends StatelessWidget {
  const _PoiTile({
    super.key,
    required this.poi,
    required this.index,
    required this.onRemove,
  });

  final ItinerairePoi poi;
  final int index;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: UrbinkSpacing.sm),
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: UrbinkSpacing.sm + 4, vertical: UrbinkSpacing.sm + 2),
        decoration: BoxDecoration(
          color: UrbinkColors.surface,
          borderRadius: BorderRadius.circular(UrbinkSpacing.radiusCard),
          border: Border.all(color: UrbinkColors.border),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 6,
                offset: const Offset(0, 1)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 26, height: 26,
              decoration: BoxDecoration(
                  color: UrbinkColors.primary,
                  borderRadius: BorderRadius.circular(7)),
              child: Center(
                child: Text('${index + 1}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(width: UrbinkSpacing.sm),
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                  color: UrbinkColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10)),
              child: Icon(poi.icon, size: 18, color: UrbinkColors.primary),
            ),
            const SizedBox(width: UrbinkSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(poi.name,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: UrbinkColors.onSurface)),
                  Text(poi.subtitle,
                      style: const TextStyle(
                          fontSize: 11, color: UrbinkColors.navInactive)),
                ],
              ),
            ),
            GestureDetector(
              onTap: onRemove,
              child: const SizedBox(
                width: 36, height: 36,
                child: Icon(Icons.remove_circle_outline_rounded,
                    size: 20, color: UrbinkColors.destructive),
              ),
            ),
            const SizedBox(width: UrbinkSpacing.xs),
            ReorderableDragStartListener(
              index: index,
              child: const SizedBox(
                width: 32, height: 36,
                child: Icon(Icons.drag_handle_rounded,
                    size: 20, color: UrbinkColors.navInactive),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// État vide
// ---------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  const _EmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(
                color: UrbinkColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20)),
            child: const Icon(Icons.add_location_alt_rounded,
                size: 32, color: UrbinkColors.primary),
          ),
          const SizedBox(height: UrbinkSpacing.md),
          Text(
            l10n.empty_no_steps,
            style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: UrbinkColors.onSurface),
          ),
          const SizedBox(height: UrbinkSpacing.xs),
          Text(
            l10n.empty_select_places,
            style: const TextStyle(fontSize: 13, color: UrbinkColors.navInactive),
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
    return SizedBox(
      width: double.infinity,
      height: 24,
      child: Center(
        child: Container(
          width: 40, height: 4,
          decoration: BoxDecoration(
              color: UrbinkColors.sheetDragPill,
              borderRadius: BorderRadius.circular(2)),
        ),
      ),
    );
  }
}
