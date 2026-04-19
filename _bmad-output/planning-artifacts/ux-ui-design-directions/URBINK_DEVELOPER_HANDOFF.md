# Urbink — Developer Handoff Spec
**Version :** 1.0 · **Date :** Avril 2026 · **Plateforme cible :** iOS (Flutter, MVP)

---

## 1. Architecture générale

### Stack technique (MVP)
- **Framework :** Flutter (iOS uniquement, Android V2)
- **Design system :** Material 3 fortement thémé (tokens Urbink)
- **Carte :** flutter_map + OpenStreetMap (Nominatim snap-to-road)
- **Auth :** Firebase anonyme dès le lancement, zéro formulaire
- **État :** Riverpod (recommandé) ou BLoC — pas de setState global
- **Navigation :** GoRouter avec routes nommées

### Structure de navigation
```
Root
├── MainShell (bottom nav persistant)
│   ├── /carte          → CarteScreen
│   ├── /parcours       → ParcoursScreen
│   ├── /social         → SocialScreen
│   ├── /badges         → BadgesScreen
│   └── /profil         → ProfilScreen
└── Overlays (z-index > shell, animation fadeIn)
    ├── /city           → CityPickerScreen
    ├── /filters        → FiltersScreen
    ├── /create-itin    → CreateItineraireScreen
    └── /settings       → SettingsScreen
        ├── create-account  (sub-screen)
        ├── login           (sub-screen)
        ├── map-style        (sub-screen)
        ├── units            (sub-screen)
        ├── theme            (sub-screen)
        ├── density          (sub-screen)
        └── help-faq         (sub-screen)
```

### Global state shape
```dart
class AppState {
  SessionState session;        // active, km, streets, secs
  List<int> exploredStreets;   // IDs de segments de rues colorés
  String lang;                 // 'fr' | 'en' | 'es' | 'pt' | 'ja'
  String cityId;               // 'paris' | 'barcelona' | 'newyork' | ...
  bool showSummary;            // trigger post-session
}

class SessionState {
  bool active;
  double km;
  int streets;
  int secs;
}
```

---

## 2. Design Tokens

### Couleurs
```dart
// lib/shared/constants/colors.dart
const primary       = Color(0xFF256F4C);  // Vert forêt — actions principales
const primaryDark   = Color(0xFF1a5438);  // Gradient header profil
const primaryAlpha10 = Color(0x1A256F4C);
const primaryAlpha06 = Color(0x0F256F4C);
const primaryAlpha18 = Color(0x2E256F4C);

const accent        = Color(0xFFF59E0B);  // Ambre — CTA secondaires, badges
const accentAlpha10 = Color(0x1AF59E0B);
const accentAlpha22 = Color(0x38F59E0B);

const bg            = Color(0xFFF8FAFC);  // Fond général
const surface       = Color(0xFFFFFFFF);  // Cards, sheets
const surfaceVar    = Color(0xFFF1F5F9);  // Chips inactifs, inputs

const textPrimary   = Color(0xFF0F172A);  // Corps et titres
const textMuted     = Color(0xFF64748B);  // Labels secondaires, placeholders
const border        = Color(0xFFE2E8F0);  // Séparateurs, bordures cards
const dragPill      = Color(0xFFCBD5E1);  // Handle bottom sheet

const destructive   = Color(0xFFDC2626);  // Bouton stop, erreurs critiques
const sessionGreen  = Color(0xFF4ADE80);  // Dot actif session

// Carte
const streetExplored       = Color(0xFF256F4C);  // Vert opacité 0.78
const streetExploredHisto  = Color(0xFF8FAF8F);  // Sessions passées opacité 0.55
const mapBackground        = Color(0xFFE8E4D8);  // Fond carte OSM
const mapPark              = Color(0xFFC5D5A8);  // Parcs opacité 0.65
const mapBuilding          = Color(0xFFCEC9BD);  // Bâtiments
```

### Typographie
```dart
// lib/shared/constants/typography.dart
// Display / titres émotionnels
displayLarge:  CrimsonPro Bold 700, 28sp
displayMedium: CrimsonPro SemiBold 600, 22sp  // Titres screens (Parcours, etc.)
displaySmall:  CrimsonPro SemiBold 600, 18sp

// Corps fonctionnel
bodyLarge:   Inter Regular 400, 16sp, lineHeight 1.4
bodyMedium:  Inter Regular 400, 14sp, lineHeight 1.4
bodySmall:   Inter Regular 400, 12sp

// Labels UI
labelLarge:  Inter SemiBold 600, 15sp   // Boutons primaires
labelMedium: Inter Medium 500, 13sp     // Chips, tags
labelSmall:  Inter Medium 500, 11sp     // Nav labels, métadonnées
caption:     Inter Regular 400, 10sp    // Timestamps, sous-labels
```

### Espacements
```dart
// lib/shared/constants/spacing.dart
xs  = 4.0;   // Gap icon + label
sm  = 8.0;   // Éléments d'une card
md  = 16.0;  // Padding standard (cards, sections)
lg  = 24.0;  // Espacement entre sections
xl  = 32.0;  // Marges écran
xxl = 48.0;  // Safe zone pouce

// Border radius
btnRadius    = 16.0;
cardRadius   = 20.0;
chipRadius   = 10.0;
sheetRadius  = 24.0;
avatarRadius = 999.0; // cercle
```

---

## 3. Composants partagés

### BottomNav
- **5 onglets :** Carte (map), Parcours (compass), Social (users), Badges (star), Profil (user)
- **Hauteur :** 74px (60px contenu + 14px safe area simulée)
- **Onglet actif :** couleur `primary`, fontWeight 600
- **Onglet inactif :** couleur `textMuted`, fontWeight 500
- **Labels :** traduits via i18n (`nav_carte`, `nav_parcours`, etc.)
- **Props :** `activeTab`, `onTabChange`, `lang`

### SessionStatusBar
- **Hauteur :** 44px, fond `primary`, position top (sous status bar iOS)
- **Contenu :** dot vert animé + `{km} km · {streets} rues · {MM}:{SS}`
- **Visible uniquement** quand session active
- **Props :** `km: double`, `streets: int`, `secs: int`

### CityBadge (fond coloré — sur fonds sombres)
- Pill avec drapeau + nom ville + chevron ▾
- Fond `rgba(255,255,255,.15)`, bordure `rgba(255,255,255,.25)`
- Tap → ouvre CityPickerScreen
- **Props :** `cityData`, `lang`, `onTap?`

### CityHeaderBar (fond blanc — sur fonds clairs)
- Même logique, fond `{cityColor}18`, bordure `{cityColor}30`
- **Props :** `cityData`, `lang`, `onTap?`

### SearchBar
- Hauteur 48px, radius 16px
- Shadow `0 4px 16px rgba(0,0,0,.10)`
- Icônes : loupe gauche, mic droite
- **Props :** `onTap` (ouvre recherche Nominatim)

### Chip (filtre)
- Padding 6px 12px, radius 10px
- Actif : fond `primary`, texte blanc
- Inactif : fond `surface`, bordure `border`
- **Props :** `label`, `active`, `onTap`

### PrimaryBtn
- Hauteur 52px, radius 16px, pleine largeur
- Variante `green` : fond `primary`, shadow verte
- Variante `amber` : fond `accent`, shadow ambrée
- Disabled : fond `border`, no shadow
- **Props :** `label`, `color: 'green'|'amber'`, `onTap`, `disabled`

### PoiTile
- Numéro coloré (vert ou ambre) + icône + nom/sous-titre + delete + drag
- **Props :** `num`, `icon`, `name`, `sub`, `color`, `onDelete?`

### DragHandle
- 40×4px, couleur `dragPill`, radius 2px, centré, margin-top 10px

---

## 4. Screens

---

### 4.1 CarteScreen (onglet Carte)

**Route :** `/carte`

#### États du bottom sheet (3 snap points)

| Snap | Hauteur | Contenu visible |
|---|---|---|
| `collapsed` | 72px | DragHandle + hint "Démarrer une sortie" |
| `peek` | 280px | Mode cards (Circuit libre / Itinéraire) + GPS chip + CTA Démarrer |
| `expanded` | 580px | Tout peek + stats estimées + layer toggles + info dernière sortie |

**Cycle des taps :** `collapsed → peek → expanded → peek` (jamais retour à collapsed par tap)

#### Composants superposés sur la carte (hors session)
```
[top: 58px]  CityPill + SearchBar (row) → Chips filtres
[bottom: sheetH + 82px]  ZonesPill "Zones ON/OFF"
```

#### Session active
- `SessionStatusBar` remplace la zone top
- Bottom sheet caché
- Bouton STOP rouge 52×52px, bottom: 90px, right: 16px
- `ZonesPill` bottom: 94px

#### Sub-vues du sheet (animation slide latéral dans le sheet)

**`SheetStart`** (défaut)
- 2 `ModeCard` : Circuit libre ✓ sélectionné / Itinéraire
- GPS chip vert
- Bouton "▶ Démarrer la sortie"
- *En expanded uniquement :* StatsRow + Layer toggles (3 items avec toggle switch)

**`SheetItineraires`** (tap sur carte Itinéraire)
- Header : Retour ← + Créer →
- Liste `ParcoursCard` itinéraires sauvegardés
- Tap → `SheetNavChoice`

**`SheetNavChoice`**
- Bandeau itinéraire sélectionné (ambre)
- 4 `NavOptionCard` : GPS intégré (par défaut), Apple Plans, Google Maps, Waze
- CTA amber "🧭 C'est parti !"

#### Carte SVG (simulation — flutter_map en prod)
- Fond `#E8E4D8`, grid SVG léger
- 25 segments de rues (historique : ~11 explorés, ~14 non explorés)
- Rues explorées : stroke `primary`, opacité 0.78
- Rues non explorées : stroke `#BFB9AF`, opacité 0.5
- Parcs : rectangles `#C5D5A8`
- Bâtiments : rectangles `#CEC9BD`
- Dot utilisateur animé (translation toutes les 2.8s en session)
- Rivière : path `#C8DFF0`

#### POI Chips (scroll horizontal)
`🏛️ Monuments` | `🌿 Parcs` | `☕ Cafés` | `🛒 Marchés` | `Voir plus ›`
- Tap "Voir plus ›" → FiltersScreen

#### Flows session
1. Tap "▶ Démarrer" → session démarre, sheet disparaît, SessionBar s'affiche
2. Timer 1s : +0.008km, +1 rue aléatoire explorée
3. Tap STOP → SessionSummary overlay → CelebrationOverlay (badge)
4. Retour carte avec nouvelles rues colorées

---

### 4.2 ParcoursScreen (onglet Parcours)

**Route :** `/parcours`

#### Layout
```
[Header]
  Titre "Parcours" (Crimson Pro 26px)
  CityHeaderBar → ouvre CityPickerScreen
  Bouton + vert (ouvre CreateItineraireScreen)

[City Banner]
  Flag + nom ville + "X rues explorées · Y%"
  Mini barre de progression

[Tab Toggle]
  Mes itinéraires | Thématiques

[Content]
  Onglet "Mes itinéraires" :
    - Liste ParcoursCard avec barre de progression colorée
    - Badge "✓ Complété" si pct=100
    - Bouton dashed "+ Créer un itinéraire"
  
  Onglet "Thématiques" :
    - Description contexte
    - Cards avec progression : nom + X/Y lieux + barre
```

#### Données mock (Paris)
```dart
[
  {emoji: '🗺️', name: 'Tour de Montmartre', meta: '4,2 km · 55 min · 5 étapes', pct: 82},
  {emoji: '📚', name: 'Quartier Latin',      meta: '3,1 km · 40 min · 4 étapes', pct: 100},
  {emoji: '🌊', name: 'Berges de la Seine',  meta: '6,8 km · 1h20 · 6 étapes',  pct: 34},
  {emoji: '🏛️', name: 'Marais & Archives',  meta: '2,8 km · 35 min · 3 étapes', pct: 0},
  {emoji: '🌿', name: 'Circuit Belleville',  meta: '2,1 km · 28 min · 3 étapes', pct: 0},
]
```

**Props :** `lang`, `cityData`, `onCreateItin`, `onNavigate`

---

### 4.3 SocialScreen (onglet Social)

**Route :** `/social`

#### Layout
```
[Header]  "Social" + icône users

[Stories row — scroll horizontal]
  Cercle "Ma carte" (carte emoji) + avatars contacts

[Feed — liste verticale]
  Chaque item FeedActivityItem :
    Avatar + nom + ville + timestamp + menu ···
    Stats : rues · distance · durée
    Mini tracé SVG (polyline sur fond carte)
    Badges débloqués (emojis)
    Réactions : 🔥 (compteur, tap toggle) · 💬 · partage
```

#### FeedActivityItem
- Header : avatar coloré (initiales) + nom + ville + temps relatif
- Stats row : `🗺️ N rues` · `📏 X.Xkm` · `⏱ HHmm`
- Tracé : rect 80px hauteur, SVG polyline `primary`
- Réaction 🔥 : toggle local + compteur +1
- **Props :** item, onLike, onComment

---

### 4.4 BadgesScreen (onglet Badges)

**Route :** `/badges`

#### Layout
```
[Header]
  Titre "Badges" (Crimson Pro 26px)
  CityHeaderBar (top-right) → CityPickerScreen
  Sous-titre : "7/32 · 2 explorés — {ville}"

[Stats Banner]
  Fond ambre léger — 3 métriques : Badges · Quartiers · Km total
  (valeurs en Crimson Pro 26px accent)

[Tab Toggle]
  🏛️ Monuments | 🏘️ Quartiers

[Content]
  Onglet Monuments :
    Grille 3 colonnes
    Débloqué : icône pleine couleur + checkmark vert top-right
    Verrouillé : grayscale 40% + icône 🔒

  Onglet Quartiers :
    Liste avec barres de progression
    100% → badge "Complet 🏆"
    Barre : couleur primary (en cours) ou accent (complété)
```

#### Données monuments (Paris)
```
Débloqués : 🏰 Notre-Dame, 🗼 Tour Eiffel, 🏛️ Louvre, 🏛️ Panthéon, 🛖 Place des Vosges
Verrouillés : ⛪ Sacré-Cœur, 🌉 Pont Neuf, 🏰 Versailles, 🎭 Opéra Garnier, 🌆 Montparnasse, 🏗️ Centre Pompidou, 🌊 Pont d'Iéna
```

#### Données quartiers
```
Marais 78% | Montmartre 55% | Saint-Germain 100% | Bastille 32% | Pigalle 18% | Oberkampf 90%
```

**Props :** `lang`, `cityData`, `onNavigate`

---

### 4.5 ProfilScreen (onglet Profil)

**Route :** `/profil`

#### Layout
```
[Header vert — background primary gradient]
  Décorateurs absolus (cercles rgba) → pointerEvents: none
  Row : avatar A + nom + sous-titre + bouton ⚙️ (ouvre Settings)
  CityBadge (blanc) + barre progression ville + %
  Stats row : Rues · Distance · Badges · Quartiers

[Content blanc — scrollable]
  Row "⚙️ Paramètres" (large tap target 52px) → Settings
  
  Card "Cette semaine"
    Histogramme 7 barres (L M M J V S D)
    Aujourd'hui = accent, jours vides = surfaceVar opacity 0.3
    Stats sous : Rues/sem · Sorties · Distance
  
  Section "Dernières sorties"
    Cards emoji + date + badge NEW + stats + badges débloqués
```

#### Trigger Settings
- Bouton ⚙️ dans header : `position: relative, zIndex: 10`
- Row "Paramètres" dans contenu : fallback fiable (large tap target)
- Les deux appellent `onSettings()`

**Props :** `lang`, `cityData`, `onSettings`, `onNavigate`, `onChangeCity`

---

### 4.6 CityPickerScreen (overlay)

**Route :** overlay `/city` (fadeIn, pas de slideUp)

#### Layout
```
[Header fixe]
  ← Retour
  "Changer de ville" + sous-titre

[Search bar]
  Full width, filtre en temps réel sur nom/pays

[Liste villes — scroll]
  Chaque CityCard :
    Drapeau (48×48px, fond coloré) + nom + pays
    Badge "Ville active" si city courante
    Barre progression si pct > 0
    Sinon : "X rues · Explorer cette ville"
    Radio button droit

[Footer sticky]
  Bouton primaire "{flag} {ville}" disabled si même ville
```

#### Villes disponibles (10)
```
paris / barcelona / newyork / lisbon / tokyo / london / rome / amsterdam / berlin / montreal
```
Chaque ville a : `id, name{fr/en/es/pt/ja}, country{fr/en/es/pt/ja}, flag, streets, pct, explored, color`

**Props :** `currentCityId`, `lang`, `onSelectCity`, `onBack`

---

### 4.7 FiltersScreen (overlay)

**Route :** overlay `/filters`

#### Layout
```
[Header fixe]
  ← Retour
  "Filtres" + bouton "Réinitialiser" (destructif, visible si >0 actifs)

[Banner actifs]
  Fond vert léger — "N filtre(s) actif(s)" — visible si >0

[Catégories — scroll]
  Culture : 🏛️ Monuments · 🎨 Musées · 🎭 Théâtres · 📚 Librairies · 🎬 Cinémas
  Nature : 🌿 Parcs · 🌳 Jardins · 🌊 Berges · 🏕️ Forêts
  Gastronomie : ☕ Cafés · 🍽️ Restaurants · 🥐 Boulangeries · 🍷 Bars · 🧀 Fromageries
  Transports : 🚇 Métro · 🚲 Vélibs · 🚌 Bus · 🚉 RER

[Footer sticky]
  "Appliquer (N)" ou "Appliquer"
```

**State :** `Set<String> activeFilters` — toggle par tap
**Props :** `initialFilters?`, `onApply`, `onBack`

---

### 4.8 CreateItineraireScreen (overlay)

**Route :** overlay `/create-itin`

#### Layout (3 zones)
```
[Header fixe — background surface]
  Row : ← Retour | "Créer un itinéraire" | CityHeaderBar
  SearchBar (pleine largeur, 48px)
  Chips filtres (scroll horizontal)
  → Total : ~170px de hauteur

[Carte SVG — derrière le sheet]
  top: 170px, bottom: 74px
  Pins numérotés sur les POIs + ligne pointillée entre eux

[Bottom sheet fixe — 80px collapsed / ~380px expanded]
  DragHandle
  Mode tabs : ✏️ Manuel | ✨ Auto
  
  Manuel :
    Titre "Étapes du parcours" + badge "N/min. 3"
    Input nom itinéraire (optionnel)
    Liste PoiTile (drag + delete)
    CTA "🗺️ Créer l'itinéraire" (disabled si <3 POIs)
  
  Auto :
    Titre + sous-titre
    Sélecteur durée : 4 chips 15/30/45/60 min
    StatsRow estimé
    CTA amber "✨ Générer l'itinéraire"
    → Après génération : StatsRow réel + liste POIs read-only + Regénérer|Utiliser
```

**Props :** `lang`, `cityData`, `onBack`, `onCreate`

---

### 4.9 SettingsScreen (overlay)

**Route :** overlay `/settings`, **sous-écrans** gérés localement (`subScreen` state)

#### Structure principale
```
[Header fixe]
  ← Retour | "Paramètres" | ⚙️ icône

[Card profil + langue — gradient vert]
  Avatar + nom + "Explorateur anonyme" + btn Éditer
  Séparateur
  Sélecteur langue : 5 pills (FR 🇫🇷 EN 🇬🇧 ES 🇪🇸 PT 🇵🇹 JA 🇯🇵)
  Pill actif : fond blanc 25%, bordure blanche 60%

[Sections — scroll]
  COMPTE         → Mode anonyme (badge Actif) · Créer compte → · Se connecter →
  CONFIDENTIALITÉ → GPS ✓OK · Tracking passif ⬛ · Profil public ⬜ · Données ⬛
  NOTIFICATIONS  → Badges ⬛ · Quartier ⬛ · Social ⬜ · Rappels ⬜
  CARTE          → Style → · Unités → · Couleur rues (color dot) · Densité POI →
  APPLICATION    → Thème → · Économie batterie ⬛
  AIDE & LÉGAL   → Aide FAQ → · Noter l'app → · CGU → · Conf. → · Version (texte)

[Zone danger]
  🗑️ Effacer toutes mes données (rouge)
  🚪 Se déconnecter (rouge)
```

#### Sous-écrans Settings (animation slideUp 30px)

**Créer un compte**
- Email + MDP + Confirmer MDP
- CTA "Créer mon compte" → état succès 🎉

**Se connecter**
- Email + MDP
- Lien "Mot de passe oublié ?"
- CTA "Se connecter" → état succès ✅

**Style de carte** (radio + mini-aperçu SVG)
- Classique · Chaud · Nuit · Sépia

**Unités** (radio)
- Kilomètres · Miles

**Thème** (radio)
- ☀️ Clair · 🌙 Sombre (coming soon) · 📱 Système

**Densité POI** (radio)
- Faible · Normale · Élevée

**Aide & FAQ**
- 5 Q&A : coloration, batterie, GPS, badges, reset

**Props :** `lang`, `onLangChange`, `onBack`

---

### 4.10 SessionSummary (overlay)

**Déclenché** par arrêt session → `showSummary = true`

```
[Bottom sheet remontant depuis le bas]
  DragHandle
  🎉 "Sortie terminée !"
  
  Grille 2×2 métriques :
    🗺️ N rues | 📏 X km | ⏱ MM:SS | 🏆 N badges
  
  Bandeau ambre : badges débloqués
  
  Boutons : Partager (outline) | Super ! (primary)
```

**Après fermeture** → déclenche CelebrationOverlay

---

### 4.11 CelebrationOverlay (overlay)

**Déclenché** après SessionSummary

```
[Plein écran, fond sombre semi-transparent]
  24 particules animées (fall 2s)
  Badge central (scale-in 600ms) : gradient or 120×120px
  Titre "Badge débloqué !" + nom monument
  Description
  CTA "Continuer l'exploration"
  Lien "Ignorer"
```

**Animations :**
- `fall` : translateY 0 → 110vh + rotate 720deg, ease-in, 2s
- `badgePop` : scale 0.5 → 1, cubic-bezier(.34,1.56,.64,1), 600ms

---

## 5. Système i18n

### Langues supportées
`fr` (défaut) · `en` · `es` · `pt` · `ja`

### Implémentation
```dart
// Fonction de traduction
String t(String lang, String key) {
  return TRANSLATIONS[lang]?[key] ?? TRANSLATIONS['fr']![key] ?? key;
}
```

### Clés de traduction (référence)
| Clé | FR | EN |
|---|---|---|
| `nav_carte` | Carte | Map |
| `nav_parcours` | Parcours | Routes |
| `nav_social` | Social | Social |
| `nav_badges` | Badges | Badges |
| `nav_profil` | Profil | Profile |
| `sheet_hint_collapsed` | Démarrer une sortie | Start a trip |
| `sheet_hint_peek` | Plus d'options | More options |
| `sheet_hint_expanded` | Réduire | Collapse |
| `sheet_title` | Démarrer une sortie | Start a trip |
| `mode_libre` | Circuit libre | Free roam |
| `mode_itin` | Itinéraire | Itinerary |
| `gps_ready` | Mode auto-détecté · GPS prêt | Auto-detected mode · GPS ready |
| `btn_start` | ▶  Démarrer la sortie | ▶  Start trip |
| `layers_title` | Affichage carte | Map display |
| `city_change` | Changer de ville | Change city |
| `city_explored` | explorées | explored |
| `city_streets` | rues | streets |
| `city_select` | Explorer cette ville | Explore this city |
| `parcours_title` | Parcours | Routes |
| `tab_mes` | Mes itinéraires | My routes |
| `tab_thematiques` | Thématiques | Thematic |
| `completed` | ✓ Complété | ✓ Completed |
| `badges_title` | Badges | Badges |
| `tab_monuments` | 🏛️ Monuments | 🏛️ Monuments |
| `tab_quartiers` | 🏘️ Quartiers | 🏘️ Districts |
| `badge_unlocked` | Complet 🏆 | Complete 🏆 |
| `badge_explored` | explorés | explored |
| `settings_title` | Paramètres | Settings |
| `lang_title` | Langue | Language |

> **Note :** ES, PT, JA ont des traductions complètes pour toutes les clés ci-dessus. Voir fichier `i18n.jsx` pour référence exhaustive.

---

## 6. Système de villes

### Modèle CityData
```dart
class CityData {
  final String id;
  final Map<String, String> name;      // {fr, en, es, pt, ja}
  final Map<String, String> country;   // {fr, en, es, pt, ja}
  final String flag;                   // emoji drapeau
  final int streets;                   // total segments OSM
  final int pct;                       // % explorés (0-100)
  final int explored;                  // segments explorés
  final Color color;                   // couleur d'accent ville
}
```

### Villes (10 — MVP)
| ID | Nom | Drapeau | Rues totales | Progression mock |
|---|---|---|---|---|
| `paris` | Paris | 🇫🇷 | 15 432 | 8% — 1 234 rues |
| `barcelona` | Barcelone | 🇪🇸 | 12 100 | 0% |
| `newyork` | New York | 🇺🇸 | 42 000 | 0% |
| `lisbon` | Lisbonne | 🇵🇹 | 8 900 | 3% — 267 rues |
| `tokyo` | Tokyo | 🇯🇵 | 78 000 | 0% |
| `london` | Londres | 🇬🇧 | 34 000 | 1% — 340 rues |
| `rome` | Rome | 🇮🇹 | 11 500 | 0% |
| `amsterdam` | Amsterdam | 🇳🇱 | 7 200 | 0% |
| `berlin` | Berlin | 🇩🇪 | 13 400 | 0% |
| `montreal` | Montréal | 🇨🇦 | 9 800 | 5% — 490 rues |

### Comportement changement de ville
- `exploredStreets` reset à `[]` (les rues explorées sont par ville)
- Les badges, parcours et historique sont scopés par ville (V1 : mock par ville)
- La carte se recentre sur la ville sélectionnée

---

## 7. Tracking & Session

### Architecture tracking (2 couches)

**Couche 1 — Tracking passif (toujours actif)**
- Démarre dès l'ouverture de l'app (zéro tap requis)
- Colorie les rues via GPS snap-to-road (Nominatim)
- Géré par le toggle `ZonesPill` ("Zones ON/OFF") — visible en permanence
- Données locales uniquement (pas de serveur requis pour la couche 1)

**Couche 2 — Session enregistrée (opt-in)**
- Démarre via "▶ Démarrer la sortie" dans le bottom sheet
- Enregistre : distance, durée, rues explorées, mode transport
- Modes : **Circuit libre** (stats + historique) | **Itinéraire** (GPS guidé)
- Mode transport auto-détecté par vitesse GPS (< 7km/h = marche, < 30km/h = vélo)

### SessionStatusBar
- Aparaît en position `top: 50px` (sous status bar), hauteur 44px
- Circuit libre : fond `primary` (vert)
- Itinéraire : fond ocre `#B8832E` (non implémenté dans ce prototype, V2)
- Contenu : dot vert pulsant + distance + rues + chrono (MM:SS)

### Stop session
1. Tap bouton stop rouge → `SessionSummary` overlay
2. SessionSummary fermé → `CelebrationOverlay` (badge)
3. CelebrationOverlay fermé → retour carte, nouvelles rues visibles

---

## 8. Animations

### Transitions d'overlays
```css
/* Overlays principaux (Settings, City, Filters, Create) */
@keyframes fadeIn {
  from { opacity: 0; }
  to   { opacity: 1; }
}
duration: 200ms;

/* Sous-écrans Settings */
@keyframes slideUp {
  from { transform: translateY(30px); opacity: 0; }
  to   { transform: translateY(0);    opacity: 1; }
}
duration: 250ms;
```

> **⚠️ Important :** Ne pas utiliser `translateY(100%)` pour les overlays dans un container `overflow:hidden` — le contenu est clippé et invisible pendant l'animation.

### Bottom sheet
```dart
// CSS équivalent
transition: transform 400ms cubic-bezier(.4, 0, .2, 1);
```
3 snap points : `collapsed(72px)` → `peek(280px)` → `expanded(580px)`

### Célébration
```css
@keyframes fall {
  from { transform: translateY(0) rotate(0deg); opacity: 1; }
  to   { transform: translateY(110vh) rotate(720deg); opacity: 0; }
}

@keyframes badgePop {
  from { transform: scale(0.5); opacity: 0; }
  to   { transform: scale(1);   opacity: 1; }
}
```

### Reduced Motion
- `MediaQuery.of(context).disableAnimations` → fade 150ms uniquement
- Particules désactivées
- Sheet snap instantané

---

## 9. Accessibilité

- **Contraste minimum :** WCAG 2.1 AA (4.5:1 texte, 3:1 UI)
- **Zone tactile minimum :** 44×44px (iOS HIG)
- **VoiceOver :** tous les éléments interactifs avec label Semantics
- **Dynamic Type :** respecté via ThemeData.textTheme (jamais de font size hardcodé)
- **Plein soleil :** palette testée à luminosité max, vert sur fond carte > 3:1
- **Pointer events :** éléments décoratifs absolus → `pointerEvents: none`

---

## 10. Checklist d'implémentation Flutter

### P0 — MVP obligatoire
- [ ] GPS permission flow (toujours autoriser)
- [ ] Snap-to-road Nominatim (< 1s latence perçue)
- [ ] Coloration rues temps réel (flutter_map polylines)
- [ ] Session start/pause/stop
- [ ] Bottom sheet 3 snap points (DraggableScrollableSheet)
- [ ] Bottom nav 5 tabs (NavigationBar Material 3)
- [ ] Firebase auth anonyme
- [ ] Stockage local (sessions, rues explorées) — Hive ou SQLite

### P1 — V1 launch
- [ ] i18n (5 langues)
- [ ] Multi-ville (10 villes, données OSM)
- [ ] Parcours sauvegardés (CRUD local)
- [ ] Badges monuments (rayon 100m)
- [ ] Settings complet (account, privacy, map style)
- [ ] CelebrationOverlay avec Lottie

### P2 — V2
- [ ] Feed social (Firebase Firestore)
- [ ] Photos épinglées (Firebase Storage)
- [ ] Android support
- [ ] Génération itinéraire auto (algo maximise rues non explorées)
- [ ] Partage carte colorée (Flutter screenshot + watermark)

---

*Document généré depuis le prototype Urbink App.html — Avril 2026*
