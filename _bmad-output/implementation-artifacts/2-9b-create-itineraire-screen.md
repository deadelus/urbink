# Story 2.9b : Écran "Créer un itinéraire" + ItineraireBottomSheet + Filtres POI

Status: done

> **Note scope :** Cet artifact couvre des fonctionnalités implémentées au-delà du scope Story 2.9 (placeholder `/create-itineraire`). Il anticipe partiellement Story 5.2 (génération auto) et Story 5.3 (création manuelle), ainsi que l'UI de filtres POI rattachée à l'Epic 6.

## Contexte

La Story 2.9 avait laissé `/create-itineraire` en tant que placeholder. Les itérations suivantes ont construit l'écran complet et ses composants partagés.

---

## Fonctionnalités implémentées

### 1. `_CreateItineraireScreen` (dans `app_router.dart`)

Écran composé en Stack :
- `MapScreen(hideSearchBar: true, showBottomUi: false)` — carte plein écran sans ses propres overlays
- Header row : bouton retour `context.pop()` + barre de recherche placeholder (48px)
- `FilterChipsRow` positionné sous le header
- `ZonesTogglePill` positionné au-dessus du sheet (`bottom: ItineraireBottomSheet.collapsedHeight + md`)
- `ItineraireBottomSheet` en bas

### 2. `ItineraireBottomSheet` (`lib/features/map/widgets/itineraire_bottom_sheet.dart`)

Bottom sheet manuelle (GestureDetector + AnimationController) :
- **PARTIAL** 80px — drag handle + compteur d'étapes
- **OPEN** 65% — contenu complet

**Toggle Manuel / Auto ✨** en tête du contenu expanded.

#### Onglet Manuel (`_ManualContent`)
- Champ nom optionnel (`TextEditingController`)
- `ReorderableListView.builder` + `ReorderableDragStartListener` par tile
- Suppression par tile (icône ×)
- `AnimatedSwitcher` + `SizeTransition` sur CTA "Créer l'itinéraire" (visible ≥ 3 POI)
- `_EmptyState` quand liste vide

Modèle `ItinerairePoi(id, name, subtitle, icon)` + 5 données mock (`_mockPois`).

#### Onglet Auto ✨ (`_AutoGenerateContent` — anticipe Story 5.2)

**Sélecteur durée :** chips 15 / 30 / 45 / 60 min (single select, animated).

**Bandeau stats estimées** : distance · durée · rues estimées (calculé depuis `_StatsRow`).

**Génération :**
1. Tap "Générer l'itinéraire" → loading 1,5 s (simulé, futur → Cloud Function `generate_parcours.go`)
2. Résultat : bandeau amber avec distance réelle + **temps estimé** + nb rues nouvelles
3. Liste `_PoiTileReadOnly` (lecture seule, numéros amber, icône ✨)
4. CTA "Utiliser cet itinéraire" → remplace `_pois` + slide retour vers onglet Manuel
5. Bouton "Regénérer" → relance la génération

Données mock par durée (`_autoGenData`) : 4 résultats (15/30/45/60 min), 2 à 5 POIs chacun.

**Transition entre onglets :** `AnimatedSwitcher` + `SlideTransition` directionnel (`_goingForward`), wrappé dans `ClipRect` pour éviter l'overflow.

### 3. `FilterChipsRow` (`lib/shared/widgets/filter_chips_row.dart`)

Barre de chips POI scrollable horizontale. Présente sur deux écrans :
- `MapScreen` (vue carte principale) → `context.push(AppRoutes.filters)`
- `_CreateItineraireScreen` → même action

- `activeFiltersProvider` (`StateProvider<Set<String>>`) — sélection multi-filtre partagée
- `_FilterChip` : toggle actif/inactif animé
- `_MoreChip` "Voir plus ›" : badge indiquant le nombre de filtres actifs hors `quickPoiFilters`
- `quickPoiFilters` : 5 filtres rapides (monuments, parcs, cafés, musées, restaurants)

### 4. `FiltersScreen` (`lib/features/map/screens/filters_screen.dart`)

Écran complet filtres POI — `GoRoute(path: AppRoutes.filters)`.

- 6 catégories : Culture, Nature, Gastronomie, Sport, Transports, Shopping (26 filtres total)
- Toggle temps réel via `activeFiltersProvider`
- Bandeau "X filtres actifs" animé (`AnimatedSwitcher`)
- Bouton "Réinitialiser" (destructif, visible si filtres actifs)
- `_CategorySection` avec badge de comptage par catégorie

Modèles dans `lib/shared/constants/poi_filters.dart` : `PoiFilter(id, label, icon, categoryId)` + `PoiFilterCategory(id, label, filters)`.

### 5. `MapScreen` — paramètres ajoutés

```dart
const MapScreen({this.hideSearchBar = false, this.showBottomUi = true});
```

- `hideSearchBar: true` → masque la barre de recherche + chips (utilisé par `_CreateItineraireScreen` qui fournit son propre header)
- `showBottomUi: false` → supprime `SortiesBottomSheet` + `ZonesTogglePill` internes (les deux sont repositionnés par l'écran parent)

---

## Fichiers

### Nouveaux fichiers
- `urbink/lib/features/map/widgets/itineraire_bottom_sheet.dart`
- `urbink/lib/shared/widgets/filter_chips_row.dart`
- `urbink/lib/features/map/screens/filters_screen.dart`
- `urbink/lib/shared/constants/poi_filters.dart`
- `urbink/lib/features/map/providers/active_filters_provider.dart`
- `urbink/lib/features/map/providers/bottom_sheet_state_provider.dart`

### Fichiers modifiés
- `urbink/lib/core/router/app_router.dart` — `_CreateItineraireScreen` complet + `AppRoutes.filters` + `GoRoute` FiltersScreen
- `urbink/lib/features/map/screens/map_screen.dart` — params `hideSearchBar`/`showBottomUi` + `FilterChipsRow` remplace ancien `_FilterChipsRow` local

---

## Liens Epic / Story

| Fonctionnalité | Epic / Story d'origine | Statut |
|---|---|---|
| `_CreateItineraireScreen` layout | Story 2.9 (placeholder → implémenté) | ✅ Hors scope 2.9, fait |
| `ItineraireBottomSheet` Manuel | Story 5.3 (création manuelle) | 🟡 UI seule, sans Firestore |
| `ItineraireBottomSheet` Auto | Story 5.2 (génération auto) | 🟡 UI + mock, sans Cloud Function |
| `FilterChipsRow` + `FiltersScreen` | Epic 6 POI | 🟡 UI seule, sans données réelles |

---

## Change Log

| Date | Version | Description | Author |
|------|---------|-------------|--------|
| 2026-04-18 | 1.0 | Implémentation écran Créer un itinéraire + ItineraireBottomSheet (manuel + auto) + FilterChipsRow + FiltersScreen | Claude Sonnet 4.6 |
| 2026-04-19 | 1.1 | Ajout temps estimé dans bandeau résultat auto-gen, stats estimées dans sélecteur durée | Claude Sonnet 4.6 |
