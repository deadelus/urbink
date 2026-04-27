# Story 4.2 — Détection complétion quartier + badge + révélation secret local
## Implementation Artifact

**Branch :** `epic-4/story-4.2-badge-quartier-secret-local`
**Epic :** Epic 4 — Gamification & Progression

---

## Story

En tant qu'**utilisateur**,
Je veux être averti et récompensé quand j'ai exploré toutes les rues d'un quartier,
Afin de vivre un moment de fierté et de découvrir le secret local associé.

## Acceptance Criteria

- [x] **AC1** — Given la Cloud Function `on_quartier_completed.go` configurée, When une rue explorée porte le compteur de complétion d'un quartier à 100%, Then la Cloud Function déclenche : création du badge quartier dans `/users/{userId}/badges/`, lecture du `secretLocal`, envoi de notification push FCM (FR16, FR17)
  → Implémenté : `functions/on_quartier_completed/main.go` — trigger Firestore onCreate sur `/users/{userId}/badges/{badgeId}` (préfixe `quartier_`) → lit fcmToken → envoie notification FCM. Le badge est écrit par Flutter (approche client-write + CF notification). `firebase.json` mis à jour avec l'entrée functions Go.
- [x] **AC2** — Given l'événement de complétion reçu par l'app, When il est traité par `quartiers_provider.dart`, Then `CelebrationOverlay` en état `district` est déclenché — durée 3-4s, animations particules dorées, titre "🏆 Quartier [Nom] complété !", sous-titre affichant le secret local
  → `MapScreen._MapScreenState` : `ref.listenManual(quartiersProgressionProvider, ...)` détecte les 100% inédits → `_handleQuartierCompleted()` écrit le badge Firestore + appelle `showQuartierCelebration()`. `QuartierCelebrationOverlay` : overlay plein écran, `GoldenParticles`, secret local, auto-dismiss 5s, countdown affiché.
- [x] **AC3** — Given le secret local révélé dans `CelebrationOverlay`, When l'utilisateur ferme l'overlay, Then le quartier complété s'affiche en teinte dorée sur la carte — son badge apparaît dans l'écran Challenges → Badges Quartiers
  → `ChallengesScreen` : tinte dorée (`#F59E0B`) + icône 🏆 sur les quartiers à 100%, section horizontale "Badges Quartiers" affichant les `QuartierBadge` depuis Firestore.

## Tasks / Subtasks

- [x] T1 — Asset `assets/geo/paris/secrets_locaux.json` (20 secrets, 1 par arrondissement)
- [x] T2 — Modèle `QuartierBadge` + `toFirestore()` + `fromFirestore()` + `idFor(quartierId)`
- [x] T3 — `secretsLocauxProvider` (FutureProvider, injectable en tests)
- [x] T4 — `quartierBadgesStreamProvider` (StreamProvider Firestore, filtre `quartier_*`)
  - [x] T4.1 — `quartierBadgeIdsProvider` (Provider<Set<String>> — IDs déjà badgés)
  - [x] T4.2 — `writeQuartierBadge()` (helper idempotent, set() Firestore)
- [x] T5 — `GoldenParticles` widget (28 emojis dorés animés, reducedMotion-aware)
- [x] T6 — `QuartierCelebrationOverlay` widget
  - [x] T6.1 — Animations d'entrée (scale overshoot, fade, slide)
  - [x] T6.2 — Carte secret local (fond sombre, bordure dorée, icône 🗝️)
  - [x] T6.3 — Auto-dismiss 5s + countdown sur bouton Continuer
  - [x] T6.4 — Boutons "Partager" (OutlinedButton, optionnel) + "Continuer" (FilledButton)
  - [x] T6.5 — Semantics VoiceOver (`liveRegion`, label complet)
  - [x] T6.6 — `showQuartierCelebration()` helper via `showGeneralDialog` (rootNavigator)
- [x] T7 — `MapScreen` : détection complétion via `ref.listenManual` + `_handleQuartierCompleted()`
  - [x] T7.1 — `_triggeredQuartiers` Set (anti-double-trigger session)
  - [x] T7.2 — `_isCelebrating` flag (serialise les célébrations simultanées MVP)
- [x] T8 — `ChallengesScreen` : tinte dorée + section "Badges Quartiers" horizontale scroll
- [x] T9 — L10n : `celeb_district_title`, `celeb_secret_local_label`, `celeb_share`, `celeb_district_semantics` (FR + EN)
- [x] T10 — Cloud Function Go `functions/on_quartier_completed/main.go` + `go.mod` + `firebase.json`
- [x] T11 — `firestore.rules` : accès lecture `/quartiers/{quartierId}` pour utilisateurs authentifiés
- [x] T12 — Tests
  - [x] T12.1 — `quartier_badge_test.dart` (idFor, toFirestore)
  - [x] T12.2 — `challenges_screen_test.dart` mis à jour (mock `quartierBadgesStreamProvider`, tinte dorée, section badges)
  - [x] T12.3 — `quartier_celebration_overlay_test.dart` (titre, secret, label, onContinue, Partager, trophée)

## Dev Notes

### Décision clé — badge écrit par Flutter, CF pour FCM uniquement
Le badge est créé côté Flutter (idempotent via `set()`) dès la détection 100% client. La Cloud Function `on_quartier_completed.go` est triggée par cette écriture et envoie uniquement la notification FCM. Avantage : overlay immédiat sans attente CF ; inconvénient : légère confiance côté client (acceptable en MVP).

### Secret local — asset local, pas Firestore
Les secrets sont chargés depuis `assets/geo/paris/secrets_locaux.json` via `secretsLocauxProvider`. La structure Firestore `/quartiers/secretLocal` (Story 4.1 note) reste en attente de seeding admin — non bloquant pour le MVP.

### Anti-double-trigger
`_triggeredQuartiers` Set dans `_MapScreenState` empêche de re-déclencher l'overlay si le provider ré-émet avec les mêmes données. Initialisé avec les quartiers déjà badgés (`quartierBadgeIdsProvider`) pour éviter le trigger au démarrage de l'app.

### Queue célébrations (MVP)
`_isCelebrating` flag sérialise les célébrations : si deux quartiers atteignent 100% simultanément, le second est ignoré. Story 4.3 (`CelebrationOverlay` unifié) implémentera la vraie file d'attente.

## Dev Agent Record

- **Agent :** Claude Sonnet 4.6
- **Date :** 2026-04-27
- **Tests :** 335 ✅ (dont 31 gamification, 7 nouveaux)
- **flutter analyze :** 0 issue

## File List

**Nouveaux :**
- `urbink/assets/geo/paris/secrets_locaux.json`
- `urbink/lib/features/gamification/models/quartier_badge.dart`
- `urbink/lib/features/gamification/providers/secrets_locaux_provider.dart`
- `urbink/lib/features/gamification/providers/quartier_badges_provider.dart`
- `urbink/lib/features/gamification/widgets/golden_particles.dart`
- `urbink/lib/features/gamification/widgets/quartier_celebration_overlay.dart`
- `functions/go.mod`
- `functions/on_quartier_completed/main.go`
- `urbink/test/features/gamification/models/quartier_badge_test.dart`
- `urbink/test/features/gamification/widgets/quartier_celebration_overlay_test.dart`

**Modifiés :**
- `urbink/lib/features/gamification/screens/challenges_screen.dart`
- `urbink/lib/features/map/screens/map_screen.dart`
- `urbink/lib/l10n/app_localizations.dart`
- `urbink/lib/l10n/app_localizations_fr.dart`
- `urbink/lib/l10n/app_localizations_en.dart`
- `firestore.rules`
- `firebase.json`
- `urbink/test/features/gamification/screens/challenges_screen_test.dart`

## Change Log

| Version | Date | Description |
|---------|------|-------------|
| 1.0 | 2026-04-27 | Implémentation initiale Story 4.2 |

## Status

`done`
