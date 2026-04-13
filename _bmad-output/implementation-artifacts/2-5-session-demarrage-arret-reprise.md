# Story 2.5 : Démarrage / arrêt / reprise de session circuit libre + sauvegarde Firestore

Status: done

## Story

En tant qu'**utilisateur**,
Je veux démarrer une session circuit libre depuis l'écran Carte, l'arrêter, et que ma progression soit sauvegardée sans perte,
Afin de ne jamais perdre mes rues explorées même si l'app est fermée brutalement.

## Acceptance Criteria

- [x] **AC1 — Démarrage session** : Given l'onglet Carte ouvert ; When l'utilisateur confirme le démarrage en mode Circuit libre ; Then la session démarre en ≤ 1 seconde — le bottom sheet se ferme, un placeholder `SessionStatusBar` Terra Cotta #A84E2C (44px) apparaît en haut de carte, le bouton Arrêter ■ 52×52px s'affiche bas-droite (FR1).

- [x] **AC2 — Arrêt avec confirmation + sauvegarde Firestore** : Given une session circuit libre en cours ; When l'utilisateur tape le bouton Arrêter ■ ; Then un Dialog de confirmation s'affiche ("Arrêter la session ?") — si confirmé, la session est sauvegardée dans Firestore `/users/{uid}/sessions/{id}` avec `sessionStart`, `sessionEnd`, `mode`, `streetIds[]`, `distanceMeters` — un écran récapitulatif affiche les stats (rues / km / durée) (FR5, FR6).

- [x] **AC3 — Fallback sqflite (offline)** : Given une session sauvegardée avec réseau absent ; When la sauvegarde Firestore échoue ; Then la session est d'abord persistée localement dans sqflite — une re-sync automatique est tentée dès la reconnexion réseau (NFR6, NFR7).

- [x] **AC4 — Crash recovery** : Given l'app fermée brutalement pendant une session active ; When l'utilisateur relance l'app ; Then les données GPS locales sqflite permettent de reconstituer la session — un Dialog "Reprendre la session précédente ?" s'affiche sur l'onglet Carte (FR5).

## Tasks / Subtasks

- [x] **T1 — Modèle `Session`** (AC: 1, 2, 3, 4)
  - [x] Créer `urbink/lib/features/sessions/models/session.dart`
  - [x] Champs : `sessionId`, `userId`, `sessionStart`, `sessionEnd?`, `mode`, `streetIds`, `distanceMeters`
  - [x] Méthodes : `toFirestore()`, `toSqflite()`, `fromFirestore()`, `fromSqflite()`, `copyWith()`

- [x] **T2 — `SessionLocalCache` (sqflite)** (AC: 3, 4)
  - [x] Créer `urbink/lib/features/sessions/services/session_local_cache.dart`
  - [x] Table `local_sessions` : `id TEXT PK`, `user_id TEXT`, `session_start INTEGER`, `session_end INTEGER?`, `mode TEXT`, `street_ids TEXT` (JSON), `distance_meters REAL`, `synced INTEGER`
  - [x] Méthodes : `openDb()`, `insertSession()`, `updateSession()`, `getInterruptedSession()` (WHERE session_end IS NULL AND synced = 0), `markSynced()`, `markCancelled()`

- [x] **T3 — `SessionRepository` (abstract + Firestore impl)** (AC: 2, 3)
  - [x] Créer `urbink/lib/features/sessions/services/session_repository.dart` (abstract class)
  - [x] Créer `urbink/lib/features/sessions/services/firestore_session_repository.dart`
  - [x] `saveSession(Session)` → écrit dans `/users/{uid}/sessions/{sessionId}`
  - [x] `syncPendingSessions(List<Session>)` → re-sync les sessions non-syncées depuis sqflite

- [x] **T4 — `SessionLifecycleNotifier`** (AC: 1, 2, 3, 4)
  - [x] Créer `urbink/lib/features/sessions/providers/session_lifecycle_provider.dart`
  - [x] State : `Session?` (null = aucune session active)
  - [x] `startSession(TransportMode mode)` → génère sessionId (UUID), écrit sqflite, tente Firestore async
  - [x] `stopAndSave(SessionMetrics metrics)` → complète sqflite, tente Firestore, retourne `Session` sauvegardée
  - [x] `resumeFromCrash(Session session)` → restaure state + set sessionStateProvider à active
  - [x] Pattern `_disposed` obligatoire sur tous les appels async
  - [x] Écoute `sessionStateProvider` : idle→active → `startSession()`

- [x] **T5 — Sync réseau au retour de connectivité** (AC: 3)
  - [x] Dans `SessionLifecycleNotifier.build()` : écouter `connectivity_plus` via un Stream
  - [x] À la reconnexion : appeler `repository.syncPendingSessions(await localCache.getUnsyncedSessions())`
  - [x] Pas de queue complexe — simple retry sur reconnexion réseau

- [x] **T6 — `SessionStatusBar` placeholder** (AC: 1)
  - [x] Créer `urbink/lib/shared/widgets/session_status_bar.dart`
  - [x] Barre 44px, fond Terra Cotta `#A84E2C`, position absolute top (après safe area)
  - [x] Affiche : emoji mode (🚶 par défaut) + distance km + durée HH:MM depuis `sessionMetricsProvider`
  - [x] Visible uniquement si `sessionStateProvider != SessionState.idle`
  - [x] **Story 2.10 remplace entièrement ce widget** — ne pas sur-ingéniérer

- [x] **T7 — Refactoring `_ScaffoldWithBottomNav`** (AC: 1, 2)
  - [x] Dans `urbink/lib/core/router/app_router.dart`
  - [x] Déplacer `_StopSessionButton` : `top-right 44px` → `bottom-right 52×52px` (au-dessus bottom nav)
  - [x] Remplacer `ref.read(sessionStateProvider.notifier).state = idle` par le flow Dialog + save
  - [x] Ajouter `SessionStatusBar` dans le Stack du scaffold (dessus de `navigationShell`)
  - [x] `_onStopTapped()` : Dialog → si confirmé → `stopAndSave(metrics)` → navigate → reset state
  - [x] Ajouter la route `/session-summary` dans `GoRouter`

- [x] **T8 — `SessionSummaryScreen`** (AC: 2)
  - [x] Créer `urbink/lib/features/sessions/screens/session_summary_screen.dart`
  - [x] Affiche : N rues, X.X km, durée HH:MM, mode (emoji + label)
  - [x] CTA : "Retour à la carte" → `context.go('/map')`
  - [x] Reçoit `Session` via `state.extra as Session`
  - [x] Hors scope : badge animation, carte miniature tracé (→ Story 3.x)

- [x] **T9 — Crash Recovery Check** (AC: 4)
  - [x] Créer `urbink/lib/features/sessions/services/crash_recovery_service.dart`
  - [x] `checkForInterruptedSession()` → appelle `SessionLocalCache.getInterruptedSession()`
  - [x] Déclencher depuis `MapScreen.initState()` via `addPostFrameCallback`
  - [x] Dialog "Reprendre ?" : Oui → `SessionLifecycleNotifier.resumeFromCrash()` / Non → `markCancelled()`

- [x] **T10 — Ajout couleur Terra Cotta + uuid** (AC: 1)
  - [x] Dans `urbink/lib/shared/constants/colors.dart` : ajouter `static const Color terraCotta = Color(0xFFA84E2C);`
  - [x] Dans `urbink/pubspec.yaml` : ajouter `uuid: ^4.5.1`

- [x] **T11 — Tests unitaires** (AC: 1, 2, 3, 4)
  - [x] `test/features/sessions/models/session_test.dart` : `toFirestore/fromFirestore`, `toSqflite/fromSqflite`
  - [x] `test/features/sessions/services/session_local_cache_test.dart` : insert, update, getInterrupted, markSynced
  - [x] `test/features/sessions/providers/session_lifecycle_provider_test.dart` : start, stop, crash recovery

## Dev Notes

### Providers existants — NE PAS modifier

| Provider | Fichier | Règle |
|---|---|---|
| `sessionStateProvider` | `session_state_provider.dart` | UI state coordinator — reste `StateProvider<SessionState>` |
| `sessionMetricsProvider` | `providers/session_metrics_provider.dart` | Lecture seule dans Story 2.5 — `stopAndSave()` lit ses valeurs mais ne le modifie pas |
| `gpsTrackingProvider` | `providers/gps_tracking_provider.dart` | Inchangé |
| `snapToRoadServiceProvider` | identifié dans session_metrics | Inchangé |

**`sessionMetricsProvider` écoute déjà `sessionStateProvider`** — il se réinitialise automatiquement quand `sessionStateProvider` passe à `idle`. Ne pas dupliquer cette logique.

### Session start flow — coordination providers

Le `SessionLifecycleNotifier` écoute `sessionStateProvider` dans son `build()` :

```dart
ref.listen(sessionStateProvider, (prev, next) {
  if (prev != SessionState.active && next == SessionState.active) {
    final mode = ref.read(transportModeProvider); // Story 2.4 — lecture seule
    _startSession(mode);
  }
  // Note: ne pas écouter le retour à idle ici — stop est explicite via stopAndSave()
});
```

`_startSession(TransportMode mode)` :
1. Génère `sessionId` = `const Uuid().v4()` (package `uuid: ^4.5.1`)
2. Lit `FirebaseAuth.instance.currentUser!.uid`
3. Écrit dans sqflite (`session_end = null, synced = 0`)
4. Tente Firestore async (non-bloquant, failure silencieuse → NFR6)
5. Met `state = Session(sessionId: ..., userId: ..., sessionStart: now, ...)`

### Session stop flow — depuis `_ScaffoldWithBottomNav`

```
[Tap Arrêter ■ bas-droite]
→ showDialog("Arrêter la session ?")
  → Non : fermer dialog (session continue)
  → Oui :
      metrics = ref.read(sessionMetricsProvider)
      mode = ref.read(transportModeProvider)
      session = await ref.read(sessionLifecycleProvider.notifier).stopAndSave(metrics, mode)
      ref.read(sessionStateProvider.notifier).state = SessionState.idle
      if (context.mounted) context.push('/session-summary', extra: session)
```

`stopAndSave(SessionMetrics metrics, TransportMode mode)` :
1. Complète l'objet `Session` avec `sessionEnd = now`, toutes les métriques
2. Met à jour sqflite (`session_end`, `street_ids`, `distance_meters`)
3. Tente Firestore → succès : `markSynced()` / échec : `synced = 0` (sera re-synced)
4. Retourne `Session` complète

### sqflite — schéma table

```sql
CREATE TABLE IF NOT EXISTS local_sessions (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  session_start INTEGER NOT NULL,
  session_end INTEGER,
  mode TEXT NOT NULL DEFAULT 'walk',
  street_ids TEXT NOT NULL DEFAULT '[]',
  distance_meters REAL NOT NULL DEFAULT 0.0,
  synced INTEGER NOT NULL DEFAULT 0
)
```

- `session_start` / `session_end` : `DateTime.millisecondsSinceEpoch`
- `street_ids` : `jsonEncode(streetIds.toList())`
- DB name : `urbink_local.db`, version `1`
- Fournir via `sessionDbProvider` (Riverpod `FutureProvider<Database>`) — singleton

```dart
final sessionDbProvider = FutureProvider<Database>((ref) async {
  return openDatabase('urbink_local.db', version: 1, onCreate: (db, v) {
    return db.execute('CREATE TABLE IF NOT EXISTS local_sessions (...)');
  });
});
```

### Firestore — document session

Path : `/users/{userId}/sessions/{sessionId}`

```
sessionStart: Timestamp.fromDate(session.sessionStart)
sessionEnd:   Timestamp.fromDate(session.sessionEnd!)
mode:         'walk' | 'bike' | 'car'
streetIds:    ['way/12345', 'way/67890', ...]
distanceMeters: 1234.5
createdAt:    FieldValue.serverTimestamp()
```

Règle de sécurité Firestore existante : `request.auth.uid == userId` → chemin `/users/{uid}/sessions/` est autorisé sans modification des règles.

### TransportMode → String Firestore

```dart
extension TransportModeFirestore on TransportMode {
  String get firestoreValue {
    switch (this) {
      case TransportMode.walking: return 'walk';
      case TransportMode.cycling: return 'bike';
      case TransportMode.driving: return 'car';
    }
  }
}
```

Story 2.6 ajoute l'auto-détection. Pour 2.5, `mode` = valeur de `transportModeProvider` au moment du stop.

### Bouton Arrêter — repositionnement dans `app_router.dart`

**Avant (Story 1.3, done)** :
```dart
// Dans _ScaffoldWithBottomNav.build()
Positioned(top: topPadding + 12, right: 16, child: _StopSessionButton(...))
// 44px, cercle rouge, onTap: state = idle
```

**Après (Story 2.5)** :
```dart
// Remplacement du Positioned
Positioned(
  bottom: MediaQuery.of(context).padding.bottom + 56 + 16, // 56 = bottom nav height approx
  right: 16,
  child: _StopSessionButton(onTap: () => _onStopTapped(context, ref)),
)
```

`_StopSessionButton` passe à 52×52px, forme carrée (border-radius 12px), conserve l'icône `Icons.stop_rounded`.

### `SessionStatusBar` — placeholder

```dart
// Dans _ScaffoldWithBottomNav.build(), dans le Stack, après navigationShell
if (sessionState != SessionState.idle)
  Positioned(
    top: MediaQuery.of(context).padding.top,
    left: 0, right: 0,
    child: const SessionStatusBar(),
  ),
```

Widget `SessionStatusBar` (44px de hauteur) :
- Fond : `UrbinkColors.terraCotta` (`#A84E2C`)
- Content : `Row` avec emoji mode + distance km (1 décimale) + durée `HH:MM`
- Lit : `ref.watch(sessionMetricsProvider)`
- Mode emoji : pour Story 2.5, affiche `🚶` par défaut (Story 2.6 gère l'auto-détection)

**Note Story 2.10 :** Ce composant sera entièrement remplacé par la vraie `SessionStatusBar` (auto-detect, design spec complet). Garder minimal — pas d'animations, pas de logic mode.

### Crash Recovery — déclenchement

Dans `MapScreen.initState()` :

```dart
@override
void initState() {
  super.initState();
  _mapController = ref.read(mapControllerProvider);
  _loadStyle();
  _connectivitySub = ...;

  // Vérification crash recovery au premier rendu
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    if (!mounted) return;
    final crashService = ref.read(crashRecoveryServiceProvider);
    final interrupted = await crashService.checkForInterruptedSession();
    if (interrupted != null && mounted) {
      _showCrashRecoveryDialog(interrupted);
    }
  });
}
```

Dialog crash recovery (dans `MapScreen`) :
```
Reprendre la session précédente ?
[session_start.day/month · distance km]
[Abandonner] [Reprendre]
```

- "Reprendre" : `ref.read(sessionLifecycleProvider.notifier).resumeFromCrash(session)` → met sessionStateProvider à active
- "Abandonner" : `ref.read(sessionLifecycleProvider.notifier).cancelInterrupted(session.sessionId)` → markCancelled sqflite

### Pattern `_disposed` — OBLIGATOIRE dans les Notifiers async

Reprendre le pattern de `session_metrics_provider.dart` :

```dart
class SessionLifecycleNotifier extends Notifier<Session?> {
  var _disposed = false;

  @override
  Session? build() {
    _disposed = false;
    ref.onDispose(() => _disposed = true);
    // ...
    return null;
  }

  Future<void> _startSession(TransportMode mode) async {
    // ...
    final result = await repository.saveSession(session);
    if (_disposed) return; // Guard après chaque await
    state = session;
  }
}
```

### Anti-patterns à éviter ABSOLUMENT

1. **NE PAS** appeler `FirebaseFirestore.instance` directement dans un widget → toujours via `SessionRepository`
2. **NE PAS** modifier `sessionMetricsProvider` — il s'auto-reset quand `sessionStateProvider` passe à `idle`
3. **NE PAS** implémenter l'auto-détection de mode → Story 2.6
4. **NE PAS** ajouter la carte miniature dans `SessionSummaryScreen` → Story 3.x
5. **NE PAS** sur-ingéniérer `SessionStatusBar` → Story 2.10 remplace le composant entièrement
6. **NE PAS** modifier `MapStreetOverlay` → fonctionne depuis Story 2.3
7. **NE PAS** implémenter le full bottom sheet "Carte & Sorties" → Story 2.9 (le démarrage via le FAB existant reste fonctionnel)
8. **NE PAS** oublier `if (_disposed) return` après chaque `await` dans les Notifiers

### Route GoRouter — session summary

Ajouter dans `app_router.dart` au niveau du `GoRouter` (pas dans `StatefulShellRoute`) :

```dart
GoRoute(
  path: '/session-summary',
  builder: (context, state) => SessionSummaryScreen(
    session: state.extra as Session,
  ),
),
```

Utiliser `builder` (pas `pageBuilder`) pour une transition slide standard (appropriée pour l'écran récap post-session).

### Dépendances pubspec.yaml à ajouter

```yaml
uuid: ^4.5.1
```

`connectivity_plus` est déjà présent (^6.1.1). `sqflite` est déjà présent (^2.4.1). `firebase_auth` et `cloud_firestore` déjà présents.

### Structure fichiers créés/modifiés

```
# Nouveaux
urbink/lib/features/sessions/models/session.dart
urbink/lib/features/sessions/services/session_local_cache.dart
urbink/lib/features/sessions/services/session_repository.dart
urbink/lib/features/sessions/services/firestore_session_repository.dart
urbink/lib/features/sessions/services/crash_recovery_service.dart
urbink/lib/features/sessions/providers/session_lifecycle_provider.dart
urbink/lib/features/sessions/providers/session_db_provider.dart
urbink/lib/features/sessions/screens/session_summary_screen.dart
urbink/lib/shared/widgets/session_status_bar.dart

# Modifiés
urbink/lib/shared/constants/colors.dart          — ajout terraCotta = Color(0xFFA84E2C)
urbink/lib/core/router/app_router.dart           — stop button repositionné + SessionStatusBar + route /session-summary
urbink/lib/features/map/screens/map_screen.dart  — crash recovery check initState

# Tests
urbink/test/features/sessions/models/session_test.dart
urbink/test/features/sessions/services/session_local_cache_test.dart
urbink/test/features/sessions/providers/session_lifecycle_provider_test.dart

# Config
urbink/pubspec.yaml — uuid: ^4.5.1
```

## Project Structure Notes

- Feature `lib/features/sessions/` existante (Stories 2.2, 2.3, 2.4) — suivre les mêmes conventions
- Créer `lib/features/sessions/screens/` (nouveau sous-dossier) pour `session_summary_screen.dart`
- Providers dans `lib/features/sessions/providers/` — nommés camelCase + suffixe `Provider`
- Services dans `lib/features/sessions/services/` — classes sans suffixe (ex: `SessionLocalCache`, pas `SessionLocalCacheService`)
- Shared widgets dans `lib/shared/widgets/` — `session_status_bar.dart` (snake_case fichier, `SessionStatusBar` classe)

## References

- [Source: _bmad-output/planning-artifacts/epics.md#Story 2.5] — ACs complets
- [Source: _bmad-output/planning-artifacts/architecture.md#Architecture des Données] — Firestore schema `/users/{userId}/sessions`
- [Source: _bmad-output/planning-artifacts/architecture.md#Patterns de Gestion d'Erreurs] — retry x3 backoff Nominatim, Firestore Crashlytics
- [Source: _bmad-output/planning-artifacts/prd.md#FR1, FR5, FR6, NFR6, NFR7]
- [Source: _bmad-output/implementation-artifacts/2-4-session-counter-transport-selector.md] — pattern `_disposed`, `sessionMetricsProvider` patterns
- [Source: urbink/lib/features/sessions/session_state_provider.dart] — `SessionState` enum (idle/active/paused)
- [Source: urbink/lib/features/sessions/providers/session_metrics_provider.dart] — `_disposed` pattern + token anti-stale
- [Source: urbink/lib/core/router/app_router.dart] — scaffold structure, `_StopSessionButton` existant à modifier
- [Source: urbink/lib/features/map/screens/map_screen.dart] — `initState` pattern pour crash recovery

## Dev Agent Record

### Agent Model Used

Claude Sonnet 4.6 (bmad-create-story)

### Debug Log References

- `Session.copyWith` : ajout param `clearSessionEnd: bool = false` — `copyWith(sessionEnd: null)` est ambigu avec "non fourni"
- `connectivityChangesProvider` : extrait en `StreamProvider` injectable pour éviter EventChannel native en test
- `transportModeProvider` : surchargé en test avec `_FakeTransportModeNotifier` (sans SharedPreferences)
- `resumeFromCrash` → listener `sessionStateProvider` déclenche `_startSession` : guard ajouté `&& state == null`
- `SessionLocalCache` : param `dbPath` injectable (`inMemoryDatabasePath`) pour isolation tests sqflite

### Completion Notes List

- 39 tests passent (`flutter test test/features/sessions/`)
- `flutter analyze --no-pub` : 0 erreur

### File List

**Nouveaux :**
- `urbink/lib/features/sessions/models/session.dart`
- `urbink/lib/features/sessions/services/session_local_cache.dart`
- `urbink/lib/features/sessions/services/session_repository.dart`
- `urbink/lib/features/sessions/services/firestore_session_repository.dart`
- `urbink/lib/features/sessions/services/crash_recovery_service.dart`
- `urbink/lib/features/sessions/providers/session_lifecycle_provider.dart`
- `urbink/lib/features/sessions/providers/session_db_provider.dart`
- `urbink/lib/features/sessions/providers/crash_recovery_provider.dart`
- `urbink/lib/features/sessions/screens/session_summary_screen.dart`
- `urbink/lib/shared/widgets/session_status_bar.dart`
- `urbink/test/features/sessions/models/session_test.dart`
- `urbink/test/features/sessions/services/session_local_cache_test.dart`
- `urbink/test/features/sessions/providers/session_lifecycle_provider_test.dart`

**Modifiés :**
- `urbink/lib/features/sessions/models/transport_mode.dart` — `firestoreValue` + `fromFirestoreValue`
- `urbink/lib/shared/constants/colors.dart` — `terraCotta`, `ocre`
- `urbink/lib/core/router/app_router.dart` — stop button repositionné + `SessionStatusBar` + route `/session-summary`
- `urbink/lib/features/map/screens/map_screen.dart` — crash recovery check `initState`
- `urbink/pubspec.yaml` — `uuid: ^4.5.1`, `sqflite_common_ffi: ^2.3.4`

## Change Log

| Date | Version | Description |
|---|---|---|
| 2026-04-13 | 1.0 | Création story — lifecycle session circuit libre + Firestore/sqflite + crash recovery |
| 2026-04-13 | 1.1 | Implémentation complète — 39 tests passent, analyze OK |
