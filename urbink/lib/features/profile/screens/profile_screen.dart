import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urbink/features/gamification/models/celebration_event.dart';
import 'package:urbink/features/gamification/providers/celebration_queue_provider.dart';
import 'package:urbink/features/profile/data/explorer_rank.dart';
import 'package:urbink/features/profile/providers/explorer_rank_provider.dart';
import 'package:urbink/features/profile/providers/profile_stats_provider.dart';
import 'package:urbink/features/profile/providers/sessions_list_provider.dart';
import 'package:urbink/features/profile/screens/ranks_screen.dart';
import 'package:urbink/features/profile/widgets/rank_card.dart';
import 'package:urbink/features/sessions/models/session.dart';
import 'package:urbink/l10n/app_localizations.dart';
import 'package:urbink/shared/constants/colors.dart';
import 'package:urbink/shared/constants/spacing.dart';
import 'package:urbink/shared/widgets/urbink_empty_state.dart';

/// Onglet Vous — Rang d'explorateur + historique personnel.
///
/// Structure :
///   1. En-tête fixe : titre + WeekHistogram + RankCard + RankPreviewStrip
///   2. Liste scrollable des sorties (filtrable par jour)
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  ProviderSubscription<ExplorerRank>? _rankSub;

  @override
  void initState() {
    super.initState();
    // Détecte les montées de rang en temps réel → célébration.
    // Guard : ignore le premier appel (prev == null) pour éviter de déclencher
    // une célébration pour un rang déjà atteint au démarrage.
    _rankSub = ref.listenManual(explorerRankProvider, (prev, next) {
      if (prev == null || prev.index >= next.index) return;
      ref.read(celebrationQueueProvider.notifier).push(
            CelebrationEvent(
              id: 'rank-${next.id}',
              mode: CelebrationMode.badge,
              title: next.name,
              iconEmoji: '💎',
            ),
          );
    });
  }

  @override
  void dispose() {
    _rankSub?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: UrbinkColors.background,
      body: Column(
        children: [
          // En-tête fixe — titre + histogramme + rang
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
    final rank = ref.watch(explorerRankProvider);
    final xp = ref.watch(explorerXpProvider);
    final sessionsCountAsync = ref.watch(profileSessionsCountProvider);

    return Container(
      color: UrbinkColors.surface,
      padding: EdgeInsets.only(
        top: topPadding + UrbinkSpacing.sm,
        bottom: UrbinkSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar + nom
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: UrbinkSpacing.md),
            child: Row(
              children: [
                // Avatar — cercle dark gradient initiales
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF1F2A37), Color(0xFF0F172A)],
                    ),
                    border: Border.all(color: UrbinkColors.border),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x2E0F172A),
                        blurRadius: 10,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'EA',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFF8FAFC),
                        height: 1,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Explorateur Anonyme',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: UrbinkColors.onSurface,
                    letterSpacing: -.3,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: UrbinkSpacing.md),
          // RankCard — tappable → RanksScreen
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: UrbinkSpacing.md),
            child: RankCard(
              rank: rank,
              currentXp: xp,
              onTap: () => Navigator.of(context, rootNavigator: true).push(
                MaterialPageRoute<void>(builder: (_) => const RanksScreen()),
              ),
            ),
          ),
          const SizedBox(height: UrbinkSpacing.sm),
          // Stats row — monuments · sorties · villes
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: UrbinkSpacing.md),
            child: Row(
              children: [
                _StatCard(
                  value: '$xp',
                  label: 'monuments',
                ),
                const SizedBox(width: UrbinkSpacing.sm),
                _StatCard(
                  value: sessionsCountAsync.maybeWhen(
                    data: (n) => '$n',
                    orElse: () => '—',
                  ),
                  label: 'sorties',
                ),
                const SizedBox(width: UrbinkSpacing.sm),
                const _StatCard(value: '1', label: 'ville'),
              ],
            ),
          ),
          const SizedBox(height: UrbinkSpacing.sm),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Carte stat (monuments / sorties / villes)
// ---------------------------------------------------------------------------

class _StatCard extends StatelessWidget {
  const _StatCard({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: UrbinkColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: UrbinkColors.border),
          boxShadow: const [
            BoxShadow(color: Color(0x06000000), blurRadius: 4, offset: Offset(0, 1)),
          ],
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: UrbinkColors.onSurface,
                letterSpacing: -.5,
                height: 1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: UrbinkColors.navInactive,
                letterSpacing: .3,
              ),
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
    final l10n = AppLocalizations.of(context);

    return Expanded(
      child: sessionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(child: Text(l10n.profile_error_loading)),
        data: (pageState) {
          final sessions = pageState.sessions;
          if (sessions.isEmpty) {
            return UrbinkEmptyState(
              emoji: '🗺️',
              title: l10n.profile_no_sessions,
            );
          }
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(
                    UrbinkSpacing.md,
                    UrbinkSpacing.md,
                    UrbinkSpacing.md,
                    UrbinkSpacing.xs,
                  ),
                  itemCount: sessions.length + 1,
                  itemBuilder: (ctx, i) {
                    if (i == 0) {
                      return const Padding(
                        padding: EdgeInsets.only(bottom: 12),
                        child: Text(
                          'Dernières sorties',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: UrbinkColors.onSurface,
                          ),
                        ),
                      );
                    }
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _SortieCard(session: sessions[i - 1]),
                    );
                  },
                ),
              ),
              _PaginationFooter(pageState: pageState),
            ],
          );
        },
      ),
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
// Carte d'une sortie — style design direction
// ---------------------------------------------------------------------------

class _SortieCard extends StatelessWidget {
  const _SortieCard({required this.session});

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

    final now = DateTime.now();
    final isNew = session.sessionStart.year == now.year &&
        session.sessionStart.month == now.month &&
        session.sessionStart.day == now.day;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: UrbinkColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: UrbinkColors.border),
        boxShadow: const [
          BoxShadow(color: Color(0x06000000), blurRadius: 4, offset: Offset(0, 1)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: UrbinkColors.surfaceVariant,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Center(
              child: Text(session.mode.emoji, style: const TextStyle(fontSize: 17)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      date,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: UrbinkColors.onSurface,
                      ),
                    ),
                    if (isNew) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
                        decoration: BoxDecoration(
                          color: UrbinkColors.primary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'NOUVEAU',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: .5,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${session.streetCount} rues · $distance · $duration',
                  style: const TextStyle(fontSize: 11, color: UrbinkColors.navInactive),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: UrbinkColors.navInactive, size: 20),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Helpers de formatage de date en français
// ---------------------------------------------------------------------------

const _shortDays = ['lun', 'mar', 'mer', 'jeu', 'ven', 'sam', 'dim'];
const _shortMonths = ['jan', 'fév', 'mar', 'avr', 'mai', 'juin', 'juil', 'aoû', 'sep', 'oct', 'nov', 'déc'];

String _formatSessionDate(DateTime d) {
  final hh = d.hour.toString().padLeft(2, '0');
  final mm = d.minute.toString().padLeft(2, '0');
  return '${_shortDays[d.weekday - 1]} ${d.day} ${_shortMonths[d.month - 1]} · $hh:$mm';
}
