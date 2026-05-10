# Implémentation Flutter — Monument Detail Bottom Sheet (Urbink)

## Contexte
Tu travailles sur l'app Urbink (Flutter, iOS-first, Material 3 thémé). Référence design : `URBINK_DEVELOPER_HANDOFF.md` + prototype HTML `Urbink App.html` + `js/Screens.jsx` (BadgesScreen → CollectionDetail → onTap monument).

Objectif : Ajouter une **bottom sheet de détail** qui s'ouvre au tap sur un monument (depuis la grille d'une collection ou depuis l'onglet Monuments). Elle affiche une **mini-carte** centrée sur le monument, sa fiche (époque, arrondissement, description), son statut (visité / à débloquer) et des actions (Partager, Voir sur la carte).

Pré-requis : la feature "Collections de Monuments" doit déjà être implémentée (cf. `CLAUDE_CODE_PROMPT_Collections.md`).

---

## 1. Modèle de données — enrichissement

Étends `Monument` (`lib/features/badges/data/collection_model.dart`) :

```dart
class Monument {
  final String id;
  final String emoji;
  final Map<String,String> name;
  final bool locked;
  final LatLng location;            // GPS réel (déjà existant pour le rayon 100m)
  final String arrondissement;      // '1er', '4e', '78' (Versailles), '92' (La Défense)
  final String era;                 // '1889', 'XIIᵉ', 'XVIIᵉ'…
  final Map<String,String> description; // i18n {fr,en,es,pt,ja}
  final DateTime? visitedAt;        // null si verrouillé
  final String? wikipediaUrl;
  final String? photoUrl;           // V2 — pour l'instant on garde l'emoji
}
```

## 2. Données seed (Paris) — table d'info à compléter

Pour chacun des ~45 monuments listés dans `paris_monuments.dart`, renseigner les champs suivants. Référence exacte : voir `MONUMENT_INFO` dans `js/Screens.jsx`.

Exemples (extrait) :

| Monument | arr | era | description (fr) |
|---|---|---|---|
| Tour Eiffel | 7e | 1889 | Le symbole de Paris, 330m de fer forgé. Construite pour l'Expo Universelle. |
| Notre-Dame | 4e | XIIᵉ | Cathédrale gothique sur l'Île de la Cité. Chef-d'œuvre du Moyen Âge. |
| Louvre | 1er | XIIᵉ | Ancien palais royal, plus grand musée du monde. La Joconde y réside. |
| Sacré-Cœur | 18e | 1914 | Basilique blanche de Montmartre, perchée à 130m. Vue à 360° sur Paris. |
| Panthéon | 5e | 1790 | Mausolée des grands hommes : Voltaire, Hugo, Curie, Zola y reposent. |
| Arc de Triomphe | 8e | 1836 | À la gloire des armées napoléoniennes. Tombe du Soldat inconnu. |
| Sainte-Chapelle | 1er | 1248 | Joyau gothique. 1113 vitraux narrant la Bible, 15m de haut. |
| Pont Alexandre III | 8e | 1900 | Pont Belle Époque le plus orné. Style Beaux-Arts, statues dorées. |
| Versailles | 78 | 1682 | Château royal de Louis XIV. Galerie des Glaces, jardins de Le Nôtre. |
| Centre Pompidou | 4e | 1977 | Architecture inside-out. Musée d'art moderne, bibliothèque. |
| Place des Vosges | 4e | 1612 | Plus ancienne place planifiée de Paris. Briques rouges, arcades. |
| Jardin du Luxembourg | 6e | 1612 | Jardin de Marie de Médicis. Bassin, ruches, palais du Sénat. |

(Liste complète : 45 entrées dans `js/Screens.jsx → MONUMENT_INFO`).

Coordonnées GPS réelles à récupérer via Wikipedia/OSM Nominatim — un script de seed peut générer le fichier Dart depuis un CSV.

---

## 3. Architecture

```
lib/features/badges/
├── screens/
│   ├── collection_detail_screen.dart    // déclenche la sheet
│   └── monument_detail_sheet.dart       // ← NOUVEAU
└── widgets/
    ├── mini_map.dart                     // ← NOUVEAU
    ├── monument_status_card.dart         // ← NOUVEAU
    └── monument_actions.dart             // ← NOUVEAU
```

Trigger : `showModalBottomSheet` avec `useSafeArea: true`, `isScrollControlled: true`, `backgroundColor: Colors.transparent` (pour gérer le radius custom et l'animation).

---

## 4. UI — Bottom Sheet

### Structure

```
[Backdrop semi-transparent rgba(15,23,42,.5) — fade 200ms]
[Sheet — slide up 250ms cubic-bezier(.4,0,.2,1)]
  ┌───────────────────────────────────────┐
  │       ━━━━ (drag handle 40×4)         │
  │                                       │
  │  ┌─────────────────────────────────┐  │
  │  │  [arr.]              [Visité ✓] │  │
  │  │                                 │  │  ← Mini-map 140px
  │  │            📍 (pin emoji)       │  │     fond #E8E4D8
  │  │                                 │  │     grid + Seine + parcs
  │  └─────────────────────────────────┘  │
  │                                       │
  │  [emoji 30] Notre-Dame                │
  │            🏰 Indispensables · XIIᵉ    │  ← Header
  │                              [×]      │
  │                                       │
  │  Cathédrale gothique sur l'Île de la  │  ← Description
  │  Cité. Chef-d'œuvre du Moyen Âge.     │     13sp lh 1.5
  │                                       │
  │  ┌─────────────────────────────────┐  │
  │  │ 🏆  Badge débloqué              │  │  ← Status card
  │  │     Visité lors d'une sortie    │  │
  │  └─────────────────────────────────┘  │
  │                                       │
  │  [Partager]  [🧭 Voir sur la carte]   │  ← Actions
  └───────────────────────────────────────┘
```

### Dimensions & tokens

- Sheet : `borderRadius: 24px 24px 0 0`, `maxHeight: 78%` du viewport, fond `surface`
- Shadow : `0 -8px 30px rgba(0,0,0,.25)`
- Padding sheet : `10px 0 24px` (drag handle a sa propre marge)
- Mini-map : margin `12px 16px 0`, height `140`, radius `16`, border `1px ${border}`, fond `#E8E4D8`
- Header monument : padding `14px 16px 8px`, gap `12`
- Description : padding `4px 16px 14px`, font 13sp `text` lineHeight 1.5
- Status card : margin `0 16px 14px`, padding `12px 14px`, radius `14`
- Actions : padding `0 16px`, gap `8`, height `48`

---

## 5. Mini-Map widget

`lib/features/badges/widgets/mini_map.dart` — version stylisée (V1) ou `flutter_map` allégé (V1.5).

### V1 — SVG/CustomPainter stylisée

Version simple, déterministe, sans appel réseau. Reproduit le rendu du prototype :

```dart
class MiniMap extends StatelessWidget {
  final double normalizedX, normalizedY;  // 0-1 du monument
  final String emoji;
  final Color accentColor;
  final bool unlocked;

  // Painter qui dessine :
  // - Fond #E8E4D8
  // - Grid streets : lignes h/v stroke #CEC9BD width 0.5 opacity 0.7
  //   (h: y=30,55,80,105 / v: x=30,70,110,150,180)
  // - Seine : path quadratique #C8DFF0 strokeWidth 9 strokeLinecap round
  //   "M-5,75 Q40,82 90,72 Q140,60 200,80"
  // - Parcs : 2 rects #C5D5A8 opacity 0.7 radius 3
  //   (x=20 y=92 32×22) + (x=140 y=20 28×20)
  // - Pin :
  //     - Si unlocked : 2 halos circle r=22 r=14 fill accentColor opacity .15/.25
  //     - Cercle central r=9 fill (locked? #94A3B8 : accentColor) stroke white 2.5
  //     - Emoji centré 9sp
  // Overlays :
  //   - Top-left pill arrondissement (rgba 255,255,255,.92, 10sp 600 muted)
  //   - Top-right si unlocked : pill accentColor "Visité ✓" 10sp 700 white
}
```

### V1.5 — flutter_map réel

Si on veut une vraie carte tile, utiliser `flutter_map` avec :
- Tile URL : `https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png`
- Center : `monument.location`, zoom 15
- Marker : `Marker` custom widget avec emoji + halo couleur collection
- Désactiver toutes les interactions (`InteractiveFlag.none`) — la sheet n'est pas une carte explorable
- Tap sur la mini-map → ferme la sheet et navigue vers `/carte` recentrée sur le monument

Pour le MVP : commencer par V1 (déterministe, offline, pas de tiles à charger), passer en V1.5 quand le tracking GPS de la carte principale est en place.

---

## 6. Header monument

```dart
Row(
  children: [
    Container(
      width: 54, height: 54,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: monument.locked ? T.surfVar : collection.color.withOpacity(.094),
      ),
      child: Center(child: Text(monument.emoji, style: TextStyle(fontSize: 30,
        color: monument.locked ? Colors.grey : null,  // grayscale(1) si verrouillé
      ))),
    ),
    SizedBox(width: 12),
    Expanded(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(monument.name[lang],
          style: TextStyle(fontFamily: 'Crimson Pro', fontSize: 20,
            fontWeight: FontWeight.w700, height: 1.15,
            letterSpacing: -.3, color: T.text)),
        SizedBox(height: 4),
        Wrap(spacing: 6, children: [
          // Pill collection (couleur d'accent)
          Container(
            decoration: BoxDecoration(
              color: collection.color.withOpacity(.094),
              borderRadius: BorderRadius.circular(6),
            ),
            padding: EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            child: Text('${collection.icon} ${collection.name[lang]}',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                color: collection.color)),
          ),
          Text('· ${monument.era}',
            style: TextStyle(fontSize: 11, color: T.muted)),
        ]),
      ]),
    ),
    // Bouton fermer
    GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        width: 30, height: 30,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: T.surfVar,
        ),
        child: Center(child: Text('×',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: T.muted))),
      ),
    ),
  ],
)
```

---

## 7. Status Card

État dynamique selon `monument.locked` :

| État | Background | Border | Icon | Title | Sub |
|---|---|---|---|---|---|
| **Verrouillé** | `surfVar` | `border` | 🔒 | "Pas encore visité" (muted) | "Approchez-vous à moins de 100m pour débloquer" |
| **Débloqué** | `collection.color × .06` | `collection.color × .19` | 🏆 | "Badge débloqué" (collection.color) | "Visité le {visitedAt formaté}" |

Si `visitedAt` est connu, afficher la date relative ("il y a 3 jours") via `package:timeago` configuré en français.

---

## 8. Actions row

Deux boutons côte à côte, height 48, radius 14 :

```dart
Row(children: [
  // Bouton Partager (outline, flex 1)
  Expanded(
    child: OutlinedButton.icon(
      onPressed: () => _shareMonument(monument),
      icon: Icon(Icons.share_outlined, size: 16),
      label: Text(t(lang, 'btn_share'),
        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: T.border, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        foregroundColor: T.text,
      ),
    ),
  ),
  SizedBox(width: 8),
  // Bouton Voir sur la carte (filled, flex 2, couleur collection)
  Expanded(flex: 2,
    child: FilledButton.icon(
      onPressed: () {
        Navigator.pop(context); // ferme sheet
        Navigator.pop(context); // ferme overlay collection
        ref.read(navigationProvider.notifier).goTo('carte',
          centerOn: monument.location, focusMonument: monument.id);
      },
      icon: Text('🧭', style: TextStyle(fontSize: 14)),
      label: Text(t(lang, 'btn_show_on_map'),
        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      style: FilledButton.styleFrom(
        backgroundColor: collection.color,
        elevation: 4,
        shadowColor: collection.color.withOpacity(.33),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
  ),
]),
```

### Action "Partager"

Utiliser `share_plus` :
```dart
Share.share(
  '${monument.name[lang]} · ${monument.era} · ${monument.arrondissement} arr.\n'
  '${monument.description[lang]}\n\n'
  'Découvert avec Urbink — https://urbink.app',
);
```

### Action "Voir sur la carte"

Ferme la sheet + l'overlay collection, navigue vers l'onglet `Carte`, recentre flutter_map sur `monument.location` (zoom 17), et déclenche un highlight animé sur le pin (pulse 2× couleur collection).

---

## 9. Internationalisation

Ajouts à `TRANSLATIONS` (i18n.dart) :

| Clé | FR | EN | ES | PT | JA |
|---|---|---|---|---|---|
| `btn_share` | Partager | Share | Compartir | Compartilhar | シェア |
| `btn_show_on_map` | Voir sur la carte | Show on map | Ver en el mapa | Ver no mapa | 地図で見る |
| `mon_visited` | Badge débloqué | Badge unlocked | Insignia desbloqueada | Emblema desbloqueado | バッジ獲得 |
| `mon_visited_sub` | Visité {when} | Visited {when} | Visitado {when} | Visitado {when} | {when}に訪問 |
| `mon_locked` | Pas encore visité | Not visited yet | Aún no visitado | Ainda não visitado | 未訪問 |
| `mon_locked_sub` | Approchez-vous à moins de 100m pour débloquer | Get within 100m to unlock | Acércate a menos de 100m | Aproxime-se a menos de 100m | 100m以内に接近で解除 |
| `mon_arr` | {n} arr. | {n} arr. | dist. {n} | {n} arr. | 第{n}区 |

Et chaque monument doit avoir 5 traductions de `name` + `description`.

---

## 10. Animations & accessibilité

### Animations
- Entrée : sheet `slideUp 250ms cubic-bezier(.4,0,.2,1)` + backdrop `fadeIn 200ms`
- Sortie : reverse, durée 200ms
- Mini-map : pin halo pulse 2s ease-in-out infinite (`opacity .15 ↔ .35`) si débloqué
- Reduced motion : pas de pulse, fade 150ms uniquement

### Gestes
- Drag down sur la sheet → fermer (seuil 80px ou velocity > 800)
- Tap backdrop → fermer
- Swipe back iOS → fermer
- Bouton × → fermer

### Accessibilité
- Sheet : `Semantics(label: 'Détail du monument {nom}', container: true)`
- Mini-map : `Semantics(label: 'Carte centrée sur {nom}, dans le {arr} arrondissement', image: true)`
- Status card : annonce VoiceOver de l'état lors de l'ouverture (`SemanticsService.announce`)
- Boutons : `tooltip` + label clair
- Focus trap dans la sheet (TalkBack/VoiceOver ne sort pas vers l'arrière-plan)

---

## 11. Tests

```dart
// test/badges/monument_sheet_test.dart
testWidgets('Tap monument card opens sheet', (tester) async { ... });
testWidgets('Locked monument shows lock state', (tester) async { ... });
testWidgets('Unlocked monument shows visited state with date', (tester) async { ... });
testWidgets('Tap "Voir sur la carte" closes sheet and navigates', (tester) async { ... });
testWidgets('Tap backdrop closes sheet', (tester) async { ... });
testWidgets('Drag down beyond threshold closes sheet', (tester) async { ... });
testWidgets('Mini-map renders pin at correct normalized position', (tester) async { ... });
testWidgets('Reduced motion: no pulse animation', (tester) async { ... });

// test/badges/i18n_test.dart
test('All monument-detail keys exist in 5 languages', ...);
```

---

## 12. Critères d'acceptation

- [ ] Tap sur tuile monument (depuis grille collection ou onglet Monuments) → bottom sheet remonte
- [ ] Mini-map affiche pin à la position normalisée du monument, halo couleur collection si débloqué
- [ ] Pill arrondissement top-left + (si visité) badge "Visité ✓" top-right couleur collection
- [ ] Header : emoji 54×54 + nom Crimson Pro 20 + pill collection couleur + époque
- [ ] Description complète, lineHeight 1.5
- [ ] Status card adapte fond/icône/copy selon `monument.locked`
- [ ] Bouton Partager appelle `share_plus` avec texte formaté
- [ ] Bouton "Voir sur la carte" ferme la sheet + l'overlay collection + navigue vers `/carte` recentré
- [ ] Drag handle, tap backdrop, swipe-down ferment la sheet
- [ ] Sheet maxHeight 78% viewport, scrollable interne si contenu déborde
- [ ] Couleur de la collection propage à : pill collection, halo pin, badge "Visité", border tuile, status card, bouton CTA, ombre du CTA
- [ ] i18n complet 5 langues
- [ ] VoiceOver lit le contenu dans l'ordre logique : nom → collection → époque → description → statut → actions
- [ ] Reduced motion respecté

---

## Hors scope (V2)

- Photos réelles des monuments (Cloudinary / Wikimedia)
- Onglets dans la sheet : "Infos / Histoire / Photos / Avis"
- Bouton "Y aller maintenant" qui démarre une sortie en mode itinéraire vers le monument
- Liste des autres collections où ce monument apparaît (cross-linking)
- Lien Wikipedia in-app (WebView)
- Audio guide premium

---

Lis d'abord `URBINK_DEVELOPER_HANDOFF.md` (§4.4 BadgesScreen, §8 Animations) puis `js/Screens.jsx` (constantes `COLLECTIONS` et `MONUMENT_INFO`, partie `Monument Detail Bottom Sheet` dans `BadgesScreen`) pour la référence pixel-perfect du rendu attendu. Respecte strictement les design tokens.
