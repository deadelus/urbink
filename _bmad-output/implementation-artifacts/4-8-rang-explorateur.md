# Implementation Artifact — Story 4.8

## Story
Epic 4 · Story 4.8 — Rang d'Explorateur — refonte ProfilScreen

## ACs implémentés

- [x] Given ProfilScreen / When l'écran s'ouvre / Then une `RankCard` affiche le rang actuel : gemme 72px, nom de la pierre, "{N} monuments découverts", barre XP vers le prochain rang (gradient couleur halo)
- [x] Given le total de monuments débloqués change / When le provider se met à jour / Then la `RankCard` reflète le nouveau total et la progression en temps réel (Riverpod)
- [x] Given ProfilScreen / When l'utilisateur scrolle la `RankPreviewStrip` / Then les 11 rangs sont visibles : rang actuel surligné (border colorée, opacity 1), rangs futurs grisés (opacity 0.5) — implémenté dans `RanksScreen` (timeline) suite à passe design direction
- [x] Given le rang monte (nouveau seuil franchi) / When le listener détecte le changement / Then `CelebrationOverlay` se déclenche (`CelebrationMode.badge`, iconEmoji `💎`, title = nom du rang)
- [x] Given ProfilScreen / When l'utilisateur scrolle / Then le contenu existant (SessionsList) reste accessible sous la `RankCard`

## Tasks / Subtasks

- [x] Créer `lib/features/profile/data/explorer_rank.dart` — `ExplorerRank` model + `kExplorerRanks` (11 rangs, seuils XP, haloColor, initial) + `rankForXp(int xp)`
- [x] Créer `lib/features/profile/providers/explorer_rank_provider.dart` — `explorerXpProvider` + `explorerRankProvider`
- [x] Créer `lib/features/profile/widgets/gem_widget.dart` — `GemWidget` CustomPaint (cercle dark gradient + halo radial + border colorée + initial serif)
- [x] Créer `lib/features/profile/widgets/rank_card.dart` — `RankCard` (surface card radius 16, gem 72px latéral, nom rang, "N monuments", barre XP gradient, "Vers {next.name}")
- [x] Créer `lib/features/profile/widgets/rank_preview_strip.dart` — `RankPreviewStrip` (scroll horizontal 11 gems 48px, current highlighted)
- [x] Mettre à jour `profile_screen.dart` — `ConsumerStatefulWidget` + `_rankSub` listenManual → `celebrationQueueProvider` quand rang monte + `_ProfileHeader` intègre `RankCard` + `RankPreviewStrip`
- [x] Ajouter clés i18n dans `app_fr.arb` + `app_en.arb` : `rank_explorer_label`, `rank_toward_next`, `rank_monuments_count`, `rank_max_reached`, `rank_all_label`, `rank_position`
- [x] Ajouter 7 nouvelles clés i18n pour `RanksScreen` : `ranks_screen_title`, `ranks_screen_subtitle`, `rank_hero_label`, `rank_next_label`, `rank_you_are_here`, `rank_threshold_start`, `rank_threshold_from`
- [x] `flutter gen-l10n`
- [x] Ajouter champ `description` à `ExplorerRank` + textes des 11 rangs
- [x] Créer `lib/features/profile/screens/ranks_screen.dart` — hero gem 120px + timeline 11 rangs
- [x] Mettre à jour `rank_card.dart` — `onTap: VoidCallback?` + label position "RANG D'EXPLORATEUR · X/11"
- [x] Refactoriser `profile_screen.dart` — suppression WeekHistogram + RankPreviewStrip, RankCard.onTap → RanksScreen
- [x] Écrire `test/profile/explorer_rank_test.dart` (unit tests: rankForXp pour chaque seuil + edge cases)
- [x] Écrire `test/profile/rank_card_test.dart` (widget tests: affichage RankCard + RankPreviewStrip)
- [x] `flutter analyze --no-pub` → 0 issue ✅
- [x] `flutter test` → 445/445 tests passent ✅

## Dev Notes

### Architecture
- XP = `badgesStatsProvider.monumentsUnlocked` (monuments distincts débloqués, cross-collections)
- `explorerXpProvider` = `Provider<int>` dérivé de `badgesStatsProvider`
- `explorerRankProvider` = `Provider<ExplorerRank>` dérivé de `explorerXpProvider`
- `badgesStatsProvider` est dans `lib/features/badges/state/badges_provider.dart`

### Les 11 rangs (seuils identiques à gems.jsx)
| Index | Nom       | haloColor | xpMin | xpNext | Initial |
|-------|-----------|-----------|-------|--------|---------|
| 0     | Cristal   | #A8C4D6   | 0     | 5      | C       |
| 1     | Opale     | #D4B5E8   | 5     | 15     | O       |
| 2     | Turquoise | #3FB8B0   | 15    | 35     | T       |
| 3     | Ambre     | #E89B3F   | 35    | 75     | A       |
| 4     | Topaze    | #E8C547   | 75    | 140    | T       |
| 5     | Jade      | #3D9B6E   | 140   | 240    | J       |
| 6     | Saphir    | #3461C9   | 240   | 380    | S       |
| 7     | Rubis     | #C9344B   | 380   | 560    | R       |
| 8     | Émeraude  | #1F8A5B   | 560   | 800    | É       |
| 9     | Diamant   | #C8E0F0   | 800   | 1100   | D       |
| 10    | Légendaire| #D4A642   | 1100  | null   | ★       |

### GemWidget Design
- `CustomPainter` : pas de dépendance externe
- Halo radial (haloColor opacity 0.25) rayon complet
- Corps : cercle dark (gradient radial #2D2D30 → #0F0F0F) r = 70% du widget
- Border : haloColor, strokeWidth 1.5
- Anneau intérieur : haloColor opacity 0.4, strokeWidth 0.7, r = 85% du corps
- Initial : TextPainter, fontSize = 48% du corps, fontWeight w700, color = haloColor

### RankCard Design (light theme, calque Ranks.jsx)
- `Container` : background `UrbinkColors.surface`, borderRadius 16, border `UrbinkColors.border`
- Halo teinté : `Positioned` top-right, radial gradient haloColor 0.08
- Row : `GemWidget(size: 72)` | Column(titre "RANG D'EXPLORATEUR", rang name Crimson-like bold, "N monuments")
- Barre XP : `LinearProgressIndicator` couleur gradient → approximé avec `valueColor: AlwaysStoppedAnimation(haloColor)`, `backgroundColor: UrbinkColors.surfaceVariant`
- Label progression : "Vers {next.name}" · "{progress}/{total}"

### RankPreviewStrip Design
- `SingleChildScrollView` horizontal, padding H16
- Titre "Les 11 rangs" + "{current} sur 11"
- Items : 54px wide, gap 8
  - `Container` borderRadius 14, bg surfaceVariant, border: current → haloColor 1.5px / others → border 1px
  - `GemWidget(size: 42, rank:)`
  - Label 9px, current → haloColor, others → navInactive
  - Opacity: reached → 1.0, future → 0.5

### Listener rang dans ProfileScreen
- `ProfileScreen` → `ConsumerStatefulWidget`
- `ProviderSubscription<ExplorerRank>? _rankSub`
- `initState`: `_rankSub = ref.listenManual(explorerRankProvider, (prev, next) { if (prev == null || prev.index >= next.index) return; ref.read(celebrationQueueProvider.notifier).push(CelebrationEvent(id:'rank-${next.id}', mode:CelebrationMode.badge, title:next.name, iconEmoji:'💎')); });`
- `dispose`: `_rankSub?.close()`

### i18n — 6 nouvelles clés
- `rank_explorer_label` : "RANG D'EXPLORATEUR" / "EXPLORER RANK"
- `rank_toward_next` : "Vers {name}" / "Toward {name}"
- `rank_monuments_count` : "{count} monuments découverts" / "{count} monuments discovered"
- `rank_max_reached` : "Rang maximum atteint" / "Maximum rank reached"
- `rank_all_label` : "Les 11 rangs" / "All 11 ranks"
- `rank_position` : "{current} sur {total}" / "{current} of {total}"

### Providers réutilisés
- `badgesStatsProvider` (badges_provider.dart) → `.monumentsUnlocked`
- `celebrationQueueProvider` (celebration_queue_provider.dart)

## Dev Agent Record

### Debug Log
- `ExplorerRank.xpNeeded` manquait le mot-clé `get` → corrigé en `int? get xpNeeded`
- `rank_max_reached` EN "Maximum rank reached" → majuscule causait un échec de test avec `textContaining('maximum')` → corrigé en lowercase "maximum rank reached"
- `const RadialGradient` dans `_GemPainter` → lint info `prefer_const_constructors` corrigé

### Completion Notes
- `ExplorerRank` : model avec `progressTo()`, `xpInRank()`, `xpNeeded`, `==` / `hashCode` par index
- `kExplorerRanks` : 11 pierres identiques à `gems.jsx` (seuils 0→5→15→35→75→140→240→380→560→800→1100)
- `rankForXp()` : parcourt de la fin, retourne le premier rang où `xp >= xpMin`
- `GemWidget` : `CustomPainter` — halo radial, corps dark gradient, border colorée, anneau intérieur, reflet spéculaire, initial
- `RankCard` : card light theme, gem 72px, nom rang, monuments count, barre XP `LinearProgressIndicator` avec `haloColor`, label "Vers {next.name}" ou "rang maximum atteint"
- `RankPreviewStrip` : scroll horizontal, 11 containers 54px, current highlighted (border + bg), futurs opacity 0.5
- `ProfileScreen` → `ConsumerStatefulWidget` : `_rankSub` listenManual, déclenche `CelebrationEvent(id:'rank-{id}', mode:badge, iconEmoji:'💎')` quand rang monte
- `_ProfileHeader` : WeekHistogram → RankCard → RankPreviewStrip
- 6 clés i18n (fr + en) + gen-l10n
- 37 nouveaux tests (28 unitaires + 9 widget) + 408 existants = 445/445 ✅

## File List

- `_bmad-output/implementation-artifacts/4-8-rang-explorateur.md`
- `urbink/lib/features/profile/data/explorer_rank.dart` (nouveau)
- `urbink/lib/features/profile/providers/explorer_rank_provider.dart` (nouveau)
- `urbink/lib/features/profile/widgets/gem_widget.dart` (nouveau)
- `urbink/lib/features/profile/widgets/rank_card.dart` (nouveau)
- `urbink/lib/features/profile/widgets/rank_preview_strip.dart` (nouveau)
- `urbink/lib/features/profile/screens/ranks_screen.dart` (nouveau)
- `urbink/lib/features/profile/screens/profile_screen.dart` (modifié)
- `urbink/lib/l10n/app_fr.arb` (modifié)
- `urbink/lib/l10n/app_en.arb` (modifié)
- `urbink/lib/l10n/app_localizations.dart` (regénéré)
- `urbink/lib/l10n/app_localizations_fr.dart` (regénéré)
- `urbink/lib/l10n/app_localizations_en.dart` (regénéré)
- `urbink/test/profile/explorer_rank_test.dart` (nouveau)
- `urbink/test/profile/rank_card_test.dart` (nouveau)

## Change Log

- Ajout Story 4.8 — Rang d'Explorateur : RankCard + RankPreviewStrip dans ProfilScreen, 11 pierres précieuses, listener rang → CelebrationOverlay (Date: 2026-05-10)
- Passe UI : RanksScreen (hero 120px + timeline 11 rangs), ExplorerRank.description, RankCard.onTap → RanksScreen, suppression WeekHistogram + RankPreviewStrip du ProfilScreen (Date: 2026-05-10)

## Status

done
