# Story 1.7 — Refactoring navigation v4
## Implementation Artifact

**Branch :** implémentée dans `story-2.10-create-itineraire`
**PR :** #17 (mergée dans develop)

---

## Ce qui a été implémenté

### 1. UrbinkBottomNav v4

**Fichier :** `lib/shared/widgets/urbink_bottom_nav.dart`

- 5 onglets plats : Carte 🗺️ · Parcours 🧭 · Social 👥 · Badges 🏆 · Profil 👤
- `_StartButton` et `_StopButton` supprimés — plus de FAB central surélevé
- `isSessionActive` retiré du contrat du widget
- Indicateur actif : trait 20×2px au-dessus de l'icône, `UrbinkColors.primary` (deep green)
- Tap scale 0.97 — 200ms ease-out via `AnimationController`
- Semantics VoiceOver : "Carte, onglet 1 sur 5" / "Parcours, onglet 2 sur 5" etc.
- `MediaQuery.textScaler` clampé à 1.3× — aucun overflow label
- Safe area `bottomPadding` gérée dans le `Container` height

### 2. Routes renommées

- `Accueil` → `Social`
- `Challenges` → `Badges`
- `Vous` → `Profil`
- Routes `Carte` et `Parcours` inchangées

### 3. Session state découplé de la nav

- `sessionState: SessionState sessionState` conservé en paramètre mais sans effet visuel dans la nav
- L'indicateur de session active est délégué à `SessionStatusBar` (Story 2.10)

---

## Notes

- Story implémentée en même temps que Story 2.10 (SessionStatusBar), qui nécessitait la suppression du FAB pour libérer l'espace carte.
- `TransportModeSelector` également supprimé dans le même PR.
