# Implémentation Flutter — Collections de Monuments (Urbink)

## Contexte
Tu travailles sur l'app Urbink (Flutter, iOS-first, Material 3 thémé). Référence design : `URBINK_DEVELOPER_HANDOFF.md` + prototype HTML `Urbink App.html` + `js/Screens.jsx` (BadgesScreen).

Objectif : remplacer la grille plate de 12 monuments dans l'onglet Badges par un système de **collections thématiques**. Chaque collection regroupe des monuments par catégorie ; un même monument peut figurer dans plusieurs collections (ex : Notre-Dame est dans "Les Indispensables" et "Lumières & Cathédrales").

## 1. Modèle de données

Crée `lib/features/badges/data/collection_model.dart` :

```dart
class MonumentCollection {
  final String id;            // 'indispensables', 'lumieres-cathedrales', ...
  final Map<String,String> name;   // i18n {fr,en,es,pt,ja}
  final Map<String,String> sub;    // sous-titre i18n
  final String icon;          // emoji représentatif
  final Color color;          // couleur d'accent (hex)
  final List<Monument> monuments;

  CollectionStats stats() {
    final unlocked = monuments.where((m) => !m.locked).length;
    return CollectionStats(
      total: monuments.length,
      unlocked: unlocked,
      pct: (unlocked / monuments.length * 100).round(),
    );
  }
}

class Monument {
  final String id;            // slug unique global (ex: 'notre-dame')
  final String emoji;
  final Map<String,String> name;
  final bool locked;
  final LatLng? location;     // pour rayon de déblocage 100m
  final String? wikipediaUrl;
  final String? description;
}

class CollectionStats {
  final int total, unlocked, pct;
}
```

## 2. Données seed (ville Paris)

Crée `lib/features/badges/data/paris_collections.dart` avec **8 collections** :

1. **`indispensables`** — "Les Indispensables" (couleur `#F59E0B`, icône ⭐) — Tour Eiffel 🗼, Notre-Dame 🏰, Louvre 🏛️, Sacré-Cœur ⛪, Panthéon 🏛️, Arc de Triomphe 🌉
2. **`lumieres-cathedrales`** — "Lumières & Cathédrales" (`#7C3AED`, ⛪) — Notre-Dame, Sacré-Cœur, La Madeleine, Saint-Sulpice, Saint-Eustache, Sainte-Chapelle, Val-de-Grâce
3. **`ponts-berges`** — "Ponts & Berges" (`#0891B2`, 🌉) — Pont Neuf, Pont Alexandre III, Pont d'Iéna, Pont des Arts, Pont Mirabeau, Pont de Bir-Hakeim
4. **`royal-imperial`** — "Royal & Impérial" (`#B45309`, 👑) — Versailles, Louvre, Palais-Royal, Conciergerie, Hôtel des Invalides, Château de Vincennes
5. **`scenes-spectacles`** — "Scènes & Spectacles" (`#BE185D`, 🎭) — Opéra Garnier, Opéra Bastille, Comédie Française, Théâtre du Châtelet, Grand Rex, Olympia
6. **`paris-moderne`** — "Paris Moderne" (`#475569`, 🏗️) — Centre Pompidou, Tour Montparnasse, La Défense, Fondation Louis Vuitton, Philharmonie, Pyramide du Louvre
7. **`places-jardins`** — "Places & Jardins" (`#256F4C`, 🌳) — Place des Vosges, Place de la Concorde, Place Vendôme, Jardin du Luxembourg, Tuileries, Palais-Royal (jardin), Parc Monceau
8. **`tresors-caches`** — "Trésors Cachés" (`#92400E`, 🗝️) — Musée Cluny, Hôtel de Sully, Saint-Étienne-du-Mont, Maison de Balzac, Musée Carnavalet, Pavillon de l'Arsenal

> **Important** : les monuments sont définis dans une table maître globale (`paris_monuments.dart`), et chaque collection référence des `Monument.id`. Cela évite la duplication de coordonnées GPS et rend cohérent l'état "locked" entre collections.

## 3. Architecture

```
lib/features/badges/
├── data/
│   ├── collection_model.dart
│   ├── paris_monuments.dart       // table maître monuments
│   ├── paris_collections.dart     // 8 collections référençant les monuments
│   └── collections_repository.dart // charge selon cityId
├── state/
│   └── badges_provider.dart       // Riverpod : collections, unlocked state
└── screens/
    ├── badges_screen.dart         // onglet, liste collections
    ├── collection_detail_screen.dart // overlay détail
    └── widgets/
        ├── collection_card.dart
        ├── monument_tile.dart
        └── collection_header.dart
```

## 4. Écran principal — BadgesScreen

Adapte la version actuelle (sous-écran "Monuments") :

- **Header** : titre "Badges" (Crimson Pro 26sp 700) + `CityHeaderBar` aligné à droite + sous-titre "{totalUnlocked}/{totalMonuments} · {N} collections complètes — {ville}"
- **Stats banner** (3 métriques, fond `accentAlpha10`, bordure `accentAlpha22`) :
  - Monuments débloqués (count distinct)
  - Collections complètes (count où pct=100)
  - Quartiers complétés
  - Style : Crimson Pro 26sp accent + label Inter 11sp muted
- **Tab toggle** "🏛️ Monuments" / "🏘️ Quartiers" (inchangé)
- **Liste collections** (scroll vertical, padding 0 16) :
  - Chaque card 14×14 padding, radius 18, border `border`, shadow légère
  - **Stripe gauche 4px de la couleur de la collection** (absolute, top:0, bottom:0, left:0)
  - Row : icône 48×48 radius 14 fond `color+'18'` + titre Crimson Pro 16sp 700 + 🏆 si complète + sous-titre 11sp muted + chevron `›`
  - **Mini-grille d'aperçu** : 6 premiers monuments en tuiles 32×32 radius 8 ; verrouillés en grayscale opacity .4
  - **Barre de progression** : track 5px `surfVar`, fill couleur collection ; à droite "{unlocked}/{total}" en couleur collection 11sp 700

## 5. Écran détail — CollectionDetailScreen

Overlay plein écran (animation fadeIn 200ms), z-index > BottomNav.

### Layout
```
[Header coloré — gradient 135° de col.color → col.color+'dd']
  Cercles décoratifs blancs (rgba .08, .05) en absolute, pointerEvents: none
  Bouton "← Retour" blanc en haut
  Row: icône 64×64 radius 18 (fond rgba(255,255,255,.22), border 1.5 rgba(255,255,255,.4))
       + titre Crimson Pro 22 + sous-titre 12 (rgba .85)
  Barre progression: track rgba(255,255,255,.2), fill blanc + label "X/Y · Z%"

[Body — fond bg, scrollable]
  Si pct=100 → Banner "🏆 Collection complète !" (fond accentAlpha10)
  Grille 3 colonnes, gap 10, padding 16:
    Card 16 radius, border (highlighted color+'40' si débloqué, sinon border)
    Checkmark badge couleur collection top-right -4 pour débloqués
    Emoji 30sp (grayscale + opacity .4 si verrouillé)
    Nom 10sp 600 (muted si verrouillé)
    Icône 🔒 si verrouillé
    minHeight 96
```

## 6. Logique de déblocage

Dans `collections_repository.dart` :
```dart
// Quand le GPS détecte l'utilisateur dans un rayon de 100m d'un monument :
Future<List<Monument>> checkUnlockNearby(LatLng userPos) async {
  final newlyUnlocked = <Monument>[];
  for (final mon in allMonuments) {
    if (mon.locked && Geolocator.distanceBetween(
      userPos.lat, userPos.lng,
      mon.location.lat, mon.location.lng,
    ) < 100) {
      mon.locked = false;
      newlyUnlocked.add(mon);
      // Persister dans Hive/SQLite
    }
  }
  return newlyUnlocked;
}
```

→ Pour chaque monument débloqué : déclencher `CelebrationOverlay` (cf. handoff §4.11), avec en bonus un check : **"vous avez complété la collection {X} !"** si le déblocage finalise une collection.

## 7. Internationalisation

Ajoute aux `TRANSLATIONS` dans `i18n.dart` :

| Clé | FR | EN | ES | PT | JA |
|---|---|---|---|---|---|
| `collections_intro` | Explorez Paris par thématique | Explore Paris by theme | Explora París por temática | Explore Paris por temática | パリをテーマで探索 |
| `collection_complete` | Collection complète ! | Collection complete! | ¡Colección completa! | Coleção completa! | コレクション達成！ |
| `collection_complete_sub` | Vous avez débloqué tous les monuments | All monuments unlocked | Todos los monumentos desbloqueados | Todos os monumentos desbloqueados | 全モニュメント解除済み |
| `stats_collections` | Collections | Collections | Colecciones | Coleções | コレクション |

Et chaque `name` + `sub` de collection doit avoir 5 traductions.

## 8. Persistance

Hive box `unlocked_monuments_{cityId}` :
```dart
@HiveType(typeId: 5)
class UnlockedMonument {
  @HiveField(0) String monumentId;
  @HiveField(1) DateTime unlockedAt;
  @HiveField(2) double? distanceMeters;
}
```

Le state "locked" d'un monument se calcule à la volée : `monument.id NOT IN unlockedBox.keys`.

## 9. Tests

- `test/badges/collection_stats_test.dart` : vérifier que `pct` se calcule correctement (4/6 = 67%)
- `test/badges/unlock_test.dart` : déclencher unlock à 99m → ok ; à 101m → no-op
- `test/badges/i18n_test.dart` : vérifier que toutes les clés existent dans les 5 langues
- Widget test : ouvrir BadgesScreen → tap sur première collection → vérifier overlay visible avec bon titre

## 10. Accessibilité

- Cards collections : Semantics label "Collection {nom}, {unlocked} sur {total} monuments débloqués, {pct}%"
- Tuiles monuments : Semantics label "{nom}, {débloqué|verrouillé}"
- Couleurs collection vs blanc dans header : vérifier contraste WCAG 4.5:1 ; sinon utiliser overlay sombre

## 11. Critères d'acceptation

- [ ] 8 collections affichées dans l'onglet "Monuments"
- [ ] Tap sur card → overlay plein écran (fadeIn 200ms)
- [ ] Header gradient + barre progression dynamique
- [ ] Grille 3 colonnes des monuments avec états locked/unlocked
- [ ] Stats banner : 3 métriques agrégées correctes (count distinct sur monuments)
- [ ] Bouton retour fonctionnel (pas de fermeture par swipe back ; tap ← uniquement pour cohérence iOS)
- [ ] Trigger unlock GPS dans rayon 100m → CelebrationOverlay + state persisté
- [ ] i18n complet 5 langues
- [ ] Reduced motion : fadeIn 150ms, pas d'animation barre

## Hors scope (V2)
- Filtres/tri des collections (par % progression, par nom, par couleur)
- Recherche dans les monuments
- Partage de collection complète
- Génération automatique d'itinéraires "Compléter la collection X"
- Collections par ville autre que Paris (architecture prête, données à seed plus tard)

---

Lis d'abord `URBINK_DEVELOPER_HANDOFF.md` (section §4.4 BadgesScreen) puis `js/Screens.jsx` (constante `COLLECTIONS`) pour le détail exact des données seed et de la palette. Respecte strictement les design tokens (`lib/shared/constants/colors.dart`, `typography.dart`, `spacing.dart`).
