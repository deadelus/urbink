import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:urbink/core/router/app_router.dart';
import 'package:urbink/features/profile/models/day_stats.dart';
import 'package:urbink/features/profile/providers/week_histogram_provider.dart';
import 'package:urbink/features/profile/widgets/week_histogram.dart';
import 'package:urbink/features/sessions/models/session.dart';
import 'package:urbink/shared/constants/colors.dart';
import 'package:urbink/shared/constants/spacing.dart';

enum _ViewMode { simple, feed }

/// Onglet "Vous" — histogramme hebdomadaire + liste des sorties.
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  int? _selectedDayIndex;
  _ViewMode _viewMode = _ViewMode.simple;

  @override
  Widget build(BuildContext context) {
    final histogramAsync = ref.watch(weekHistogramProvider);

    return Scaffold(
      backgroundColor: UrbinkColors.background,
      body: SafeArea(
        child: histogramAsync.when(
          loading: () =>
              const Center(child: CircularProgressIndicator(strokeWidth: 2)),
          error: (err, stack) => const Center(
            child: Text(
              'Impossible de charger l\'historique',
              style: TextStyle(color: UrbinkColors.textMuted),
            ),
          ),
          data: _buildContent,
        ),
      ),
    );
  }

  Widget _buildContent(List<DayStats> days) {
    final allEmpty = days.every((d) => d.isEmpty);
    final filteredSessions = _getFilteredSessions(days);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildHeader(days, allEmpty)),
        if (!allEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                UrbinkSpacing.md, UrbinkSpacing.sm, UrbinkSpacing.md, 0),
              child: _ViewToggle(
                selected: _viewMode,
                onChanged: (m) => setState(() => _viewMode = m),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: UrbinkSpacing.sm)),
        ],
        if (filteredSessions.isEmpty && !allEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(UrbinkSpacing.md),
              child: Text(
                _selectedDayIndex != null
                    ? 'Aucune sortie ce jour-là.'
                    : 'Aucune sortie cette semaine.',
                style: const TextStyle(color: UrbinkColors.textMuted),
              ),
            ),
          ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, i) => _buildSessionTile(filteredSessions[i]),
            childCount: filteredSessions.length,
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: UrbinkSpacing.xl)),
      ],
    );
  }

  Widget _buildHeader(List<DayStats> days, bool allEmpty) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        UrbinkSpacing.md,
        UrbinkSpacing.lg,
        UrbinkSpacing.md,
        UrbinkSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Vous',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: UrbinkColors.onSurface,
            ),
          ),
          const SizedBox(height: UrbinkSpacing.lg),
          Container(
            padding: const EdgeInsets.all(UrbinkSpacing.md),
            decoration: BoxDecoration(
              color: UrbinkColors.surface,
              borderRadius:
                  BorderRadius.circular(UrbinkSpacing.radiusCard),
              border: Border.all(color: UrbinkColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Cette semaine',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: UrbinkColors.textMuted,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: UrbinkSpacing.md),
                WeekHistogram(
                  days: days,
                  selectedDayIndex: _selectedDayIndex,
                  onDayTapped: (i) =>
                      setState(() => _selectedDayIndex = i),
                ),
                if (allEmpty) ...[
                  const SizedBox(height: UrbinkSpacing.md),
                  _EmptyWeekState(
                    onDemarrer: () => context.go(AppRoutes.map),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionTile(Session session) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: UrbinkSpacing.md,
        vertical: UrbinkSpacing.xs,
      ),
      child: Container(
        padding: const EdgeInsets.all(UrbinkSpacing.md),
        decoration: BoxDecoration(
          color: UrbinkColors.surface,
          borderRadius: BorderRadius.circular(UrbinkSpacing.radiusCard),
          border: Border.all(color: UrbinkColors.border),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatDate(session.sessionStart),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: UrbinkColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: UrbinkSpacing.xs),
                  Text(
                    '${session.streetCount} rues · '
                    '${session.distanceKm.toStringAsFixed(1)} km · '
                    '${_formatDuration(session.duration)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: UrbinkColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: UrbinkSpacing.sm),
            Text(
              session.mode.emoji,
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }

  List<Session> _getFilteredSessions(List<DayStats> days) {
    if (_selectedDayIndex != null) {
      return days[_selectedDayIndex!].sessions;
    }
    return (days.expand((d) => d.sessions).toList()
      ..sort((a, b) => b.sessionStart.compareTo(a.sessionStart)));
  }

  String _formatDate(DateTime date) {
    const months = [
      'jan', 'fév', 'mar', 'avr', 'mai', 'juin',
      'juil', 'août', 'sep', 'oct', 'nov', 'déc',
    ];
    return '${date.day} ${months[date.month - 1]}';
  }

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    if (h > 0) return '${h}h${m.toString().padLeft(2, '0')}';
    return '${m}min';
  }
}

// ---------------------------------------------------------------------------
// Empty week state — affiché sous l'histogramme si aucune session cette semaine
// ---------------------------------------------------------------------------

class _EmptyWeekState extends StatelessWidget {
  const _EmptyWeekState({required this.onDemarrer});

  final VoidCallback onDemarrer;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Ta première sortie cette semaine n\'attend que toi',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: UrbinkColors.textMuted,
            height: 1.4,
          ),
        ),
        const SizedBox(height: UrbinkSpacing.sm),
        TextButton(
          onPressed: onDemarrer,
          style: TextButton.styleFrom(
            foregroundColor: UrbinkColors.histogramOcre,
            textStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          child: const Text('Démarrer'),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Toggle Vue simple / Vue feed
// ---------------------------------------------------------------------------

class _ViewToggle extends StatelessWidget {
  const _ViewToggle({required this.selected, required this.onChanged});

  final _ViewMode selected;
  final ValueChanged<_ViewMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _Chip(
          label: 'Vue simple',
          active: selected == _ViewMode.simple,
          onTap: () => onChanged(_ViewMode.simple),
        ),
        const SizedBox(width: UrbinkSpacing.sm),
        _Chip(
          label: 'Vue feed',
          active: selected == _ViewMode.feed,
          onTap: () => onChanged(_ViewMode.feed),
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
          horizontal: UrbinkSpacing.md,
          vertical: UrbinkSpacing.sm,
        ),
        decoration: BoxDecoration(
          color:
              active ? UrbinkColors.histogramOcre : UrbinkColors.surfaceVariant,
          borderRadius: BorderRadius.circular(UrbinkSpacing.radiusChip),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: active ? Colors.white : UrbinkColors.textMuted,
          ),
        ),
      ),
    );
  }
}
