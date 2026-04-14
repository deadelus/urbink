# Story 2.6 : Détection automatique du mode de déplacement

Status: ready-for-dev

## Story

En tant qu'**utilisateur**,
Je veux que l'app détecte automatiquement si je suis à pied, en vélo ou en voiture,
Afin de ne pas avoir à configurer manuellement mon mode avant chaque session.

## Acceptance Criteria

- [ ] **AC1 — Marche** : Given une session active ; When la vitesse GPS est < 7 km/h en moyenne sur 30 secondes ; Then le mode est classifié `walking` — l'icône dans `SessionStatusBar` affiche 🚶 (FR4).

- [ ] **AC2 — Vélo** : Given une session active ; When la vitesse GPS est entre 7 et 30 km/h ; Then le mode est classifié `cycling` — l'icône dans `SessionStatusBar` affiche 🚴 (FR4).

- [ ] **AC3 — Voiture** : Given une session active ; When la vitesse GPS est > 30 km/h ; Then le mode est classifié `driving` — l'icône dans `SessionStatusBar` affiche 🚗 (FR4).

- [ ] **AC4 — Mode dominant en session** : Given un changement de mode détecté en cours de session ; When le mode bascule (ex : marche → voiture dans un bus) ; Then le mode de la session sauvegardée dans Firestore et affiché dans le récapitulatif correspond au mode dominant (= celui avec le plus de ticks GPS) (FR4).

## Tasks / Subtasks

- [ ] **T1 — `TransportModeDetector` (service pur)** (AC: 1, 2, 3)
  - [ ] Créer `urbink/lib/features/sessions/services/transport_mode_detector.dart`
  - [ ] Fenêtre glissante 30 secondes : `List<({double speedMps, DateTime at})> _samples`
  - [ ] `TransportMode update(double speedMps, DateTime at)` — purge les samples > 30s, ajoute le nouveau, classifie la moyenne
  - [ ] `static TransportMode classify(double avgSpeedMps)` — < 1.944 m/s → walking, 1.944–8.333 m/s → cycling, > 8.333 m/s → driving
  - [ ] Ignorer les samples avec `speedMps < 0` (vitesse invalide geolocator)

- [ ] **T2 — Étendre `SessionMetrics`** (AC: 1, 2, 3, 4)
  - [ ] Dans `urbink/lib/features/sessions/models/session_metrics.dart` : ajouter `final TransportMode detectedMode` (default `TransportMode.walking`)
  - [ ] Ajouter `final Map<TransportMode, int> modeTicks` (default `const {}`)
  - [ ] Ajouter getter `TransportMode get dominantMode` — retourne la clé avec la valeur max dans `modeTicks`, fallback `detectedMode`
  - [ ] Mettre à jour `copyWith` pour inclure `detectedMode` et `modeTicks`
  - [ ] `SessionMetrics` importe `transport_mode.dart`

- [ ] **T3 — Intégrer `TransportModeDetector` dans `SessionMetricsNotifier`** (AC: 1, 2, 3, 4)
  - [ ] Dans `urbink/lib/features/sessions/providers/session_metrics_provider.dart`
  - [ ] Instancier `TransportModeDetector _detector` dans le notifier (réinitialisé dans `build()`)
  - [ ] Dans `_onPosition(Position position)` : appeler `_detector.update(position.speed, DateTime.now())`
  - [ ] Mettre à jour `modeTicks` : `{...current.modeTicks, newMode: (current.modeTicks[newMode] ?? 0) + 1}`
  - [ ] Mettre à jour `state.detectedMode = newMode`

- [ ] **T4 — `autoDetectedModeProvider`** (AC: 1, 2, 3)
  - [ ] Dans `urbink/lib/features/sessions/providers/session_metrics_provider.dart` (ou fichier dédié)
  - [ ] `final autoDetectedModeProvider = Provider<TransportMode>((ref) => ref.watch(sessionMetricsProvider).detectedMode);`

- [ ] **T5 — Mettre à jour `SessionStatusBar` placeholder** (AC: 1, 2, 3)
  - [ ] Dans `urbink/lib/shared/widgets/session_status_bar.dart`
  - [ ] Remplacer `const Text('🚶')` par un emoji dynamique lu depuis `autoDetectedModeProvider`
  - [ ] Helper `String _modeEmoji(TransportMode mode)` : walking → 🚶, cycling → 🚴, driving → 🚗
  - [ ] ⚠️ Ne pas faire d'autres changements — Story 2.10 remplace entièrement ce widget

- [ ] **T6 — Mettre à jour `SessionLifecycleNotifier.stopAndSave()`** (AC: 4)
  - [ ] Dans `urbink/lib/features/sessions/providers/session_lifecycle_provider.dart`
  - [ ] Remplacer `final mode = ref.read(transportModeProvider)` par `final mode = metrics.dominantMode`
  - [ ] Supprimer l'import de `transport_mode_provider.dart` si devenu inutilisé dans ce fichier

- [ ] **T7 — Tests unitaires `TransportModeDetector`** (AC: 1, 2, 3, 4)
  - [ ] Créer `urbink/test/features/sessions/services/transport_mode_detector_test.dart`
  - [ ] Test : vitesse 0 m/s → walking
  - [ ] Test : vitesse 1.5 m/s (~5.4 km/h) → walking
  - [ ] Test : vitesse 2.5 m/s (~9 km/h) → cycling
  - [ ] Test : vitesse 10 m/s (36 km/h) → driving
  - [ ] Test : fenêtre glissante — samples > 30s sont purgés
  - [ ] Test : `classify()` aux seuils exacts (1.944 m/s, 8.333 m/s)
  - [ ] Test : sample invalide (speed = -1.0) ignoré

- [ ] **T8 — Tests `SessionMetrics`** (AC: 4)
  - [ ] Dans `urbink/test/features/sessions/models/session_test.dart` : ajouter test `dominantMode` (modeTicks non vide → retourne le mode dominant)
  - [ ] Test : `modeTicks` vide → `dominantMode` fallback sur `detectedMode`

## Dev Notes

### Seuils de vitesse — conversions obligatoires

Les ACs sont en km/h, `Position.speed` de geolocator est en **m/s**. Ne pas confondre.

| Mode | km/h | m/s |
|------|------|-----|
| marche | < 7 | < 1.944 |
| vélo | 7–30 | 1.944–8.333 |
| voiture | > 30 | > 8.333 |

Constantes recommandées dans `TransportModeDetector` :
```dart
static const double _walkMaxMps = 7.0 / 3.6;   // 1.944 m/s
static const double _bikeMaxMps = 30.0 / 3.6;  // 8.333 m/s
static const Duration _windowDuration = Duration(seconds: 30);
```

### `Position.speed` — comportement geolocator

- Type `double`, unité **m/s**
- Vaut `-1.0` si la vitesse n'est pas disponible (GPS non lock, premier fix)
- Vaut `0.0` si l'utilisateur est stationnaire mais avec signal valide
- `speedAccuracy` est aussi disponible mais non requis pour Story 2.6

```dart
// Dans TransportModeDetector.update() :
if (speedMps < 0) return _currentMode; // speed invalide → conserver le mode courant
```

### Architecture `TransportModeDetector` — classe pure (non Riverpod)

```dart
class TransportModeDetector {
  static const double _walkMaxMps = 7.0 / 3.6;
  static const double _bikeMaxMps = 30.0 / 3.6;
  static const Duration _windowDuration = Duration(seconds: 30);

  final List<({double speedMps, DateTime at})> _samples = [];
  TransportMode _currentMode = TransportMode.walking;

  /// Met à jour la fenêtre et retourne le mode classifié.
  TransportMode update(double speedMps, DateTime at) {
    if (speedMps < 0) return _currentMode; // invalide

    // Purge les samples hors fenêtre
    final cutoff = at.subtract(_windowDuration);
    _samples.removeWhere((s) => s.at.isBefore(cutoff));
    _samples.add((speedMps: speedMps, at: at));

    final avg = _samples.map((s) => s.speedMps).reduce((a, b) => a + b) / _samples.length;
    _currentMode = classify(avg);
    return _currentMode;
  }

  static TransportMode classify(double avgSpeedMps) {
    if (avgSpeedMps < _walkMaxMps) return TransportMode.walking;
    if (avgSpeedMps < _bikeMaxMps) return TransportMode.cycling;
    return TransportMode.driving;
  }
}
```

### Extension `SessionMetrics` — champs à ajouter

```dart
// Dans session_metrics.dart
import 'package:urbink/features/sessions/models/transport_mode.dart';

class SessionMetrics {
  // ... champs existants ...
  final TransportMode detectedMode;
  final Map<TransportMode, int> modeTicks;

  const SessionMetrics({
    this.sessionStartTime,
    this.distanceMeters = 0.0,
    this.exploredStreetIds = const {},
    this.detectedMode = TransportMode.walking,
    this.modeTicks = const {},
  });

  TransportMode get dominantMode {
    if (modeTicks.isEmpty) return detectedMode;
    return modeTicks.entries
        .reduce((a, b) => a.value >= b.value ? a : b)
        .key;
  }

  SessionMetrics copyWith({
    DateTime? sessionStartTime,
    double? distanceMeters,
    Set<String>? exploredStreetIds,
    TransportMode? detectedMode,
    Map<TransportMode, int>? modeTicks,
  }) { ... }
}
```

### Intégration dans `SessionMetricsNotifier._onPosition()`

```dart
// Champ notifier (réinitialisé dans build()) :
late TransportModeDetector _detector;

@override
SessionMetrics build() {
  _disposed = false;
  _lastPosition = null;
  _sessionToken++;
  _detector = TransportModeDetector(); // ← nouveau
  ref.onDispose(() => _disposed = true);
  // ... listeners existants inchangés ...
  return const SessionMetrics();
}

Future<void> _onPosition(Position position) async {
  final token = _sessionToken;
  // ... calcul distance existant inchangé ...

  // ← nouveau : auto-détection mode
  final newMode = _detector.update(position.speed, DateTime.now());

  // ... snap to road existant inchangé ...
  if (_disposed || token != _sessionToken) return;

  final current = state;
  final updatedStreets = {...current.exploredStreetIds};
  if (streetId != null) updatedStreets.add(streetId);

  // ← nouveaux champs dans copyWith :
  final updatedTicks = Map<TransportMode, int>.from(current.modeTicks);
  updatedTicks[newMode] = (updatedTicks[newMode] ?? 0) + 1;

  state = current.copyWith(
    distanceMeters: current.distanceMeters + additionalDistance,
    exploredStreetIds: updatedStreets,
    detectedMode: newMode,           // ← nouveau
    modeTicks: updatedTicks,         // ← nouveau
  );
}
```

### Mise à jour `SessionLifecycleNotifier.stopAndSave()`

```dart
// AVANT (Story 2.5) :
final mode = ref.read(transportModeProvider);

// APRÈS (Story 2.6) :
// metrics est déjà passé en paramètre → utiliser son mode dominant
// Pas de ref.read(transportModeProvider) ici.
final completed = current.copyWith(
  sessionEnd: DateTime.now(),
  mode: metrics.dominantMode,  // ← remplace transportModeProvider
  streetIds: metrics.exploredStreetIds.toList(),
  distanceMeters: metrics.distanceMeters,
);
```

Si `transportModeProvider` n'est plus utilisé dans `session_lifecycle_provider.dart`, supprimer son import. **Ne pas supprimer le provider lui-même** — Story 2.10 s'en charge.

### `SessionStatusBar` — mise à jour minimale

```dart
// Ajouter un watch sur autoDetectedModeProvider :
final mode = ref.watch(autoDetectedModeProvider);

// Remplacer const Text('🚶') par :
Text(_modeEmoji(mode), style: const TextStyle(fontSize: 16)),

// Helper :
String _modeEmoji(TransportMode mode) => switch (mode) {
  TransportMode.walking => '🚶',
  TransportMode.cycling => '🚴',
  TransportMode.driving => '🚗',
};
```

### Anti-patterns à éviter

1. **NE PAS** appeler `classify()` sur chaque position brute sans fenêtre glissante — les fluctuations GPS causent des oscillations de mode
2. **NE PAS** modifier `transportModeProvider` ou `TransportModeSelector` — Story 2.10
3. **NE PAS** refactorer `SessionStatusBar` au-delà de l'emoji dynamique — Story 2.10
4. **NE PAS** persister `detectedMode` dans sqflite — seul le `mode` final (dominant) est sauvegardé dans la `Session`
5. **NE PAS** appeler Firestore à chaque changement de mode — seul `stopAndSave()` écrit le mode final
6. **NE PAS** oublier le pattern `_disposed` et le token anti-stale existants dans `_onPosition()`

### Providers inchangés

| Provider | Fichier | Statut |
|---|---|---|
| `transportModeProvider` | `transport_mode_provider.dart` | Inchangé (Story 2.10 le supprime) |
| `gpsPositionStreamProvider` | `gps_tracking_provider.dart` | Inchangé |
| `sessionStateProvider` | `session_state_provider.dart` | Inchangé |
| `sessionLifecycleProvider` | `session_lifecycle_provider.dart` | Modifié : mode → `metrics.dominantMode` |
| `sessionMetricsProvider` | `session_metrics_provider.dart` | Modifié : + détecteur + modeTicks |

### Structure fichiers

```
# Nouveaux
urbink/lib/features/sessions/services/transport_mode_detector.dart
urbink/test/features/sessions/services/transport_mode_detector_test.dart

# Modifiés
urbink/lib/features/sessions/models/session_metrics.dart          — + detectedMode, modeTicks, dominantMode
urbink/lib/features/sessions/providers/session_metrics_provider.dart — + TransportModeDetector intégration
urbink/lib/features/sessions/providers/session_metrics_provider.dart — + autoDetectedModeProvider
urbink/lib/features/sessions/providers/session_lifecycle_provider.dart — mode → metrics.dominantMode
urbink/lib/shared/widgets/session_status_bar.dart                  — emoji dynamique

# Tests modifiés
urbink/test/features/sessions/models/session_test.dart             — + dominantMode tests
```

## Project Structure Notes

- `TransportModeDetector` est un service pur (pas de Riverpod) — suit le pattern `GpsTrackingService`, `SnapToRoadService`
- `autoDetectedModeProvider` dans `session_metrics_provider.dart` (même fichier que `sessionMetricsProvider`) — pas de fichier séparé
- Pas de `providers/transport_mode_detector_provider.dart` — le détecteur est instancié directement dans `SessionMetricsNotifier`

## References

- [Source: _bmad-output/planning-artifacts/epics.md#Story 2.6] — ACs complets
- [Source: _bmad-output/planning-artifacts/prd.md#FR4] — détection automatique mode de déplacement
- [Source: urbink/lib/features/sessions/providers/session_metrics_provider.dart] — pattern `_onPosition`, token anti-stale, `_disposed`
- [Source: urbink/lib/features/sessions/services/gps_tracking_service.dart] — `Position.speed` (m/s), `positionStream()`
- [Source: urbink/lib/features/sessions/models/session_metrics.dart] — structure `SessionMetrics`, `copyWith`
- [Source: urbink/lib/features/sessions/models/transport_mode.dart] — enum `TransportMode` (walking/cycling/driving)
- [Source: urbink/lib/shared/widgets/session_status_bar.dart] — placeholder à mettre à jour minimalement
- [Source: urbink/lib/features/sessions/providers/session_lifecycle_provider.dart] — `stopAndSave()` + `currentUidProvider`
- [Source: _bmad-output/implementation-artifacts/2-5-session-demarrage-arret-reprise.md] — patterns `_disposed`, `_isStarting`, `_isSyncing`, `currentUidProvider`

## Dev Agent Record

### Agent Model Used

Claude Sonnet 4.6

### Debug Log References

### Completion Notes List

### File List

## Change Log

| Date | Version | Description |
|---|---|---|
| 2026-04-14 | 1.0 | Création story — auto-détection mode déplacement via fenêtre glissante 30s |
