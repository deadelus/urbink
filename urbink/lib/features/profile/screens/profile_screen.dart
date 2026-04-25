import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urbink/features/profile/providers/sessions_list_provider.dart';
import 'package:urbink/features/profile/providers/week_sessions_provider.dart';
import 'package:urbink/features/sessions/models/session.dart';
import 'package:urbink/l10n/app_localizations.dart';
import 'package:urbink/shared/constants/colors.dart';
import 'package:urbink/shared/constants/spacing.dart';
import 'package:urbink/shared/widgets/urbink_empty_state.dart';
import 'package:urbink/shared/widgets/week_histogram.dart';

/// Onglet Vous — Historique personnel.
///
/// Structure :
///   1. WeekHistogram (7 jours, filtrable par tap)
///   2. Toggle Vue simple / Vue feed
///   3. Liste des sorties (filtrée par le jour sélectionné dans l'histogramme)
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: UrbinkColors.background,
      body: Column(
        children: [
          // En-tête fixe — titre + histogramme
          _ProfileHeader(topPadding: topPadding),
          // Liste scrollable
          const Expanded(child: _SessionsList()),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// En-tête
// ---------------------------------------------------------------------------

class _ProfileHeader extends ConsumerWidget {
  const _ProfileHeader({required this.topPadding});

  final double topPadding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDay = ref.watch(selectedHistogramDayProvider);

    return Container(
      color: UrbinkColors.surface,
      padding: EdgeInsets.fromLTRB(
        UrbinkSpacing.md,
        topPadding + UrbinkSpacing.sm,
        UrbinkSpacing.md,
        UrbinkSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                AppLocalizations.of(context).profile_title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: UrbinkColors.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              if (selectedDay != null) ...[
                const SizedBox(width: UrbinkSpacing.sm),
                _DayFilterChip(day: selectedDay, ref: ref),
              ],
            ],
          ),
          const SizedBox(height: UrbinkSpacing.md),
          const WeekHistogram(),
        ],
      ),
    );
  }
}

class _DayFilterChip extends StatelessWidget {
  const _DayFilterChip({required this.day, required this.ref});

  final DateTime day;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final label = _formatDayShort(day);
    return GestureDetector(
      onTap: () => ref.read(selectedHistogramDayProvider.notifier).state = null,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: UrbinkSpacing.sm,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: UrbinkColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(UrbinkSpacing.radiusChip),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: UrbinkColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.close_rounded,
              size: 14,
              color: UrbinkColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Liste des sorties
// ---------------------------------------------------------------------------

class _SessionsList extends ConsumerStatefulWidget {
  const _SessionsList();

  @override
  ConsumerState<_SessionsList> createState() => _SessionsListState();
}

class _SessionsListState extends ConsumerState<_SessionsList> {
  bool _simpleView = true;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 150) {
      ref.read(sessionsByDayProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final sessionsAsync = ref.watch(sessionsByDayProvider);
    final selectedDay = ref.watch(selectedHistogramDayProvider);

    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        // Toggle Vue simple / Vue feed
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: UrbinkSpacing.md,
            vertical: UrbinkSpacing.sm,
          ),
          child: Row(
            children: [
              Text(
                selectedDay != null
                    ? l10n.profile_sessions_of(_formatDayLong(selectedDay))
                    : l10n.profile_all_sessions,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: UrbinkColors.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const Spacer(),
              _ViewToggle(
                isSimple: _simpleView,
                onChanged: (v) => setState(() => _simpleView = v),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        // Contenu
        Expanded(
          child: sessionsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => Center(child: Text(l10n.profile_error_loading)),
            data: (pageState) {
              final sessions = pageState.sessions;
              if (sessions.isEmpty) {
                return UrbinkEmptyState(
                  emoji: '🗺️',
                  title: selectedDay != null
                      ? l10n.profile_no_sessions_day
                      : l10n.profile_no_sessions,
                );
              }
              if (_simpleView) {
                return Column(
                  children: [
                    Expanded(
                      child: ListView.separated(
                        controller: _scrollController,
                        padding: const EdgeInsets.only(top: UrbinkSpacing.xs),
                        itemCount: sessions.length,
                        separatorBuilder: (_, _) =>
                            const Divider(height: 1, indent: UrbinkSpacing.md),
                        itemBuilder: (ctx, i) =>
                            _SortieListTile(session: sessions[i]),
                      ),
                    ),
                    _PaginationFooter(pageState: pageState),
                  ],
                );
              }
              // Vue feed — placeholder Epic 9
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('📸', style: TextStyle(fontSize: 40)),
                    const SizedBox(height: UrbinkSpacing.sm),
                    Text(
                      l10n.profile_feed_placeholder,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: UrbinkColors.navInactive,
                          ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Footer de pagination
// ---------------------------------------------------------------------------

class _PaginationFooter extends StatelessWidget {
  const _PaginationFooter({required this.pageState});

  final SessionsPageState pageState;

  @override
  Widget build(BuildContext context) {
    if (pageState.isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: UrbinkSpacing.md),
        child: Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }
    if (!pageState.hasMore && pageState.sessions.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: UrbinkSpacing.sm),
        child: Center(
          child: Text(
            AppLocalizations.of(context).profile_all_shown,
            style: const TextStyle(
              fontSize: 12,
              color: UrbinkColors.navInactive,
            ),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}

// ---------------------------------------------------------------------------
// Toggle vue simple / feed
// ---------------------------------------------------------------------------

class _ViewToggle extends StatelessWidget {
  const _ViewToggle({required this.isSimple, required this.onChanged});

  final bool isSimple;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ToggleButton(
          label: l10n.profile_view_simple,
          icon: Icons.list_rounded,
          isActive: isSimple,
          onTap: () => onChanged(true),
        ),
        const SizedBox(width: 4),
        _ToggleButton(
          label: l10n.profile_view_feed,
          icon: Icons.grid_view_rounded,
          isActive: !isSimple,
          onTap: () => onChanged(false),
        ),
      ],
    );
  }
}

class _ToggleButton extends StatelessWidget {
  const _ToggleButton({
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
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isActive
              ? UrbinkColors.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(UrbinkSpacing.radiusChip),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isActive ? UrbinkColors.primary : UrbinkColors.navInactive,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
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
// ListTile compact d'une sortie
// ---------------------------------------------------------------------------

class _SortieListTile extends StatelessWidget {
  const _SortieListTile({required this.session});

  final Session session;

  @override
  Widget build(BuildContext context) {
    final date = _formatSessionDate(session.sessionStart);
    final distance = session.distanceKm >= 1.0
        ? '${session.distanceKm.toStringAsFixed(1)} km'
        : '${session.distanceMeters.toStringAsFixed(0)} m';
    final dur = session.duration;
    final duration = dur.inHours > 0
        ? '${dur.inHours}h${dur.inMinutes.remainder(60).toString().padLeft(2, '0')}'
        : '${dur.inMinutes}min';

    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: UrbinkSpacing.md,
        vertical: UrbinkSpacing.xs,
      ),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: UrbinkColors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            session.mode.emoji,
            style: const TextStyle(fontSize: 18),
          ),
        ),
      ),
      title: Text(
        date,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: UrbinkColors.onSurface,
        ),
      ),
      subtitle: Text(
        '${session.streetCount} rues · $distance · $duration',
        style: const TextStyle(
          fontSize: 12,
          color: UrbinkColors.navInactive,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Helpers de formatage de date en français (sans dépendance locale intl)
// ---------------------------------------------------------------------------

const _shortDays = ['lun', 'mar', 'mer', 'jeu', 'ven', 'sam', 'dim'];
const _longDays = ['lundi', 'mardi', 'mercredi', 'jeudi', 'vendredi', 'samedi', 'dimanche'];
const _shortMonths = ['jan', 'fév', 'mar', 'avr', 'mai', 'juin', 'juil', 'aoû', 'sep', 'oct', 'nov', 'déc'];

/// "lun 5 jan"
String _formatDayShort(DateTime d) =>
    '${_shortDays[d.weekday - 1]} ${d.day} ${_shortMonths[d.month - 1]}';

/// "lundi 5 jan"
String _formatDayLong(DateTime d) =>
    '${_longDays[d.weekday - 1]} ${d.day} ${_shortMonths[d.month - 1]}';

/// "lun 5 jan · 14:32"
String _formatSessionDate(DateTime d) {
  final hh = d.hour.toString().padLeft(2, '0');
  final mm = d.minute.toString().padLeft(2, '0');
  return '${_formatDayShort(d)} · $hh:$mm';
}
