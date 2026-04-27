---
stepsCompleted: [1, 2, 3, 4]
status: complete
lastEdited: '2026-04-13'
editHistory:
  - date: '2026-04-13'
    changes: 'v2 — Nav v4 (5 onglets plats, FAB Démarrer supprimé) ; UX-DR9 obsolète (TransportModeSelector) ; UX-DR10 mis à jour ; Story 1.3 ACs refondus ; Story 2.4 → SessionStatusBar + auto-détection ; Story 2.5 flow depuis bottom sheet ; Story 2.6 refs SessionStatusBar ; Stories 2.8 (tracking passif) et 2.9 (bottom sheet Carte & Sorties) ajoutées ; FR Coverage Map mis à jour (FR0, FR1b, FR10b, FR10c, FR23b)'
inputDocuments:
  - '_bmad-output/planning-artifacts/prd.md'
  - '_bmad-output/planning-artifacts/architecture.md'
  - '_bmad-output/planning-artifacts/ux-design-specification.md'
---

# Urbink - Epic Breakdown

## Overview

Ce document fournit le découpage complet en epics et stories pour Urbink, décomposant les exigences du PRD, de l'Architecture et de la Spec UX en stories implémentables et actionnables.

## Requirements Inventory

### Functional Requirements

FR1 : L'utilisateur peut démarrer une session d'exploration qui enregistre son tracé GPS en temps réel
FR2 : Le système fait correspondre le tracé GPS aux rues du réseau OSM (snap to nearest road via Nominatim) et les colorie
FR3 : L'utilisateur voit ses rues explorées colorées sur la carte en temps réel pendant une session
FR4 : Le système détecte automatiquement le mode de déplacement (marche / vélo / voiture) sans intervention
FR5 : L'utilisateur peut arrêter et reprendre une session d'exploration
FR6 : Chaque session est sauvegardée individuellement avec horodatage et mode de déplacement
FR7 : L'utilisateur peut visualiser l'agrégation de toutes ses sessions sur la carte (vue "tout l'historique")
FR8 : L'utilisateur peut filtrer l'affichage des sessions par période : aujourd'hui / cette semaine / ce mois / tout l'historique
FR9 : Le système calcule et affiche le pourcentage de rues explorées par quartier
FR10 : L'utilisateur voit la carte complète de Paris en tout temps (aucune zone masquée)
FR11 : L'utilisateur peut consulter la liste des points d'intérêt à proximité de sa position
FR12 : L'utilisateur peut lire la description textuelle d'un monument ou point d'intérêt
FR13 : L'utilisateur peut écouter la description audio d'un monument (TTS à la demande)
FR14 : L'utilisateur peut activer ou désactiver l'affichage des couches (monuments, pins, quartiers)
FR15 : L'utilisateur peut voir la progression de complétion de chaque quartier de Paris
FR16 : Le système débloque automatiquement un badge quartier quand toutes les rues sont explorées
FR17 : Le système révèle un "secret local" lors de la complétion d'un quartier
FR18 : Le système débloque automatiquement un badge monument quand l'utilisateur passe à proximité
FR19 : L'utilisateur peut consulter tous ses badges obtenus et leur progression
FR20 : L'utilisateur peut activer un objectif thématique et suivre sa progression
FR21 : L'utilisateur peut générer en un tap un parcours automatique couvrant le maximum de rues non explorées avec une durée cible
FR22 : L'utilisateur peut créer un parcours personnalisé en traçant manuellement un itinéraire sur la carte
FR23 : L'utilisateur peut suivre un parcours en temps réel avec guidage visuel
FR24 : Les rues se colorient au fur et à mesure de la progression sur un parcours
FR25 : L'utilisateur peut créer un pin communautaire avec photo, description et position GPS
FR26 : Le système soumet automatiquement chaque pin à la modération IA avant publication — sanction progressive : avertissement → avertissement → suspension 24h → ban
FR27 : L'utilisateur peut voir les pins communautaires sur la carte (clustering par zoom, pins des profils privés visibles uniquement par leurs abonnés)
FR28 : L'utilisateur peut réagir négativement à un pin ("Pas ouf") — 5 réactions négatives rendent le pin privé automatiquement
FR29 : L'utilisateur peut signaler un pin comme inapproprié
FR30 : L'utilisateur peut exporter une image de sa carte colorée (watermark Urbink) et la partager sur les réseaux sociaux
FR31 : L'utilisateur peut partager un itinéraire avec un lien (aperçu web pour les non-utilisateurs)
FR31b : L'utilisateur peut suivre d'autres explorateurs (profil public : abonnement immédiat ; profil privé : demande à accepter)
FR31c : L'utilisateur peut configurer son profil en public ou privé (modèle Instagram)
FR31d : L'utilisateur peut publier un parcours terminé dans un fil d'actualité visible par ses abonnés
FR32 : L'utilisateur peut utiliser l'app en mode invité sans compte — UID anonyme Firebase créé automatiquement, progression dans Firestore dès le départ
FR33 : L'utilisateur peut créer un compte via Sign in with Apple, Google ou Facebook — linkWithCredential() sans perte de données
FR34 : La progression est déjà dans Firestore sous l'UID anonyme — aucune migration nécessaire
FR35 : L'utilisateur peut accéder à sa progression depuis un nouvel appareil après connexion
FR36 : L'utilisateur peut recevoir une notification lors du déblocage d'un badge
FR37 : L'utilisateur peut recevoir une notification de rappel d'exploration (max 1 fois / 3 jours)
FR38 : L'utilisateur peut recevoir une notification quand quelqu'un réagit à son pin
FR39 : L'utilisateur peut gérer ses préférences de notification
FR40 : L'administrateur peut importer et valider des pins pré-remplis via le pipeline cold start IA
FR41 : L'administrateur peut définir et associer des secrets locaux à chaque quartier
FR42 : L'administrateur peut consulter la file de modération des pins signalés (Firebase Console MVP)
FR43 : L'administrateur peut supprimer un pin sans préavis
FR44 : L'administrateur peut configurer les monuments et leurs données (description, position, badge associé)
FR45 : L'utilisateur peut consulter et accepter la politique de confidentialité au premier lancement
FR46 : L'utilisateur peut supprimer son compte — anonymisation RGPD : données personnelles supprimées, sessions GPS conservées (IDs de rues uniquement), pins anonymisés
FR47 : Le système affiche les crédits OpenStreetMap conformément à la licence ODbL

### NonFunctional Requirements

NFR1 : Chargement initial de la carte au lancement : < 2 secondes
NFR2 : Coloration d'une rue après passage GPS : < 1 seconde (latence perçue)
NFR3 : Génération d'un parcours automatique : < 3 secondes
NFR4 : Agrégation et affichage des sessions filtrées : < 2 secondes
NFR5 : Liste des POI à proximité : < 1 seconde
NFR6 : Aucune perte de données de session GPS — chaque session persistée localement avant sync cloud
NFR7 : Échec de sync cloud : données locales conservées et re-synchronisées automatiquement à la prochaine connexion
NFR8 : Disponibilité cible du backend : 99,5% (local-first, cloud non bloquant)
NFR9 : Données en transit chiffrées via HTTPS/TLS
NFR10 : Données de localisation accessibles uniquement au compte utilisateur propriétaire
NFR11 : Aucune revente ni partage de données de localisation avec des tiers
NFR12 : Suppression complète et irréversible des données sur demande (RGPD)
NFR13 : Tokens OAuth stockés dans iOS Keychain (flutter_secure_storage)
NFR14 : Architecture backend supportant 10 000 utilisateurs actifs mensuels, scalable à 10x
NFR15 : Volume estimé ~1 Mo/utilisateur/mois de données GPS — Firestore dimensionné en conséquence
NFR16 : Intégration OpenStreetMap (tuiles + réseau routier)
NFR17 : Intégration Wikidata / Wikipedia (descriptions monuments)
NFR18 : Intégration Apple Push Notification Service (APNs)
NFR19 : Intégration Sign in with Apple / Google OAuth / Facebook Login
NFR20 : AVSpeechSynthesizer TTS natif iOS — sans coût externe

### Additional Requirements

- **Initialisation projet :** `flutter create urbink` + configuration Firebase via FlutterFire CLI — première story Epic 1
- **Environnements Firebase :** 3 projets distincts (dev / staging / prod) à configurer
- **CI/CD :** GitHub Actions (build + tests) + Fastlane (publication App Store automatique)
- **Monitoring :** Firebase Crashlytics (crashes) + Firebase Analytics (métriques usage)
- **Stockage local cache :** sqflite — cache local uniquement, source de vérité = Firestore dès le premier lancement via Firebase Anonymous Auth
- **Admin back-office MVP :** Firebase Console — pas de code admin à développer au MVP
- **Snap to road :** Nominatim API (REST, ~200ms, en ligne uniquement) via NominatimClient isolé dans `shared/utils/`
- **Map matching V2 :** service Go + OSRM/Valhalla conteneurisé sur Scaleway — hors MVP
- **Structure feature-based :** organisation par feature, jamais par type
- **Frontière architecturale :** jamais d'appel Firestore direct dans un widget — toujours via Riverpod provider
- **Clés API :** jamais dans le code Flutter — uniquement dans Cloud Functions Go
- **Cold start Paris :** 200 pins pré-remplis + secrets locaux 20 arrondissements à J0 du lancement
- **State management :** Riverpod — StreamProvider pour Firestore, states immutables via freezed
- **Navigation :** go_router — routing déclaratif Flutter standard

### UX Design Requirements

UX-DR1 : Implémenter le design system Material 3 avec tokens Urbink — palette (Ocre #B8832E, Vert Sauge #5A7A5A, Brun profond #1E1610, fond #FAFAF7), typographie (Crimson Pro / Inter), espacements (base 4px, grille 8px) dans `shared/constants/colors.dart`, `typography.dart`, `spacing.dart`
UX-DR2 : Créer le composant custom `MapStreetOverlay` — couche flutter_map affichant les polylines de rues explorées (Vert Sauge #5A7A5A opacité 0.75), rue en cours animée (#6A9A6A), marqueurs pins 📷 cliquables — 4 états : idle / recording / playback / creation
UX-DR3 : *(done — Story 2.4)* Créer le composant custom `SessionCounter` — pill semi-transparent top-center pendant session active, affichant N rues · km · HH:MM avec indicateur GPS animé (vert/orange) — 3 états : acquiring / active / paused
UX-DR3b : *(Story 2.10)* Remplacer `SessionCounter` par `SessionStatusBar` — barre 44px position absolue haut de carte, fond Terra Cotta #A84E2C (circuit libre) ou Ocre #B8832E (itinéraire), auto-détection transport, suppression `TransportModeSelector`
UX-DR4 : Créer le composant custom `CelebrationOverlay` — overlay plein écran Lottie pour badge monument (2-3s), quartier complété (3-4s, secret local révélé), itinéraire terminé (2s) — accessibilityAnnouncement + reducedMotion fallback fade 150ms
UX-DR5 : Créer le composant custom `FeedActivityItem` — item feed social avec header avatar + stats row + RouteMapPreview + chips badges/photos + réactions bar (🔥💬🗺️) — variantes compact (vue simple) et full (feed Accueil/Vous)
UX-DR6 : Créer le composant custom `WeekHistogram` — histogramme 7 barres L-D, hauteur proportionnelle aux rues explorées, jour actuel en Ocre, jours vides en fantôme #F0EDE8 — 3 états : empty / partial / full
UX-DR7 : Créer le composant custom `BadgeGrid` — grille 4 colonnes monuments / 3 colonnes quartiers, badges débloqués en couleur + scale-in au premier affichage, badges verrouillés opacité 40% + indice texte + CTA "Voir sur carte"
UX-DR8 : Créer le composant custom `RouteMapPreview` — carte miniature SVG schématique avec polyline tracé (Vert Sauge = sorties, Ocre = itinéraires planifiés) — 3 variantes : small 176×85px / medium full-width 16:9 / thumbnail 48×48px
UX-DR9 : ~~OBSOLÈTE — `TransportModeSelector` supprimé~~ Le mode de déplacement est auto-détecté via la vitesse GPS (marche < 7 km/h · vélo < 30 km/h · voiture au-dessus) — aucun composant de sélection manuelle à implémenter ; le mode est affiché en lecture seule dans la `SessionStatusBar`
UX-DR10 : Implémenter la bottom navigation 5 onglets plats (Carte 🗺️ · Parcours 🧭 · Social 👥 · Badges 🏆 · Profil 👤) — **pas de bouton central surélevé** (FAB Démarrer supprimé en v4) ; onglet actif Ocre #B8832E + underline 2px, inactifs #8C7B6A ; tab persistence état/position par onglet
UX-DR11 : Implémenter les bottom sheets conformément aux specs UX — snap 40% (aperçu) / 70% (détail), pill de drag 4×32px, scrim #1E1610 @40%, swipe-to-dismiss, focus piégé à l'intérieur tant qu'ouvert
UX-DR12 : Implémenter la hiérarchie des boutons Urbink — Primaire (Ocre #B8832E, hauteur 52px, radius 12px), Secondaire (contour Ocre), Ghost (texte seul), Destructif (rouge #C0392B) — état loading : spinner blanc inline, jamais 2 primaires sur le même écran
UX-DR13 : Implémenter les feedback patterns — SnackBar custom 4 types (succès #2D5A2D / info #1E1610 / erreur #8B2020 / warning #7A5A1E), 2.5s dismiss, icône gauche — feedback haptique léger/moyen/fort selon l'action
UX-DR14 : Implémenter les empty states pour tous les contextes vides (feed sans follows, itinéraires vides, historique vierge) — illustration emoji + message chaleureux ≤ 2 lignes + CTA si action directe disponible
UX-DR15 : Implémenter le support WCAG 2.1 AA — Semantics Flutter sur tous les éléments interactifs, zones tactiles minimum 44×44pt, Dynamic Type iOS jusqu'à xxxLarge, reducedMotion (MediaQuery.disableAnimations), lien Réglages iOS pour erreurs GPS
UX-DR16 : Implémenter la gestion des safe areas iOS — safeAreaTop pour `SessionStatusBar` et search pill, safeAreaBottom + 60pt pour bottom nav, zone pouce 120pt depuis le bas pour toutes les actions primaires (bouton Arrêter ■ bas-droite compris)

### FR Coverage Map

FR0 → Epic 2 · Carte & Exploration — Tracking passif toujours actif (sans session)
FR1 → Epic 2 · Carte & Exploration — Démarrage session circuit libre enregistrée (depuis bottom sheet)
FR1b → Epic 5 · Parcours — Mode itinéraire GPS pur (check-points, reset progression)
FR2 → Epic 2 · Carte & Exploration — Snap to road Nominatim + coloration
FR3 → Epic 2 · Carte & Exploration — Affichage rues colorées temps réel (MapStreetOverlay)
FR4 → Epic 2 · Carte & Exploration — Détection automatique mode déplacement
FR5 → Epic 2 · Carte & Exploration — Arrêt et reprise de session circuit libre
FR6 → Epic 2 · Carte & Exploration — Sauvegarde session avec horodatage et mode
FR7 → Epic 3 · Historique & Filtrage — Agrégation toutes sessions
FR8 → Epic 3 · Historique & Filtrage — Filtrage temporel
FR9 → Epic 3 · Historique & Filtrage — Pourcentage complétion par quartier
FR10 → Epic 2 · Carte & Exploration — Carte Paris toujours visible
FR10b → Epic 2 · Carte & Exploration — Toggle zones explorées persistant bas-gauche
FR10c → Epic 6 · Points d'Intérêt — Chips POI filtres inline + écran filtres complets
FR11 → Epic 6 · Points d'Intérêt — Liste POI à proximité
FR12 → Epic 6 · Points d'Intérêt — Description textuelle monument (Wikidata)
FR13 → Epic 6 · Points d'Intérêt — Lecture audio TTS
FR14 → Epic 3 · Historique & Filtrage — Toggle couches carte
FR15 → Epic 4 · Gamification — Progression complétion quartier
FR16 → Epic 4 · Gamification — Badge quartier débloqué automatiquement
FR17 → Epic 4 · Gamification — Secret local révélé
FR18 → Epic 4 · Gamification — Badge monument débloqué par proximité
FR19 → Epic 4 · Gamification — Consultation badges et progression
FR20 → Epic 4 · Gamification — Activation et suivi objectif thématique
FR21 → Epic 5 · Parcours — Génération parcours automatique 1-tap
FR22 → Epic 5 · Parcours — Création itinéraire personnalisé (POIs ordonnés + option boucle)
FR23 → Epic 5 · Parcours — Guidage itinéraire GPS temps réel
FR23b → Epic 5 · Parcours — Sélecteur navigation externe (Waze/Plans/Google Maps/GPS intégré)
FR24 → Epic 5 · Parcours — Coloration passive pendant progression itinéraire
FR25 → Epic 8 · Communauté & Pins — Création pin (photo + texte + GPS)
FR26 → Epic 8 · Communauté & Pins — Modération IA + sanctions progressives
FR27 → Epic 8 · Communauté & Pins — Affichage pins sur carte
FR28 → Epic 8 · Communauté & Pins — Réaction "Pas ouf" + auto-masquage
FR29 → Epic 8 · Communauté & Pins — Signalement pin
FR30 → Epic 9 · Partage & Social — Export image carte colorée
FR31 → Epic 9 · Partage & Social — Partage itinéraire par lien
FR31b → Epic 9 · Partage & Social — Suivi explorateurs (follow/unfollow)
FR31c → Epic 9 · Partage & Social — Profil public/privé
FR31d → Epic 9 · Partage & Social — Publication parcours dans fil d'actualité
FR32 → Epic 7 · Compte & Auth — Mode invité Firebase Anonymous Auth
FR33 → Epic 7 · Compte & Auth — Création compte OAuth (linkWithCredential)
FR34 → Epic 7 · Compte & Auth — Données Firestore sous UID anonyme dès J0
FR35 → Epic 7 · Compte & Auth — Accès multi-appareils
FR36 → Epic 10 · Notifications — Notification déblocage badge
FR37 → Epic 10 · Notifications — Notification rappel exploration
FR38 → Epic 10 · Notifications — Notification réaction pin
FR39 → Epic 10 · Notifications — Gestion préférences de notification
FR40 → Epic 11 · Administration — Import pins cold start IA
FR41 → Epic 11 · Administration — Secrets locaux par quartier
FR42 → Epic 11 · Administration — File modération pins signalés
FR43 → Epic 11 · Administration — Suppression pin sans préavis
FR44 → Epic 11 · Administration — Configuration monuments
FR45 → Epic 7 · Compte & Auth — Politique de confidentialité RGPD au premier lancement
FR46 → Epic 7 · Compte & Auth — Suppression compte et anonymisation RGPD
FR47 → Epic 2 · Sessions GPS — Crédits OpenStreetMap (ODbL)

UX-DR1 → Epic 1 · Fondation — Design tokens Material 3 + Urbink
UX-DR2 → Epic 2 · Sessions GPS — Composant MapStreetOverlay
UX-DR3 → Epic 2 · Carte & Exploration — Composant SessionStatusBar
UX-DR4 → Epic 4 · Gamification — Composant CelebrationOverlay
UX-DR5 → Epic 9 · Partage & Social — Composant FeedActivityItem
UX-DR6 → Epic 3 · Historique & Filtrage — Composant WeekHistogram
UX-DR7 → Epic 4 · Gamification — Composant BadgeGrid
UX-DR8 → Epic 5 · Parcours — Composant RouteMapPreview
UX-DR9 → ~~OBSOLÈTE~~ — auto-détection transport intégrée dans Epic 2 (pas de composant séparé)
UX-DR10 → Epic 1 · Fondation — Bottom navigation 5 onglets
UX-DR11 → Epic 1 · Fondation — Bottom sheets conformes UX
UX-DR12 → Epic 1 · Fondation — Hiérarchie boutons Urbink
UX-DR13 → Epic 1 · Fondation — Feedback patterns (toasts + haptique)
UX-DR14 → Epic 1 · Fondation — Empty states
UX-DR15 → Epic 1 · Fondation — Accessibilité WCAG 2.1 AA
UX-DR16 → Epic 1 · Fondation — Safe areas iOS

## Epic List

### Epic 1 : Fondation & Infrastructure
Setup projet Flutter, Firebase multi-env, CI/CD, design system Material 3 + tokens Urbink, composants de navigation et patterns UX fondamentaux.
**FRs couverts :** FR45, FR47 (partiels — onboarding et crédits OSM)
**UX-DRs couverts :** UX-DR1, UX-DR10, UX-DR11, UX-DR12, UX-DR13, UX-DR14, UX-DR15, UX-DR16

### Epic 2 : Carte & Exploration GPS
Les utilisateurs voient Paris, marchent, et leurs rues se colorient en temps réel (couche passive) — le moment "aha" du produit. La session circuit libre enregistrée est opt-in depuis le bottom sheet Carte & Sorties.
**FRs couverts :** FR0, FR1, FR1b (partiel), FR2, FR3, FR4, FR5, FR6, FR10, FR10b, FR47
**UX-DRs couverts :** UX-DR2, UX-DR3 (→ SessionStatusBar)

### Epic 3 : Historique & Filtrage Temporel
Les utilisateurs visualisent toute leur exploration agrégée, filtrée par période, et suivent leur progression dans l'onglet Vous.
**FRs couverts :** FR7, FR8, FR9, FR14
**UX-DRs couverts :** UX-DR6

### Epic 4 : Gamification & Progression
Les utilisateurs débloquent des badges quartiers et monuments, découvrent des secrets locaux, et suivent des objectifs thématiques — avec animations de célébration.
**FRs couverts :** FR15, FR16, FR17, FR18, FR19, FR20
**UX-DRs couverts :** UX-DR4, UX-DR7

### Epic 5 : Parcours
Les utilisateurs génèrent un circuit automatique ou créent leur propre itinéraire et le suivent en temps réel.
**FRs couverts :** FR21, FR22, FR23, FR24
**UX-DRs couverts :** UX-DR8

### Epic 6 : Points d'Intérêt
Les utilisateurs consultent les POI à proximité, lisent ou écoutent les descriptions des monuments.
**FRs couverts :** FR11, FR12, FR13

### Epic 7 : Compte & Authentification
Les utilisateurs créent un compte, synchronisent leur progression, accèdent depuis un nouvel appareil, et peuvent supprimer leurs données (RGPD).
**FRs couverts :** FR32, FR33, FR34, FR35, FR45, FR46

### Epic 8 : Communauté & Pins
Les utilisateurs créent des pins communautaires, voient les pins des autres, réagissent et signalent — avec modération IA automatique.
**FRs couverts :** FR25, FR26, FR27, FR28, FR29

### Epic 9 : Partage & Social
Les utilisateurs partagent leur carte, publient leurs parcours dans un fil d'actualité, suivent d'autres explorateurs.
**FRs couverts :** FR30, FR31, FR31b, FR31c, FR31d
**UX-DRs couverts :** UX-DR5

### Epic 10 : Notifications
Les utilisateurs reçoivent des notifications contextuelles et gèrent leurs préférences.
**FRs couverts :** FR36, FR37, FR38, FR39

### Epic 11 : Administration & Cold Start
Jo lance le pipeline cold start IA et administre le contenu via Firebase Console.
**FRs couverts :** FR40, FR41, FR42, FR43, FR44

### Epic 12 : Déploiement App Store
L'app est publiée sur l'App Store avec CI/CD complet, conformité Apple et TestFlight.
**FRs couverts :** aucun FR (opérationnel) — exigences architecture

---

## Epic 1 : Fondation & Infrastructure

L'app Flutter tourne, Firebase est configuré sur 3 environnements, le design system Material 3 + tokens Urbink est en place, et tous les patterns UI fondamentaux (navigation, boutons, feedback, accessibilité) sont disponibles pour les epics suivants.

### Story 1.1 : Création du projet Flutter + configuration Firebase multi-environnements

En tant que **développeur**,
Je veux un projet Flutter configuré avec Firebase sur 3 environnements distincts,
Afin d'avoir une base stable et sécurisée pour tout le développement d'Urbink.

**Acceptance Criteria :**

**Given** un environnement de développement local
**When** la commande `flutter create urbink` est exécutée et FlutterFire CLI est lancé
**Then** un projet Flutter valide est créé avec `analysis_options.yaml` lint strict, et trois projets Firebase distincts (urbink-dev / urbink-staging / urbink-prod) sont configurés

**Given** les fichiers `.env.dev` et `.env.prod` en place
**When** l'app se lance en mode dev
**Then** Firebase Auth, Firestore, Storage et FCM sont initialisés et pointent sur `urbink-dev` — aucune recompilation nécessaire pour switcher d'environnement

**Given** la structure feature-based définie dans l'architecture
**When** l'arborescence `lib/features/`, `lib/shared/`, `lib/core/` est créée
**Then** elle correspond exactement à la structure documentée dans l'architecture — `go_router` configuré dans `core/router/app_router.dart`, providers Riverpod globaux dans `core/providers/`

**Given** `flutter_secure_storage` intégré
**When** un token OAuth est reçu lors d'une auth
**Then** il est stocké dans iOS Keychain via `flutter_secure_storage` — jamais en clair dans Firestore ou SharedPreferences

---

### Story 1.2 : Design system Material 3 + tokens Urbink

En tant que **développeur**,
Je veux un design system complet avec les tokens Urbink appliqués à Material 3,
Afin que tous les composants de l'app aient une apparence cohérente sans duplication de code.

**Acceptance Criteria :**

**Given** le fichier `shared/constants/colors.dart`
**When** un widget utilise `Theme.of(context).colorScheme`
**Then** la palette Urbink est active : primary = Ocre #B8832E, secondary = Vert Sauge #5A7A5A, surface = #FAFAF7, onSurface = #1E1610 — aucun hex codé en dur dans les widgets

**Given** le fichier `shared/constants/typography.dart`
**When** un widget utilise `Theme.of(context).textTheme`
**Then** Crimson Pro est la police display/heading, Inter est la police body — Dynamic Type iOS respecté (MediaQuery.textScaleFactor honoré)

**Given** le fichier `shared/constants/spacing.dart`
**When** un widget utilise les constantes d'espacement
**Then** la grille 8px est appliquée : `space-xs=4`, `space-sm=8`, `space-md=16`, `space-lg=24`, `space-xl=32`, `space-2xl=48`

**Given** le ThemeData Material 3 configuré
**When** l'app se lance
**Then** `useMaterial3: true` est actif, les border-radius des composants correspondent aux specs UX (boutons 12px, cards 16px, chips 8px), et le thème passe les tests de rendu golden en mode clair

---

### Story 1.3 : Bottom navigation 5 onglets + bottom sheets conformes UX *(done)*

> **Status : done — PR#2 mergée.** Ce qui a été implémenté : nav Accueil/Carte/Démarrer/Challenges/Vous avec bouton Démarrer central surélevé. La v4 (nav plate, onglets renommés, FAB supprimé) est couverte par **Story 1.7**.

En tant qu'**utilisateur**,
Je veux naviguer entre les 5 sections de l'app via une navigation claire en bas d'écran,
Afin d'accéder rapidement à toutes les fonctionnalités depuis n'importe quel écran.

**Acceptance Criteria :**

**Given** l'app lancée
**When** l'utilisateur regarde le bas de l'écran
**Then** la bottom nav affiche 5 onglets : Accueil 🏠 · Carte 🗺️ · Démarrer ▶ · Challenges 🏆 · Vous 👤 — le bouton Démarrer est central, surélevé de 12px avec ombre Material 3

**Given** un onglet sélectionné
**When** l'utilisateur tape dessus
**Then** l'icône et le label passent en Ocre #B8832E avec un underline 2px — les autres onglets restent en #8C7B6A

**Given** l'état de chaque onglet
**When** l'utilisateur navigue entre onglets puis revient
**Then** chaque onglet mémorise sa position de scroll et son état — `StatefulShellRoute.indexedStack` assure un Navigator dédié par branche

**Given** un bottom sheet déclenché via `showUrbinkBottomSheet()`
**When** il s'élève depuis le bas
**Then** il snape à 40% (aperçu) ou 70% (détail), affiche une pill de drag 4×32px en #D4C8B4, un scrim #1E1610 à 40%, et se ferme par swipe bas ou tap sur le scrim — focus VoiceOver piégé à l'intérieur

**Given** aucune session active
**When** l'utilisateur tape le bouton Démarrer ▶
**Then** le bouton passe en Ocre #B8832E avec icône ⏸, et un bouton Arrêter rouge #C0392B 44px apparaît en haut à droite

**Given** une session active ou en pause
**When** l'utilisateur tape le bouton Arrêter (top right)
**Then** la session s'arrête côté UI : bouton Démarrer → Vert Sauge ▶, bouton Arrêter disparaît — modale de confirmation + écran récapitulatif implémentés en Story 2.5

---

### Story 1.4 : Hiérarchie des boutons + toasts + empty states + feedback haptique

En tant qu'**utilisateur**,
Je veux des retours visuels et haptiques clairs à chaque action,
Afin de savoir immédiatement si mon action a été prise en compte.

**Acceptance Criteria :**

**Given** le widget `UrbinkButton` dans `shared/widgets/`
**When** il est utilisé en variante Primary
**Then** il affiche fond Ocre #B8832E, texte blanc, hauteur 52pt, radius 12px, zone tactile 52×52pt minimum — état loading : spinner blanc inline, bouton désactivé

**Given** le widget `UrbinkButton` en variante Destructif
**When** il est affiché
**Then** texte Rouge #C0392B sur fond transparent — jamais 2 boutons Primary sur le même écran

**Given** le widget `UrbinkSnackBar` dans `shared/widgets/`
**When** une action se termine (succès/info/erreur/warning)
**Then** un SnackBar apparaît en bas au-dessus de la nav, icône à gauche, durée 2.5s, couleur de fond selon type (#2D5A2D / #1E1610 / #8B2020 / #7A5A1E), dismissable par swipe haut

**Given** une action primaire (tap bouton Démarrer, publication pin)
**When** elle se déclenche
**Then** un retour haptique `HeavyImpact` ou `MediumImpact` est émis via `HapticFeedback` Flutter — les actions secondaires émettent `LightImpact`

**Given** un contexte vide (feed sans follows, itinéraires vides, historique vierge)
**When** l'écran se charge sans données
**Then** un empty state s'affiche avec illustration emoji + message chaleureux ≤ 2 lignes + CTA si action directe disponible — jamais un écran blanc ou un message d'erreur générique

---

### Story 1.5 : Accessibilité WCAG 2.1 AA + safe areas iOS

En tant qu'**utilisateur ayant des besoins d'accessibilité**,
Je veux que l'app soit utilisable avec VoiceOver et respecte les réglages d'accessibilité iOS,
Afin de pouvoir explorer la ville sans barrière.

**Acceptance Criteria :**

**Given** chaque élément interactif de l'app
**When** VoiceOver iOS est activé
**Then** chaque bouton, onglet et card a un `Semantics` Flutter avec `label` explicite en français — les onglets bottom nav annoncent "Accueil, onglet 1 sur 5" etc.

**Given** le réglage "Réduire les animations" iOS activé (`MediaQuery.of(context).disableAnimations`)
**When** une animation se déclenche
**Then** elle est remplacée par un fade in/out de 150ms — aucune animation Lottie ni slide complexe

**Given** le réglage Dynamic Type iOS à xxxLarge
**When** l'app affiche du texte
**Then** aucun overflow ni texte tronqué — tous les textes utilisent `Theme.of(context).textTheme`, jamais de fontSize hardcodé

**Given** tous les éléments interactifs
**When** ils sont rendus
**Then** leur zone tactile est ≥ 44×44pt (iOS HIG) — les icônes plus petites ont une hitbox étendue via `SizedBox` + `GestureDetector`

**Given** les écrans avec contenu sous la bottom nav ou la Dynamic Island
**When** l'app tourne sur iPhone SE, iPhone 15 ou iPhone 15 Pro Max
**Then** `MediaQuery.of(context).padding` est utilisé pour toutes les safe areas — aucun contenu rogné par le notch, la Dynamic Island ou le home indicator

---

### Story 1.6 : CI/CD pipeline + monitoring

En tant que **développeur**,
Je veux un pipeline CI/CD automatisé et un monitoring de production,
Afin de détecter les régressions rapidement et publier sur l'App Store en confiance.

**Acceptance Criteria :**

**Given** un push sur `main` ou `develop`
**When** GitHub Actions déclenche `ci.yml`
**Then** `flutter test` s'exécute, le build iOS compile sans erreur, et le résultat est visible dans l'interface GitHub

**Given** un tag de release sur `main`
**When** GitHub Actions déclenche `deploy.yml`
**Then** Fastlane soumet automatiquement un build à TestFlight — les identifiants App Store sont lus depuis les secrets GitHub, jamais committé en dur

**Given** Firebase Crashlytics initialisé dans `main.dart`
**When** une exception non capturée se produit en production
**Then** le crash apparaît dans Firebase Crashlytics avec stack trace complet dans les 5 minutes

**Given** Firebase Analytics initialisé
**When** l'app se lance
**Then** l'événement `app_open` est loggué — visible dans la console Firebase Analytics dans les 24h (délai standard Firebase)

---

### Story 1.7 : Refactoring navigation v4 — 5 onglets plats, suppression FAB Démarrer *(done)*

> **Status : done — implémentée dans PR#17 (story-2.10-create-itineraire, mergée dans develop).** Navigation v4 5 onglets plats, FAB supprimé, routes renommées, SessionStatusBar prend le relais pour l'état session.

En tant qu'**utilisateur**,
Je veux une navigation plate en 5 onglets sans bouton central surélevé,
Afin d'avoir plus d'espace carte et accéder aux sorties via le bottom sheet dédié.

**Acceptance Criteria :**

**Given** le fichier `urbink_bottom_nav.dart` existant (Story 1.3)
**When** la migration v4 est appliquée
**Then** la bottom nav affiche 5 onglets plats : Carte 🗺️ · Parcours 🧭 · Social 👥 · Badges 🏆 · Profil 👤 — hauteur uniforme, `_StartButton` et `_StopButton` supprimés, `isSessionActive` retiré du contrat du widget

**Given** l'app avec session active
**When** l'utilisateur est sur l'onglet Carte
**Then** aucun bouton dans la bottom nav ne change d'état — la `SessionStatusBar` (Story 2.10) et le bouton Arrêter ■ (Story 2.10) sont les seuls indicateurs visuels de session

**Given** les routes GoRouter existantes pointant vers les 5 onglets
**When** la migration est appliquée
**Then** les routes `Accueil`, `Challenges`, `Vous` sont renommées `Social`, `Badges`, `Profil` — les routes carte et parcours inchangées ; tous les tests de navigation mis à jour

**Given** les Semantics VoiceOver existants (Story 1.3)
**When** la migration est appliquée
**Then** les annonces sont mises à jour : "Carte, onglet 1 sur 5" / "Parcours, onglet 2 sur 5" etc. — aucune référence à "Démarrer"

---

### Story 1.8 : Firebase Anonymous Auth au premier lancement *(avancée depuis Epic 7)*

> **Priorité critique :** Sans cette story, `currentUidProvider` retourne `null` et toutes les écritures Firestore (sessions, rues, badges) sont silencieusement ignorées. À implémenter **avant Epic 3** pour que les données historiques soient réellement persistées.
> Story 7.1 est conservée dans Epic 7 pour référence mais son implémentation se fait ici.

En tant que **nouvel utilisateur**,
Je veux explorer l'app sans créer de compte,
Afin de découvrir la valeur d'Urbink avant de m'engager. (FR32)

**Acceptance Criteria :**

**Given** le premier lancement de l'app (après l'onboarding Story 2.7)
**When** l'utilisateur accepte la politique de confidentialité
**Then** `FirebaseAuth.instance.signInAnonymously()` est appelé silencieusement — un UID Firestore est créé, `currentUidProvider` retourne une valeur non-null, la progression commence à être sauvegardée immédiatement

**Given** un utilisateur avec un UID anonyme déjà existant (app rouverte)
**When** l'app démarre
**Then** `FirebaseAuth.instance.currentUser` restaure la session — aucun nouveau `signInAnonymously()` n'est appelé ; l'UID persiste via iOS Keychain (NFR13)

**Given** un utilisateur en mode invité
**When** il tente d'accéder à des fonctionnalités sociales (Epic 9)
**Then** un message s'affiche : "Crée un compte pour partager tes explorations" avec CTA "Créer un compte" — implémentation complète du compte en Story 7.2

---

### Story 1.9 : Firestore Security Rules + indexes

> **Dépendance :** Story 1.8 done (UID non-null requis pour valider les règles). À implémenter avant toute beta TestFlight pour éviter l'exposition des données utilisateurs.

En tant que **développeur / DPO**,
Je veux que les données Firestore soient protégées par des règles d'accès strictes,
Afin qu'aucun utilisateur ne puisse lire ou écrire les données d'un autre.

**Acceptance Criteria :**

**Given** les collections `/users/{userId}/sessions/`, `/users/{userId}/streets/`
**When** un utilisateur authentifié tente de lire/écrire
**Then** les règles Firestore autorisent uniquement `request.auth.uid == userId` — les emulators Firebase valident les règles sans erreur

**Given** un utilisateur non authentifié (ou UID différent)
**When** il tente d'accéder à `/users/{userId}/` (read ou write)
**Then** la requête est refusée avec `PERMISSION_DENIED` — testé via `firebase emulators:exec`

**Given** la query `aggregationProvider` sur `/users/{uid}/sessions/`
**When** elle s'exécute en production
**Then** l'index composite `sessionStart ASC + streetIds ARRAY` est déployé via `firestore.indexes.json` — pas de `FAILED_PRECONDITION` en console

**Given** les queries futures (Story 3.2 filtrage par date)
**When** elles filtrent sur `sessionStart`
**Then** l'index `sessionStart DESC` sur la collection `sessions` est présent dans `firestore.indexes.json`

---

## Epic 2 : Carte & Exploration GPS

L'utilisateur ouvre l'app, voit la carte complète de Paris, marche, et ses rues se colorient en temps réel — c'est le moment "aha" fondateur d'Urbink.

### Story 2.1 : Affichage carte OSM plein écran (flutter_map)

En tant qu'**utilisateur**,
Je veux voir la carte complète de Paris dès l'ouverture de l'app,
Afin de me situer et de commencer à explorer immédiatement.

**Acceptance Criteria :**

**Given** l'app lancée (onglet Carte ou écran principal)
**When** la carte se charge
**Then** les tuiles OSM s'affichent en plein écran (100% de la surface) en moins de 2 secondes — aucune zone masquée, aucun fog of war (FR10, NFR1)

**Given** la carte affichée
**When** l'utilisateur effectue un pinch-to-zoom ou un pan
**Then** la carte répond fluidement sans saccade — zoom min/max configuré dans `map_constants.dart`

**Given** la carte affichée
**When** elle est visible
**Then** les crédits "© OpenStreetMap contributors" apparaissent en bas de la carte conformément à la licence ODbL (FR47)

**Given** flutter_map configuré
**When** les tuiles OSM ne se chargent pas (réseau absent)
**Then** les tuiles en cache s'affichent — un message discret informe l'utilisateur sans bloquer la carte

---

### Story 2.2 : Tracking GPS en temps réel + snap to road Nominatim

En tant qu'**utilisateur**,
Je veux que l'app suive ma position GPS en temps réel et identifie la rue sur laquelle je marche,
Afin que mes rues se colorient avec précision.

**Acceptance Criteria :**

**Given** la permission GPS accordée
**When** une session est active
**Then** `gps_tracking_service.dart` émet la position GPS toutes les ~10 mètres via un stream Riverpod — le tracking continue en arrière-plan (background location iOS)

**Given** une position GPS reçue
**When** `snap_to_road_service.dart` appelle Nominatim
**Then** la requête aboutit en ≤ 200ms en conditions normales et retourne le `streetId` OSM le plus proche (FR2, NFR2)

**Given** une erreur réseau lors de l'appel Nominatim
**When** l'échec se produit
**Then** 3 tentatives automatiques avec backoff exponentiel sont effectuées — en cas d'échec persistant, la session continue sans snap to road, le segment GPS est conservé localement pour retry ultérieur

**Given** `gps_tracking_service.dart` actif
**When** l'app est mise en arrière-plan par l'utilisateur
**Then** le tracking GPS continue — la permission "Toujours autoriser" est demandée au premier démarrage de session avec la justification "Urbink trace ton exploration en temps réel"

---

### Story 2.3 : Composant MapStreetOverlay — coloration des rues explorées

En tant qu'**utilisateur**,
Je veux voir mes rues explorées se colorier sur la carte en temps réel,
Afin de visualiser mon territoire personnel d'exploration.

**Acceptance Criteria :**

**Given** une rue identifiée via snap to road pendant une session
**When** le `streetId` est reçu
**Then** la polyline correspondante s'affiche sur `MapStreetOverlay` en Vert Sauge #5A7A5A, opacité 0.75, dans un délai ≤ 1 seconde perçue (FR3, NFR2)

**Given** `MapStreetOverlay` en état `recording`
**When** la rue actuelle est en cours d'exploration
**Then** la polyline de la rue courante est animée en #6A9A6A (légèrement plus clair) pour signaler l'activité en cours

**Given** des milliers de segments colorés accumulés
**When** la carte est affichée avec l'historique complet
**Then** le rendu reste fluide (≥ 30 fps) — les polylines sont simplifiées selon le niveau de zoom via `flutter_map` layer optimization

**Given** `MapStreetOverlay` en état `idle` (pas de session)
**When** l'utilisateur consulte sa carte
**Then** toutes les rues explorées sont affichées en Vert Sauge — les rues non explorées restent au fond OSM standard

---

### Story 2.4 : Composant SessionCounter + TransportModeSelector — UI session active *(done)*

> **Status : done — PR#10 mergée.** Ce qui a été implémenté : `SessionCounter` pill top-center + `TransportModeSelector` 3 chips manuels. La v4 (SessionStatusBar 44px + auto-détection, suppression du sélecteur) est couverte par **Story 2.10**.

En tant qu'**utilisateur**,
Je veux voir mes métriques de session en temps réel et choisir mon mode de déplacement,
Afin de suivre ma progression pendant que j'explore.

**Acceptance Criteria :**

**Given** une session active
**When** `SessionCounter` est affiché
**Then** il apparaît en pill semi-transparent (#1E1610 @ 85%) en position top-center, safe area + 8pt, affichant `N rues · X.Xkm · HH:MM` mis à jour en temps réel

**Given** `SessionCounter` en état `acquiring`
**When** le GPS n'a pas encore acquis un signal suffisant
**Then** l'indicateur GPS pulse en orange — dès que le signal est acquis, il passe au vert fixe

**Given** le bottom sheet Démarrer
**When** l'utilisateur doit choisir son mode de transport
**Then** `TransportModeSelector` affiche 3 chips segmentés 🚶 · 🚴 · 🚗 — le chip actif a fond Ocre + texte blanc, les inactifs fond #F4F2ED — le dernier choix est mémorisé (SharedPreferences)

**Given** `SessionCounter` en variante Extended (itinéraire)
**When** un itinéraire est en cours
**Then** une barre de progression de l'itinéraire s'affiche sous les 3 métriques (X/N points atteints)

---

### Story 2.5 : Démarrage / arrêt / reprise de session circuit libre + sauvegarde Firestore *(v4)*

En tant qu'**utilisateur**,
Je veux démarrer une session circuit libre depuis l'écran Carte, l'arrêter, et que ma progression soit sauvegardée sans perte,
Afin de ne jamais perdre mes rues explorées même si l'app est fermée brutalement.

**Acceptance Criteria :**

**Given** l'onglet Carte ouvert, bottom sheet déroulé (peek ou expanded)
**When** l'utilisateur tape "▶ Démarrer la sortie" en mode Circuit libre
**Then** la session démarre en ≤ 1 seconde — le bottom sheet se collapse, `SessionStatusBar` Terra Cotta apparaît, le bouton Arrêter ■ 52×52px s'affiche bas-droite (FR1)

**Given** une session circuit libre en cours
**When** l'utilisateur tape le bouton Arrêter ■ bas-droite (posé par Story 1.3)
**Then** un Dialog de confirmation s'affiche ("Arrêter la session ?") — si confirmé, la session est sauvegardée dans Firestore avec `sessionStart`, `sessionEnd`, `mode`, `streetIds[]`, `distanceMeters`, puis un écran récapitulatif affiche le tracé, les stats (rues/km/durée) et les badges débloqués (FR5, FR6)

**Given** une session sauvegardée dans Firestore
**When** la sauvegarde échoue (réseau absent)
**Then** la session est d'abord persistée localement via `sqflite` — une re-sync automatique est tentée dès la reconnexion réseau (NFR6, NFR7)

**Given** l'app fermée brutalement pendant une session
**When** l'utilisateur relance l'app
**Then** la session est reconstituée depuis les données GPS locales `sqflite` et un Dialog propose "Reprendre la session précédente ?" (FR5)

---

### Story 2.6 : Détection automatique du mode de déplacement

En tant qu'**utilisateur**,
Je veux que l'app détecte automatiquement si je suis à pied, en vélo ou en voiture,
Afin de ne pas avoir à configurer manuellement mon mode avant chaque session.

**Acceptance Criteria :**

**Given** une session active en mode "Auto-detect"
**When** la vitesse GPS est < 7 km/h en moyenne sur 30 secondes
**Then** le mode est classifié `marche` — l'icône dans `SessionStatusBar` affiche 🚶

**Given** une session active
**When** la vitesse GPS est entre 7 et 30 km/h
**Then** le mode est classifié `vélo` — l'icône dans `SessionStatusBar` affiche 🚴

**Given** une session active
**When** la vitesse GPS est > 30 km/h
**Then** le mode est classifié `voiture` — l'icône dans `SessionStatusBar` affiche 🚗

**Given** un changement de mode détecté en cours de session
**When** le mode bascule (ex : marche → voiture dans un bus)
**Then** le mode de la session est mis à jour dans Firestore — le résumé de session affiche le mode dominant (FR4)

---

### Story 2.7 : Onboarding permission GPS + politique de confidentialité + crédits OSM

En tant que **nouvel utilisateur**,
Je veux être informé de l'usage de mes données GPS et donner mon consentement,
Afin de démarrer l'app en confiance et en conformité RGPD.

**Acceptance Criteria :**

**Given** le premier lancement de l'app
**When** l'écran s'affiche
**Then** un écran de politique de confidentialité s'affiche avec un bouton "Accepter et continuer" — aucune fonctionnalité accessible sans acceptation (FR45)

**Given** l'utilisateur ayant accepté la politique de confidentialité
**When** il démarre sa première session
**Then** la popup iOS de permission GPS s'affiche avec le message : "Urbink trace ton exploration en temps réel pour colorier les rues que tu parcours" — l'option "Toujours autoriser" est recommandée

**Given** l'utilisateur ayant refusé la permission GPS
**When** il tente de démarrer une session
**Then** un message s'affiche : "Le GPS est requis pour colorier tes rues" avec un lien direct vers les Réglages iOS — aucun crash

**Given** Firebase Anonymous Auth
**When** l'app se lance pour la première fois (après acceptation politique)
**Then** `signInAnonymously()` est appelé silencieusement — un UID Firestore est créé sans aucune action utilisateur requise (FR32)

---

### Story 2.8 : Tracking passif toujours actif — couche 1 (FR0)

En tant qu'**utilisateur** (y compris invité),
Je veux que les rues se colorient automatiquement dès que j'ouvre l'app et que je marche, sans aucune action de ma part,
Afin de voir mon territoire exploré se construire librement, même sans créer de compte ou démarrer une session.

**Acceptance Criteria :**

**Given** l'app lancée et la permission GPS accordée
**When** l'utilisateur se déplace (même sans session démarrée)
**Then** `gps_tracking_service.dart` émet des positions et le système snap-to-road colorie les rues via `MapStreetOverlay` — le tracking passif est actif indépendamment de toute session enregistrée (FR0)

**Given** un utilisateur en mode invité (Anonymous Auth)
**When** il marche avec l'app ouverte
**Then** les rues colorées sont sauvegardées sous son UID anonyme Firestore — la progression est conservée si l'utilisateur crée un compte ultérieurement via `linkWithCredential()`

**Given** le toggle "Zones ON/OFF" (FR10b)
**When** l'utilisateur tape le pill 🟢 Zones bas-gauche
**Then** l'affichage des rues colorées est activé/désactivé sur la carte — le tracking passif continue en arrière-plan indépendamment de l'état du toggle

**Given** l'app mise en arrière-plan
**When** l'utilisateur marche téléphone en poche
**Then** le tracking passif continue (background location iOS) et les rues se colorient au retour au premier plan

---

### Story 2.9 : Bottom sheet "Carte & Sorties" — DraggableScrollableSheet (FR1, FR1b)

En tant qu'**utilisateur**,
Je veux accéder aux options de sortie (circuit libre ou itinéraire) en déroulant un panneau depuis l'écran Carte,
Afin de démarrer une sortie enregistrée ou lancer un itinéraire sans quitter la vue carte.

**Acceptance Criteria :**

**Given** l'écran Carte affiché
**When** l'utilisateur tire vers le haut depuis le bas de l'écran
**Then** un `DraggableScrollableSheet` s'élève avec 3 snap points : 72px (collapsed — handle + hint "↑ Dérouler pour démarrer une sortie") / ~260px (peek — section Démarrer une sortie visible) / 65% écran (expanded — contenu complet)

**Given** le sheet en état peek ou expanded
**When** la section "Démarrer une sortie" est visible
**Then** deux cards sont affichées côte à côte : "Circuit libre 🚶 · ✓ Par défaut" (fond Vert Sauge léger, bordure Vert Sauge) et "Itinéraire 🗺️ · Mode GPS →" (fond #F4F2ED) ; une info-chip "🤖 Mode auto-détecté · GPS prêt" est affichée sous les cards ; le bouton "▶ Démarrer la sortie" (fond Vert Sauge) lance la session en mode sélectionné

**Given** l'utilisateur tape la card "Itinéraire"
**When** la card est sélectionnée
**Then** le sheet anime un sub-slide (AnimatedSwitcher) vers la vue liste d'itinéraires avec bouton "← Retour" et bouton "+ Créer" — **pas de GoRouter push** à cette étape ; seul le bouton "Créer" déclenche un push vers l'écran dédié

**Given** une session circuit libre active
**When** elle est en cours
**Then** le sheet est collapsed et non déroulable — seuls la `SessionStatusBar` et le bouton Arrêter ■ sont accessibles

---

### Story 2.10 : Refactoring UI session — SessionStatusBar + suppression TransportModeSelector *(remplace Story 2.4)*

> **Dépendance :** Story 2.4 done (SessionCounter + TransportModeSelector implémentés). Cette story remplace les deux composants par la v4. À implémenter après Story 2.9 (bottom sheet).

En tant qu'**utilisateur**,
Je veux voir l'état de ma session dans une barre contextuelle en haut de la carte, sans saisir mon mode de déplacement,
Afin d'avoir un retour clair sans friction et sans encombrer l'écran avec des chips de sélection.

**Acceptance Criteria :**

**Given** `SessionCounter` pill top-center existant (Story 2.4)
**When** la migration v4 est appliquée
**Then** `SessionCounter` est supprimé du widget tree ; `SessionStatusBar` (44px, `AbsolutePositioned` sous la status bar iOS, fond Terra Cotta #A84E2C) le remplace pendant une session circuit libre — `TransportModeSelector` est entièrement retiré de l'app (widget + provider + SharedPreferences key)

**Given** `SessionStatusBar` en session circuit libre active
**When** elle est affichée
**Then** elle affiche `● X.Xkm · N rues · HH:MM` + icône mode auto-détecté (🚶/🚴/🚗) — le point ● pulse en orange pendant l'acquisition GPS, passe vert fixe dès signal acquis

**Given** un itinéraire GPS actif (Story 2.9)
**When** il est en cours
**Then** `SessionStatusBar` Ocre #B8832E affiche `étape X/N · [Nom POI suivant] · X.Xkm` — pas de distance totale ni de compteur de rues (pas d'enregistrement)

**Given** le bouton Arrêter de Story 1.3 (top-right, 44px)
**When** la migration v4 est appliquée
**Then** il est repositionné bas-droite 52×52px rounded rect — `sessionActiveProvider` reste le point d'accroche ; la logique de confirmation (Story 2.5) est inchangée

**Given** le mode de déplacement qui change en cours de session
**When** la vitesse GPS franchit un seuil (7 km/h ou 30 km/h)
**Then** l'icône dans `SessionStatusBar` se met à jour silencieusement — aucun toast, aucune confirmation requise (Story 2.6 inchangée)

---

## Epic 3 : Historique & Filtrage Temporel

L'utilisateur visualise toute son exploration agrégée sur la carte, filtre par période, suit sa progression par quartier dans l'onglet Vous, et gère les couches visibles sur la carte.

### Story 3.1 : Moteur d'agrégation des sessions + affichage carte historique

En tant qu'**utilisateur**,
Je veux voir sur la carte toutes les rues que j'ai explorées depuis le début,
Afin de visualiser l'empreinte complète de mon exploration urbaine.

**Acceptance Criteria :**

**Given** plusieurs sessions sauvegardées dans Firestore (`/users/{userId}/sessions/`)
**When** l'utilisateur ouvre l'onglet Carte
**Then** `aggregation_provider.dart` calcule l'union de tous les `streetIds` de toutes les sessions et les affiche via `MapStreetOverlay` en état `idle` (FR7)

**Given** l'agrégation calculée
**When** elle est affichée sur la carte
**Then** le rendu s'effectue en ≤ 2 secondes même pour un historique de 12 mois (NFR4)

**Given** une nouvelle session terminée
**When** les nouvelles rues sont sauvegardées dans Firestore
**Then** `MapStreetOverlay` se met à jour automatiquement via un `StreamProvider` Riverpod — aucun rechargement manuel requis

---

### Story 3.2 : Filtrage temporel (aujourd'hui / semaine / mois / tout l'historique)

En tant qu'**utilisateur**,
Je veux filtrer l'affichage de mes rues explorées par période,
Afin de voir ma progression sur différentes échelles de temps.

**Acceptance Criteria :**

**Given** la barre de filtrage temporelle (`time_filter_bar.dart`)
**When** l'utilisateur sélectionne "Aujourd'hui"
**Then** seules les rues des sessions dont `sessionStart` est dans le jour courant (minuit → maintenant) sont affichées (FR8)

**Given** le filtre "Cette semaine" sélectionné
**When** la carte se met à jour
**Then** les rues des 7 derniers jours glissants sont affichées en ≤ 2 secondes (NFR4)

**Given** le filtre "Tout l'historique" sélectionné
**When** la carte se met à jour
**Then** l'union complète de toutes les sessions est affichée — c'est la vue par défaut à l'ouverture

**Given** le filtre actif
**When** l'utilisateur change de filtre
**Then** la transition est fluide (fade entre les deux états de coloration) — le filtre sélectionné est mémorisé jusqu'à la prochaine ouverture de l'app

---

### Story 3.3 : Composant WeekHistogram + onglet Vous (historique personnel)

En tant qu'**utilisateur**,
Je veux voir un résumé visuel de mon activité hebdomadaire et la liste de mes sorties,
Afin de suivre mes habitudes d'exploration dans l'onglet Vous.

**Acceptance Criteria :**

**Given** l'onglet Vous ouvert
**When** l'écran se charge
**Then** `WeekHistogram` affiche 7 barres L-D, hauteur proportionnelle aux rues explorées ce jour — le jour actuel en Ocre #B8832E, jours sans activité en barre fantôme #F0EDE8 (UX-DR6)

**Given** `WeekHistogram` en état `empty` (aucune session cette semaine)
**When** il est affiché
**Then** toutes les barres sont fantômes et un message "Ta première sortie cette semaine n'attend que toi" s'affiche avec CTA "Démarrer"

**Given** l'écran Vous sous le WeekHistogram
**When** il affiche la liste des sorties
**Then** un toggle "Vue simple / Vue feed" est visible — Vue simple : `ListTile` compact (date · rues · km · durée) ; Vue feed : `FeedActivityItem` avec tracé miniature (à activer à l'Epic 9)

**Given** une barre du `WeekHistogram` tapée
**When** l'utilisateur tape sur un jour
**Then** la liste des sorties est filtrée pour afficher uniquement les sessions de ce jour

---

### Story 3.4 : Toggle couches carte (monuments, pins, quartiers)

En tant qu'**utilisateur**,
Je veux activer ou désactiver les différentes couches d'information sur la carte,
Afin de personnaliser ma vue selon ce que je veux voir.

**Acceptance Criteria :**

**Given** la carte affichée
**When** l'utilisateur accède aux options de couches
**Then** 3 toggles sont disponibles : Monuments 🏛️ · Pins 📷 · Quartiers 🗺️ — activés par défaut (FR14)

**Given** le toggle Monuments désactivé
**When** la carte se met à jour
**Then** tous les marqueurs de monuments disparaissent de la carte sans rechargement — réactivé → ils réapparaissent

**Given** le toggle Quartiers activé
**When** la carte est affichée
**Then** les frontières des quartiers de Paris sont superposées à la carte avec une couleur distincte — ceux complétés à 100% ont une teinte dorée

**Given** l'état des toggles
**When** l'utilisateur ferme et rouvre l'app
**Then** les préférences de couches sont mémorisées (SharedPreferences)

---

## Epic 4 : Gamification & Progression

L'utilisateur débloque des badges monuments et quartiers, découvre des secrets locaux, active des objectifs thématiques — avec des animations de célébration mémorables.

### Story 4.1 : Système de quartiers — structure Firestore + calcul progression %

En tant qu'**utilisateur**,
Je veux voir le pourcentage de rues que j'ai explorées dans chaque quartier de Paris,
Afin de savoir où concentrer mes prochaines explorations.

**Acceptance Criteria :**

**Given** la collection `/quartiers/{quartierId}` dans Firestore
**When** le système est initialisé
**Then** les 20 arrondissements de Paris sont présents avec leurs listes de `streetIds` OSM associés et un champ `secretLocal` (FR15)

**Given** une rue explorée lors d'une session
**When** son `streetId` est ajouté à `/users/{userId}/streets/`
**Then** `quartiers_provider.dart` recalcule le pourcentage de complétion du quartier correspondant : `exploredStreets / totalStreets * 100`

**Given** l'écran Challenges → section Quartiers
**When** il affiche la liste des quartiers
**Then** chaque quartier affiche une `LinearProgressIndicator` avec son % de complétion — triés par proximité de complétion (% descendant) (FR15)

---

### Story 4.2 : Détection complétion quartier + badge + révélation secret local

En tant qu'**utilisateur**,
Je veux être averti et récompensé quand j'ai exploré toutes les rues d'un quartier,
Afin de vivre un moment de fierté et de découvrir le secret local associé.

**Acceptance Criteria :**

**Given** la Cloud Function `on_quartier_completed.go` configurée
**When** une rue explorée porte le compteur de complétion d'un quartier à 100%
**Then** la Cloud Function déclenche : création du badge quartier dans `/users/{userId}/badges/`, lecture du `secretLocal`, envoi de notification push FCM (FR16, FR17)

**Given** l'événement de complétion reçu par l'app
**When** il est traité par `quartiers_provider.dart`
**Then** `CelebrationOverlay` en état `district` est déclenché — durée 3-4s, animations Lottie particules dorées, titre "🏆 Quartier [Nom] complété !", sous-titre affichant le secret local

**Given** le secret local révélé dans `CelebrationOverlay`
**When** l'utilisateur ferme l'overlay
**Then** le quartier complété s'affiche en teinte dorée sur la carte — son badge apparaît dans l'écran Challenges → Badges Quartiers

---

### Story 4.3 : Composant CelebrationOverlay — animations de célébration

En tant qu'**utilisateur**,
Je veux voir une animation festive plein écran lors d'un déblocage ou d'une complétion,
Afin de ressentir la fierté de l'accomplissement.

**Acceptance Criteria :**

**Given** un badge monument débloqué
**When** `CelebrationOverlay` est déclenché en état `badge`
**Then** un overlay plein écran s'affiche : fond noir semi-transparent, icône badge en scale-in 300ms, particules Lottie dorées, titre du badge, durée 2-3s — dismissable par tap (UX-DR4)

**Given** un quartier complété
**When** `CelebrationOverlay` est déclenché en état `district`
**Then** durée 3-4s avec secret local révélé sous le titre, bouton "Partager" + "Continuer" visibles — auto-dismiss après 5s si pas de tap

**Given** le réglage "Réduire les animations" iOS activé
**When** `CelebrationOverlay` se déclenche
**Then** toutes les animations Lottie sont remplacées par un fade in/out de 150ms — `accessibilityAnnouncement` annonce le texte de célébration à VoiceOver

**Given** plusieurs badges débloqués dans la même session
**When** ils se déclenchent en séquence
**Then** ils s'affichent en file d'attente — l'un après l'autre, pas simultanément

---

### Story 4.4 : Badges monuments — détection proximité GPS

En tant qu'**utilisateur**,
Je veux débloquer automatiquement un badge quand je passe près d'un monument emblématique,
Afin d'être récompensé pour ma présence physique sur le lieu.

**Acceptance Criteria :**

**Given** la Cloud Function `on_monument_proximity.go`
**When** la position GPS d'un utilisateur en session est à ≤ 100m d'un monument configuré
**Then** la Cloud Function vérifie que le badge n'est pas déjà débloqué, puis le crée dans `/users/{userId}/badges/` et déclenche FCM (FR18)

**Given** un badge monument créé dans Firestore
**When** `badges_provider.dart` reçoit la mise à jour via `StreamProvider`
**Then** `CelebrationOverlay` est déclenché côté app en état `badge` — le feedback haptique fort est émis

**Given** un monument dont le badge est déjà débloqué
**When** l'utilisateur repasse à proximité
**Then** aucun déclenchement — le badge n'est débloqué qu'une seule fois

---

### Story 4.5 : Composant BadgeGrid + écran Challenges

En tant qu'**utilisateur**,
Je veux voir tous mes badges dans un écran dédié et découvrir ceux que je n'ai pas encore,
Afin d'être motivé à explorer de nouveaux lieux.

**Acceptance Criteria :**

**Given** l'onglet Challenges ouvert
**When** la section Badges Monuments est affichée
**Then** `BadgeGrid` affiche une grille 4 colonnes — badges débloqués en couleur complète + date, badges verrouillés en grisé (opacité 40%) + indice textuel court (UX-DR7, FR19)

**Given** un badge verrouillé tapé
**When** l'utilisateur tape dessus
**Then** un bottom sheet s'affiche : nom du monument, indice "Passe à X mètres pour débloquer", CTA "Voir sur carte" qui centre la carte sur le monument

**Given** un badge nouvellement débloqué
**When** il apparaît pour la première fois dans `BadgeGrid`
**Then** une animation scale-in est jouée + un chip "Nouveau !" superposé s'affiche pendant 3 secondes

---

### Story 4.6 : Objectifs thématiques — activation et suivi progression

En tant qu'**utilisateur**,
Je veux activer des objectifs thématiques (toutes les églises de Paris, tous les parcs...) et suivre ma progression,
Afin d'explorer la ville avec un but précis et varié.

**Acceptance Criteria :**

**Given** l'onglet Challenges → section Objectifs thématiques
**When** l'écran est affiché
**Then** les objectifs disponibles sont listés sous forme de cards : titre, description, icône, barre de progression N/Total, mode de déplacement compatible (FR20)

**Given** un objectif thématique activé par l'utilisateur
**When** il explore et passe près d'un point de l'objectif
**Then** le point est coché automatiquement dans `/users/{userId}/badges/{objectifId}` — la progression se met à jour dans l'écran Challenges

**Given** un objectif complété à 100%
**When** le dernier point est atteint
**Then** `CelebrationOverlay` se déclenche en état `badge` avec le badge thématique associé

**Given** la liste des points d'un objectif
**When** l'utilisateur tape sur un point non atteint
**Then** l'onglet Carte s'ouvre et se centre sur ce point avec un marqueur temporaire

---

## Epic 5 : Parcours

L'utilisateur génère un circuit automatique ou trace son propre itinéraire et le suit en temps réel — les rues se colorient au fil de la progression.

### Story 5.1 : Composant RouteMapPreview + modèle de données parcours Firestore

En tant que **développeur**,
Je veux le composant RouteMapPreview et la structure de données des parcours en Firestore,
Afin que les autres stories de cet epic puissent s'appuyer sur ces fondations.

**Acceptance Criteria :**

**Given** la collection `/users/{userId}/parcours/{parcoursId}` dans Firestore
**When** un parcours est créé
**Then** il contient : `name`, `points[]` (lat/lng), `estimatedDistance`, `estimatedDuration`, `mode`, `type` (auto/custom), `createdAt` (FR21, FR22)

**Given** le widget `RouteMapPreview`
**When** il reçoit une liste de points GPS
**Then** il affiche un fond SVG schématique warm-off-white avec une polyline Vert Sauge (sorties) ou Ocre (itinéraires planifiés), point de départ vert, point d'arrivée ocre (UX-DR8)

**Given** `RouteMapPreview` en variante `small` (176×85px)
**When** il est utilisé dans un `ListTile` ou `FeedActivityItem`
**Then** il s'affiche correctement sans overflow — variante `medium` full-width 16:9 dans l'écran détail parcours, `thumbnail` 48×48px dans les listes compactes

---

### Story 5.2 : Génération parcours automatique (Cloud Function)

En tant qu'**utilisateur**,
Je veux générer en un tap un circuit couvrant le maximum de rues non explorées autour de moi,
Afin d'explorer efficacement sans avoir à planifier. (FR21)

**Acceptance Criteria :**

**Given** l'onglet Parcours → section "Parcours automatique" (ou depuis le bottom sheet Carte & Sorties → Itinéraire → Générer automatiquement)
**When** l'utilisateur choisit une durée cible (15 / 30 / 45 / 60 min) et tape "Générer"
**Then** la Cloud Function `generate_parcours.go` est appelée — elle retourne un circuit en ≤ 3 secondes (NFR3)

**Given** la Cloud Function `generate_parcours.go`
**When** elle calcule le circuit
**Then** elle maximise les rues non encore dans `/users/{userId}/streets/`, inclut 2-3 POI sur le chemin, respecte la durée cible selon le mode de transport choisi

**Given** le parcours généré retourné
**When** il s'affiche dans l'app
**Then** `RouteMapPreview` en variante `medium` montre le tracé — distance estimée, durée et nombre de rues nouvelles sont affichés — un CTA "Démarrer ce parcours" est disponible

**Given** un appel à la Cloud Function qui échoue
**When** le timeout est atteint (> 5s)
**Then** un message d'erreur bienveillant s'affiche : "Impossible de générer un parcours pour l'instant, réessaie dans quelques instants"

---

### Story 5.3 : Création parcours personnalisé (traçage manuel sur carte)

En tant qu'**utilisateur**,
Je veux tracer manuellement mon propre itinéraire sur la carte et le sauvegarder,
Afin de planifier à l'avance un circuit qui me tient à cœur. (FR22)

**Acceptance Criteria :**

**Given** l'onglet Carte → bouton "Créer un itinéraire"
**When** le mode création est activé
**Then** `MapStreetOverlay` passe en état `creation` — un curseur "+" apparaît, l'utilisateur peut taper sur la carte pour ajouter des points (max 20 points au MVP)

**Given** des points placés sur la carte
**When** ils sont connectés
**Then** une ligne se trace entre les points via snap to road — distance totale et durée estimée sont mises à jour en temps réel sous la carte

**Given** l'itinéraire terminé (≥ 2 points)
**When** l'utilisateur tape "Sauvegarder"
**Then** un `TextField` s'affiche pour nommer l'itinéraire (nom auto "Itinéraire du [date]" si vide) — sauvegardé dans `/users/{userId}/parcours/`

**Given** la liste "Mes itinéraires" dans l'onglet Carte
**When** l'utilisateur consulte ses itinéraires
**Then** chaque itinéraire affiche `RouteMapPreview` small + nom + distance + date — actions : Démarrer / Modifier / Supprimer (confirmation Dialog)

---

### Story 5.4 : Guidage temps réel sur parcours + coloration progressive

En tant qu'**utilisateur**,
Je veux suivre un itinéraire en temps réel avec un guidage visuel,
Afin de ne pas me perdre et de voir mes progrès sur le parcours. (FR23, FR24)

**Acceptance Criteria :**

**Given** un itinéraire démarré (automatique ou personnalisé)
**When** la session de guidage commence
**Then** `MapStreetOverlay` passe en état `playback` superposé à `recording` — le prochain point cible est mis en évidence sur la carte avec un marqueur pulsant

**Given** le guidage actif
**When** l'utilisateur atteint un point du parcours (dans un rayon de 30m)
**Then** le point est coché — la `SessionStatusBar` Ocre met à jour l'étape (X/N points) et le prochain POI devient la cible

**Given** les rues traversées pendant le parcours guidé
**When** elles sont parcourues
**Then** elles se colorient en temps réel via `MapStreetOverlay` recording — exactement comme une session libre (FR24)

**Given** le parcours terminé (dernier point atteint)
**When** la complétion est détectée
**Then** `CelebrationOverlay` en état `itinerary` s'affiche (2s) avec % de rues nouvelles explorées — la session est sauvegardée normalement dans Firestore

---

## Epic 6 : Points d'Intérêt

L'utilisateur consulte les POI à proximité de sa position, lit la description des monuments et peut les écouter en audio.

### Story 6.1 : Données monuments Paris dans Firestore + affichage sur carte

En tant qu'**utilisateur**,
Je veux voir les monuments emblématiques de Paris sur la carte,
Afin de savoir où ils se trouvent par rapport à mon exploration.

**Acceptance Criteria :**

**Given** la collection `/monuments/{monumentId}` dans Firestore
**When** le système est initialisé (via Epic 11 cold start)
**Then** les monuments principaux de Paris (Tour Eiffel, Notre-Dame, Louvre, Sacré-Cœur, etc.) sont présents avec : nom, position GPS, rayon de proximité (m), description, wikidataId, badgeId associé

**Given** la couche Monuments activée (toggle Epic 3)
**When** la carte est affichée avec zoom suffisant
**Then** des marqueurs stylisés Urbink apparaissent aux positions des monuments — clustering automatique aux faibles niveaux de zoom via flutter_map clustering layer

**Given** un marqueur monument tapé
**When** l'utilisateur tape dessus
**Then** un bottom sheet s'élève avec : nom du monument, aperçu description (2-3 lignes), CTA "Lire plus" et CTA "🔊 Écouter"

---

### Story 6.2 : Bouton "À proximité" + liste POI à proximité

En tant qu'**utilisateur**,
Je veux consulter les points d'intérêt proches de ma position actuelle,
Afin de découvrir ce qui se trouve autour de moi en temps réel. (FR11)

**Acceptance Criteria :**

**Given** l'écran Carte avec un bouton "À proximité" (`poi_proximity_button.dart`)
**When** l'utilisateur tape ce bouton
**Then** une liste de POI dans un rayon de 500m s'affiche en ≤ 1 seconde, triée par distance croissante (NFR5)

**Given** la liste de POI affichée
**When** elle est visible
**Then** chaque item affiche : nom, distance, icône de catégorie, et si le badge associé est débloqué (✓) ou non (🔒)

**Given** un POI sélectionné dans la liste
**When** l'utilisateur tape dessus
**Then** la carte se centre sur ce POI et le marqueur s'anime — le bottom sheet du monument s'ouvre

---

### Story 6.3 : Description textuelle monument (Wikidata API)

En tant qu'**utilisateur**,
Je veux lire la description d'un monument directement dans l'app,
Afin d'apprendre l'histoire des lieux que j'explore. (FR12)

**Acceptance Criteria :**

**Given** le bottom sheet d'un monument ouvert
**When** l'utilisateur tape "Lire plus"
**Then** la description complète est chargée depuis l'API Wikidata (via `wikidataId` stocké dans Firestore) et affichée dans un écran dédié — `CircularProgressIndicator` pendant le chargement

**Given** l'API Wikidata indisponible ou lente
**When** la requête échoue ou dépasse 3 secondes
**Then** la description stockée localement dans Firestore (résumé court) s'affiche à la place — un message discret indique "Description complète indisponible"

**Given** la description affichée
**When** elle est visible
**Then** elle est scrollable, lisible en taille Dynamic Type normale, et inclut les crédits Wikidata/Wikipedia

---

### Story 6.4 : Lecture audio TTS (AVSpeechSynthesizer)

En tant qu'**utilisateur**,
Je veux écouter la description d'un monument pendant que je marche,
Afin d'apprendre sans avoir à regarder mon écran. (FR13)

**Acceptance Criteria :**

**Given** le bottom sheet ou l'écran description d'un monument
**When** l'utilisateur tape "🔊 Écouter"
**Then** `AVSpeechSynthesizer` (natif iOS, via `flutter_tts`) commence la lecture de la description en français — un bouton ⏸ apparaît pour mettre en pause (NFR20)

**Given** la lecture audio en cours
**When** l'utilisateur ferme le bottom sheet ou navigue ailleurs
**Then** la lecture s'arrête automatiquement — pas de lecture audio fantôme en arrière-plan

**Given** `flutter_tts` utilisé
**When** la lecture est configurée
**Then** la langue est détectée depuis les préférences iOS — fallback sur `fr-FR` si non détecté

---

## Epic 7 : Compte & Authentification

L'utilisateur crée un compte pour sauvegarder et accéder à sa progression depuis n'importe quel appareil, et peut supprimer ses données conformément au RGPD.

### Story 7.1 : Firebase Anonymous Auth au premier lancement + mode invité

En tant que **nouvel utilisateur**,
Je veux explorer l'app sans créer de compte,
Afin de découvrir la valeur d'Urbink avant de m'engager. (FR32)

**Acceptance Criteria :**

**Given** le premier lancement de l'app (après Story 2.7 onboarding)
**When** l'utilisateur accepte la politique de confidentialité
**Then** `signInAnonymously()` Firebase est appelé silencieusement — un UID Firestore est créé, la progression commence à être sauvegardée dans Firestore sous cet UID immédiatement

**Given** un utilisateur en mode invité
**When** il explore et accumule des sessions
**Then** toutes ses données (sessions, rues, badges) sont dans Firestore sous l'UID anonyme — rien n'est perdu si l'app est désinstallée et réinstallée sur le même appareil (l'UID anonyme Firebase persiste via Keychain)

**Given** un utilisateur invité qui n'a pas de compte
**When** il tente d'accéder à des fonctionnalités sociales (Epic 9)
**Then** un message s'affiche : "Crée un compte pour partager tes explorations et suivre d'autres explorateurs" avec CTA "Créer un compte"

---

### Story 7.2 : Écran création de compte + Sign in with Apple / Google / Facebook

En tant qu'**utilisateur**,
Je veux créer un compte en quelques secondes via mes comptes existants,
Afin de sécuriser ma progression et accéder aux fonctionnalités sociales. (FR33)

**Acceptance Criteria :**

**Given** l'écran de création de compte (`login_screen.dart`)
**When** il est affiché
**Then** 3 boutons OAuth sont visibles : "Sign in with Apple" (obligatoire iOS, en premier), "Continuer avec Google", "Continuer avec Facebook" — aucun formulaire email/mot de passe au MVP

**Given** le bouton "Sign in with Apple" tapé
**When** le flux OAuth Apple se termine avec succès
**Then** `linkWithCredential()` Firebase lie le compte Apple à l'UID anonyme existant — même UID Firestore, aucune migration de données (FR33, FR34)

**Given** une erreur OAuth (réseau, annulation utilisateur)
**When** elle se produit
**Then** l'utilisateur reste en mode invité — un `UrbinkSnackBar` erreur s'affiche avec le message approprié — aucun crash

---

### Story 7.3 : Accès multi-appareils après création de compte

En tant qu'**utilisateur avec compte**,
Je veux retrouver toute ma progression quand je me connecte sur un nouvel appareil,
Afin de ne jamais perdre mon historique d'exploration. (FR35)

**Acceptance Criteria :**

**Given** un utilisateur avec compte existant sur un nouvel appareil
**When** il se connecte avec le même fournisseur OAuth (Apple/Google/Facebook)
**Then** `signInWithCredential()` restaure l'UID Firebase associé — `StreamProvider` Riverpod charge toutes les données Firestore de cet UID automatiquement

**Given** la connexion réussie sur nouvel appareil
**When** la carte s'affiche
**Then** toutes les rues explorées, badges et sessions sont visibles — chargement en ≤ 3 secondes sur une connexion standard

**Given** deux appareils connectés au même compte
**When** une session se termine sur l'un
**Then** la progression se synchronise dans Firestore — visible sur l'autre appareil au prochain rafraîchissement (sync Firestore temps réel via `StreamProvider`)

---

### Story 7.4 : Suppression de compte et anonymisation RGPD

En tant qu'**utilisateur**,
Je veux pouvoir supprimer mon compte et toutes mes données personnelles,
Afin d'exercer mon droit à l'effacement conformément au RGPD. (FR46, NFR12)

**Acceptance Criteria :**

**Given** l'écran Profil → Paramètres → Supprimer mon compte
**When** l'utilisateur confirme la suppression (Dialog de confirmation)
**Then** la Cloud Function `on_user_deleted.go` est déclenchée — elle supprime : email, tokens OAuth, profil public, photo de profil (Firebase Storage) dans les 30 secondes

**Given** `on_user_deleted.go` en cours d'exécution
**When** les sessions GPS sont traitées
**Then** les coordonnées brutes GPS sont supprimées, les `streetIds` (IDs de rues OSM, non personnels) sont conservés anonymement — les pins sont anonymisés (`userId → null`)

**Given** la suppression complète
**When** elle est terminée
**Then** Firebase Auth désactive le compte — l'utilisateur est déconnecté de l'app et redirigé vers l'écran onboarding

---

## Epic 8 : Communauté & Pins

L'utilisateur crée des pins communautaires, les voit sur la carte, réagit et signale — avec modération IA automatique avant publication.

### Story 8.1 : Structure Firestore pins + affichage pins sur carte avec clustering

En tant qu'**utilisateur**,
Je veux voir les pins communautaires sur la carte et savoir ce que les autres ont découvert,
Afin de bénéficier de la connaissance collective des explorateurs. (FR27)

**Acceptance Criteria :**

**Given** la collection `/pins/{pinId}` dans Firestore avec statut `published`
**When** la couche Pins est activée (toggle Epic 3)
**Then** les marqueurs 📷 sont affichés sur la carte aux positions GPS des pins — clustering automatique aux faibles niveaux de zoom

**Given** des pins de profils privés
**When** la carte affiche les pins
**Then** les pins d'utilisateurs privés ne s'affichent que pour leurs abonnés acceptés — les autres utilisateurs ne les voient pas (FR27)

**Given** un marqueur pin tapé
**When** l'utilisateur tape dessus
**Then** un bottom sheet s'élève avec : photo, description, catégorie, nom de l'explorateur, date, réactions — le bottom sheet respecte les specs UX (pill de drag, scrim)

---

### Story 8.2 : Création pin communautaire (photo + description + GPS)

En tant qu'**utilisateur**,
Je veux épingler une découverte sur la carte avec une photo et une description,
Afin de partager ce que j'ai trouvé avec la communauté des explorateurs. (FR25)

**Acceptance Criteria :**

**Given** une session active et une zone explorée (rue colorée)
**When** l'utilisateur tape le bouton 📷 flottant sur la carte (visible pendant session active)
**Then** l'appareil photo iOS s'ouvre — la photo prise est pré-positionnée à la position GPS actuelle (FR25)

**Given** une zone non explorée
**When** l'utilisateur tente d'épingler
**Then** un `UrbinkSnackBar` info s'affiche : "Explore cette zone d'abord pour y épingler une découverte" — l'appareil photo ne s'ouvre pas

**Given** la photo prise
**When** l'utilisateur valide
**Then** un écran minimaliste s'affiche : aperçu photo + `TextField` description (facultatif, max 140 chars) + sélecteur de catégorie (Porte / Cour / Vue / Street Art / Autre) + bouton "Publier"

**Given** le bouton "Publier" tapé
**When** le pin est soumis
**Then** il est uploadé dans Firebase Storage (photo) + créé dans Firestore avec statut `pending` — le flux entier (photo → soumission) se complète en ≤ 30 secondes (NFR) — un `UrbinkSnackBar` succès confirme la soumission

---

### Story 8.3 : Modération IA automatique (Cloud Function OnPinCreated) + sanctions progressives

En tant qu'**administrateur / système**,
Je veux que chaque pin soit automatiquement analysé par IA avant publication,
Afin d'éviter que du contenu inapproprié n'apparaisse sur la carte publique. (FR26)

**Acceptance Criteria :**

**Given** un pin créé dans Firestore avec statut `pending`
**When** la Cloud Function `on_pin_created.go` se déclenche
**Then** elle analyse le texte (modèle NLP) et l'image (API Vision) — si le contenu est acceptable, le statut passe à `published` ; si problématique, à `review` (modération manuelle) ou `rejected`

**Given** un pin rejeté automatiquement par l'IA
**When** le statut passe à `rejected`
**Then** `sanctionCount` de l'auteur est incrémenté dans `/users/{userId}` : 1→avertissement in-app, 2→avertissement, 3→suspension 24h (`suspendedUntil`), 4+→ban (Firebase Auth désactivé) (FR26)

**Given** un utilisateur suspendu
**When** il tente de créer un pin pendant la suspension
**Then** l'app vérifie `suspendedUntil` avant d'ouvrir l'appareil photo — un message discret informe de la durée restante sans détailler la raison

**Given** la Cloud Function qui échoue (timeout API IA)
**When** l'analyse ne peut pas se terminer
**Then** le pin passe en statut `review` pour modération manuelle — l'auteur reçoit un message : "Ton pin est en cours de vérification" (pas de rejet silencieux)

---

### Story 8.4 : Réaction "Pas ouf" + auto-masquage à 5 réactions négatives

En tant qu'**utilisateur**,
Je veux signaler discrètement qu'un pin n'est pas pertinent,
Afin que les pins de mauvaise qualité disparaissent naturellement de la carte. (FR28)

**Acceptance Criteria :**

**Given** le bottom sheet d'un pin ouvert
**When** l'utilisateur tape le bouton "Pas ouf 👎"
**Then** sa réaction est enregistrée dans Firestore sous le pin — il ne peut réagir qu'une seule fois par pin

**Given** un pin ayant atteint 5 réactions "Pas ouf"
**When** la 5ème réaction est enregistrée
**Then** une Cloud Function met le statut du pin à `private` automatiquement — le pin disparaît de la carte publique sans notification à l'auteur et sans suppression du document

**Given** un pin en statut `private` via réactions
**When** l'auteur consulte ses pins
**Then** il le voit toujours dans son profil personnel — seule la visibilité publique est retirée

---

### Story 8.5 : Signalement pin + escalade vers modération manuelle

En tant qu'**utilisateur**,
Je veux signaler un pin comme inapproprié pour les contenus illicites,
Afin de contribuer à la sécurité de la communauté. (FR29)

**Acceptance Criteria :**

**Given** le bottom sheet d'un pin ouvert
**When** l'utilisateur tape "Signaler"
**Then** un Dialog s'affiche avec les raisons possibles : Contenu offensant / Spam / Contenu illicite / Autre — le signalement est enregistré dans Firestore

**Given** un signalement soumis
**When** il est traité par la Cloud Function `on_pin_reported.go`
**Then** le pin passe en statut `review` (si pas déjà) — l'IA ré-analyse le contenu pour décider si suppression automatique ou escalade manuelle

**Given** un pin signalé par ≥ 3 utilisateurs différents
**When** la 3ème plainte arrive
**Then** le pin est automatiquement masqué (`status: review`) en attendant modération manuelle par Jo via Firebase Console — l'auteur n'est pas notifié

---

## Epic 9 : Partage & Social

L'utilisateur partage sa carte colorée, publie ses parcours dans un fil d'actualité, et suit d'autres explorateurs.

### Story 9.1 : Structure Firestore follows + posts + profils public/privé

En tant que **développeur**,
Je veux les collections Firestore pour le système social d'Urbink,
Afin que les stories suivantes puissent implémenter le fil social.

**Acceptance Criteria :**

**Given** les collections `/follows/{followId}` et `/posts/{postId}` dans Firestore
**When** elles sont initialisées
**Then** `/follows` contient `followerId`, `followingId`, `status` (pending/accepted) — `/posts` contient `userId`, `parcoursId`, `sessionId`, `badgesUnlocked[]`, `createdAt`

**Given** le champ `isPublic: bool` dans `/users/{userId}`
**When** il est `false` (profil privé)
**Then** les règles Firestore n'autorisent la lecture de `/posts` de cet utilisateur qu'aux `followerId` avec `status: accepted` dans `/follows`

**Given** les règles Firestore configurées
**When** un utilisateur tente de lire les posts d'un profil privé sans être abonné accepté
**Then** la requête retourne vide — aucune erreur d'autorisation visible côté app (géré par le provider Riverpod)

---

### Story 9.2 : Suivi d'explorateurs (follow/unfollow + demande pour profils privés)

En tant qu'**utilisateur**,
Je veux suivre d'autres explorateurs pour voir leurs activités dans mon fil,
Afin d'être inspiré par les explorations de ma communauté. (FR31b, FR31c)

**Acceptance Criteria :**

**Given** un profil public visité
**When** l'utilisateur tape "Suivre"
**Then** un document `/follows/` est créé avec `status: accepted` — le profil suivi est ajouté immédiatement au fil Accueil de l'utilisateur (FR31b)

**Given** un profil privé visité
**When** l'utilisateur tape "Demander à suivre"
**Then** un document `/follows/` est créé avec `status: pending` — le propriétaire du profil reçoit une notification "X veut te suivre" — le bouton affiche "Demande envoyée"

**Given** une demande de suivi reçue
**When** le propriétaire du profil privé accepte
**Then** le statut `/follows/` passe à `accepted` — le demandeur voit désormais les posts et pins de ce profil

**Given** l'écran Profil → Paramètres
**When** l'utilisateur configure sa visibilité
**Then** un toggle "Profil public / Privé" est disponible — passer en privé retire immédiatement les pins de la carte publique et les posts du fil des non-abonnés (FR31c)

---

### Story 9.3 : Publication parcours terminé dans le fil d'actualité

En tant qu'**utilisateur**,
Je veux partager mon parcours terminé avec mes abonnés,
Afin de montrer mes explorations et inspirer d'autres curieux urbains. (FR31d)

**Acceptance Criteria :**

**Given** une session ou un parcours terminé
**When** le résumé s'affiche
**Then** un bouton "Partager avec mes abonnés" est présent — optionnel, non forcé

**Given** l'utilisateur qui tape "Partager"
**When** la publication est confirmée
**Then** un document `/posts/` est créé dans Firestore avec : `sessionId`, `parcoursId`, `badgesUnlocked[]` durant ce parcours, `stats` (rues, km, durée), `routePoints[]` pour le tracé miniature

**Given** un post publié dans `/posts/`
**When** un abonné ouvre son fil Accueil
**Then** le post apparaît dans le fil chronologique de cet abonné via `StreamProvider` Riverpod

---

### Story 9.4 : Composant FeedActivityItem + fil Accueil

En tant qu'**utilisateur**,
Je veux voir les activités de mes abonnements dans un fil social clair et interactif,
Afin de suivre les explorations de mes contacts. (FR31d, UX-DR5)

**Acceptance Criteria :**

**Given** l'onglet Accueil ouvert avec des abonnements actifs
**When** le fil se charge
**Then** les posts s'affichent en liste anti-chronologique — 20 items par page, lazy load au scroll

**Given** chaque post dans le fil
**When** il est rendu
**Then** `FeedActivityItem` affiche : header (avatar + nom + ville + temps relatif) · stats row (rues · km · durée) · `RouteMapPreview` small · chips badges débloqués · réactions bar (🔥 · 💬 · 🗺️)

**Given** le bouton réaction 🔥 tapé
**When** l'utilisateur réagit
**Then** le compteur s'incrémente avec un feedback haptique léger — l'utilisateur ne peut réagir qu'une fois par post (idempotent)

**Given** le bouton 🗺️ "Voir le tracé" tapé
**When** l'utilisateur tape
**Then** un overlay carte plein écran s'ouvre avec le tracé du post — CTA "Explorer cette zone" centre l'onglet Carte sur la zone sans quitter le fil

**Given** l'onglet Accueil sans abonnements
**When** le fil est vide
**Then** l'empty state s'affiche : "🧭 Suis des explorateurs pour voir leurs aventures" + CTA "Découvrir des profils" — 3 activités fictives "démo" sont optionnellement affichées pour montrer le format

---

### Story 9.5 : Export image carte colorée + share sheet iOS

En tant qu'**utilisateur**,
Je veux exporter une image de ma carte colorée et la partager sur les réseaux sociaux,
Afin de montrer mon empreinte d'explorateur et donner envie à d'autres de télécharger Urbink. (FR30)

**Acceptance Criteria :**

**Given** l'écran Profil ou la carte en vue historique complète
**When** l'utilisateur tape "Partager ma carte"
**Then** un snapshot de la zone carte avec les rues colorées est généré côté client (capture flutter_map) — un watermark "Urbink" est superposé en coin

**Given** le snapshot généré
**When** il est prêt (≤ 3 secondes)
**Then** le share sheet iOS natif (`Share.share()`) s'ouvre avec l'image — l'utilisateur peut partager sur Instagram, WhatsApp, iMessage, etc.

**Given** le share sheet utilisé
**When** le partage est confirmé
**Then** aucune donnée n'est envoyée à un serveur Urbink — le snapshot est généré et partagé entièrement côté client

---

### Story 9.6 : Partage itinéraire par lien (Cloud Function)

En tant qu'**utilisateur**,
Je veux partager un itinéraire avec un lien que n'importe qui peut ouvrir,
Afin de recommander un circuit même à des personnes qui n'ont pas Urbink. (FR31)

**Acceptance Criteria :**

**Given** l'écran détail d'un itinéraire sauvegardé
**When** l'utilisateur tape "Partager par lien"
**Then** la Cloud Function `generate_share_link.go` est appelée — elle génère un lien unique avec les métadonnées de l'itinéraire (nom, distance, durée, points) stockées dans Firestore

**Given** le lien généré
**When** il est ouvert par un non-utilisateur dans un navigateur
**Then** une page web légère (Firebase Hosting) s'affiche avec : nom de l'itinéraire, carte miniature statique, distance et durée, CTA "Télécharger Urbink" avec lien App Store

**Given** le lien ouvert par un utilisateur Urbink
**When** l'app est installée et Deep Link configuré
**Then** l'app s'ouvre directement sur l'écran de prévisualisation de l'itinéraire avec CTA "Démarrer ce parcours"

---

## Epic 10 : Notifications

L'utilisateur reçoit des notifications contextuelles (badges, rappels, réactions) et gère ses préférences.

### Story 10.1 : Infrastructure FCM + APNs + demande de permission

En tant que **développeur**,
Je veux configurer Firebase Cloud Messaging pour les notifications push iOS,
Afin que toutes les notifications de l'app passent par une infrastructure fiable. (FR36-39)

**Acceptance Criteria :**

**Given** `notification_service.dart` initialisé dans `main.dart`
**When** l'app se lance
**Then** FCM est initialisé, le token FCM est récupéré et sauvegardé dans `/users/{userId}.fcmToken` dans Firestore

**Given** l'app lancée pour la première fois après le moment "aha" (Epic 2)
**When** la demande de permission est déclenchée
**Then** la popup iOS de permission de notifications s'affiche — non demandée au tout premier lancement, mais après la première rue colorée

**Given** le token FCM mis à jour (renouvellement automatique iOS)
**When** le nouveau token est reçu
**Then** Firestore est mis à jour automatiquement via le listener FCM — aucun token obsolète en base

---

### Story 10.2 : Notification déblocage badge + quartier complété

En tant qu'**utilisateur**,
Je veux être notifié quand je débloque un badge même si l'app est en arrière-plan,
Afin de ne manquer aucune récompense. (FR36)

**Acceptance Criteria :**

**Given** la Cloud Function `on_quartier_completed.go` déclenchée
**When** le badge quartier est créé dans Firestore
**Then** FCM Admin SDK Go envoie une notification push via `send_push.go` : titre "🏆 Quartier [Nom] complété !", corps "[Secret local preview]"

**Given** la notification reçue par l'app en arrière-plan
**When** l'utilisateur tape dessus
**Then** l'app s'ouvre sur l'écran Challenges → section du quartier complété

**Given** la Cloud Function `on_monument_proximity.go` déclenchée
**When** le badge monument est créé
**Then** FCM envoie une notification push : titre "🏛️ [Nom monument] débloqué !", corps "Tu as visité [N] monuments à Paris"

---

### Story 10.3 : Notification rappel exploration

En tant qu'**utilisateur**,
Je veux recevoir un rappel bienveillant si je n'ai pas exploré depuis 3 jours,
Afin de maintenir l'habitude d'exploration sans me sentir harcelé. (FR37)

**Acceptance Criteria :**

**Given** un utilisateur qui n'a pas eu de session depuis 3 jours
**When** une Cloud Function schedulée (Cloud Scheduler Firebase) s'exécute
**Then** elle identifie les utilisateurs sans session depuis > 72h et envoie FCM : titre "La ville t'attend 🗺️", corps "Tu n'as pas exploré depuis 3 jours — de nouvelles rues t'attendent"

**Given** la notification rappel envoyée
**When** elle est reçue par l'utilisateur
**Then** tap → l'app s'ouvre sur l'onglet Carte, bottom sheet en état peek (section "Démarrer une sortie" visible)

**Given** la fréquence des rappels
**When** le système calcule le prochain envoi
**Then** un maximum d'un rappel tous les 3 jours est respecté par utilisateur — aucun rappel si une session a eu lieu dans les 72h

---

### Story 10.4 : Notification réaction sur pin + gestion préférences

En tant qu'**utilisateur**,
Je veux être notifié quand quelqu'un réagit à mon pin, et contrôler mes préférences de notification,
Afin de rester connecté à la communauté à mon rythme. (FR38, FR39)

**Acceptance Criteria :**

**Given** une réaction ajoutée sur un pin dont `userId` correspond à un utilisateur actif
**When** la réaction est enregistrée dans Firestore
**Then** FCM envoie une notification push : titre "Ton pin a été aimé ❤️", corps "[Pseudo] a réagi à ton pin dans [quartier]"

**Given** l'écran Profil → Préférences de notification
**When** l'utilisateur l'ouvre
**Then** 4 toggles sont disponibles : Badges et quartiers / Rappels exploration / Réactions sur mes pins / Demandes de suivi — activés par défaut, désactivables indépendamment (FR39)

**Given** un type de notification désactivé
**When** l'événement correspondant se produit
**Then** le provider Riverpod vérifie les préférences dans Firestore avant d'appeler FCM — aucune notification envoyée si le type est désactivé

### Story 10.5 : Tests intégration Cloud Functions Go — Firebase Emulator Suite

En tant que **développeur**,
Je veux pouvoir tester les Cloud Functions Go avec de vraies données Firestore en local,
Afin de valider le comportement de bout en bout sans déployer sur Firebase.

**Acceptance Criteria :**

**Given** la Firebase Emulator Suite configurée (Firestore + Functions)
**When** un badge `quartier_*` est créé dans l'émulateur Firestore
**Then** la Cloud Function `OnQuartierCompleted` est déclenchée et le test vérifie que FCM serait appelé

**Given** un test d'intégration Go avec `go test -tags integration`
**When** le test tourne avec `FIRESTORE_EMULATOR_HOST` et `FIREBASE_AUTH_EMULATOR_HOST` définis
**Then** `firestoreReader.readBadge` et `firestoreReader.readFCMToken` s'exécutent contre l'émulateur réel

**Given** l'émulateur non disponible
**When** le test tourne sans les variables d'environnement émulateur
**Then** les tests d'intégration sont skippés (`t.Skip`) — les tests unitaires passent toujours

**Notes techniques :**
- Ajouter `functions-framework-go` pour l'enregistrement + démarrage HTTP local
- Configurer `firebase.json` avec `"emulators": { "firestore": { "port": 8080 }, "functions": { "port": 5001 } }`
- Les tests d'intégration utilisent le build tag `//go:build integration`
- Voir la doc Firebase Emulator Go : `FIRESTORE_EMULATOR_HOST=localhost:8080`

---

## Epic 11 : Administration & Cold Start

Jo lance le pipeline cold start IA pour pré-remplir Paris de contenu avant le lancement, et administre le contenu via Firebase Console.

### Story 11.1 : Pipeline cold start IA (Cloud Function populate_paris.go)

En tant qu'**administrateur**,
Je veux lancer un pipeline automatisé qui génère des pins de qualité pour Paris avant le lancement,
Afin que les premiers utilisateurs trouvent du contenu dès le jour 1. (FR40)

**Acceptance Criteria :**

**Given** la Cloud Function `populate_paris.go` déclenchée manuellement par Jo
**When** le pipeline s'exécute
**Then** il scrape et structure les données de Paris Secret, blogs street art, Wikidata en pins géolocalisés formatés — chaque pin contient description, position GPS, catégorie, source

**Given** les pins générés par le pipeline
**When** ils arrivent dans Firestore
**Then** ils ont le statut `pending_review` — non publiés automatiquement, en attente de validation manuelle par Jo

**Given** les pins `pending_review` dans Firebase Console
**When** Jo les valide
**Then** il peut passer le statut à `published` (ou supprimer les pins de faible qualité) — au minimum 200 pins publiés avant le lancement

---

### Story 11.2 : Secrets locaux par arrondissement (Firestore /quartiers)

En tant qu'**administrateur**,
Je veux associer un secret local à chaque arrondissement de Paris,
Afin que les utilisateurs qui complètent un quartier découvrent quelque chose d'unique. (FR41)

**Acceptance Criteria :**

**Given** les 20 arrondissements de Paris dans `/quartiers/{quartierId}`
**When** Jo accède à Firebase Console
**Then** il peut lire et modifier le champ `secretLocal` (texte + position GPS optionnelle) de chaque quartier

**Given** un secret local sauvegardé
**When** un utilisateur complète le quartier correspondant
**Then** le secret s'affiche exactement tel que Jo l'a rédigé dans `CelebrationOverlay`

**Given** le lancement de l'app
**When** les premiers utilisateurs complètent des arrondissements
**Then** les 20 arrondissements ont un secret local défini — aucun arrondissement sans contenu

---

### Story 11.3 : Modération manuelle pins signalés (Firebase Console)

En tant qu'**administrateur**,
Je veux consulter et traiter les pins que l'IA n'a pas pu trancher,
Afin de maintenir la qualité du contenu communautaire. (FR42, FR43)

**Acceptance Criteria :**

**Given** des pins en statut `review` dans Firestore
**When** Jo ouvre Firebase Console
**Then** il peut filtrer `/pins` par `status == "review"` et voir le contenu (texte + URL photo Firebase Storage)

**Given** un pin en `review` jugé acceptable par Jo
**When** il change le statut à `published`
**Then** le pin apparaît sur la carte publique dans les 60 secondes (délai propagation Firestore)

**Given** un pin en `review` jugé inapproprié
**When** Jo supprime le document Firestore
**Then** la Cloud Function `on_pin_reported.go` incrémente `sanctionCount` de l'auteur et applique la sanction progressive (FR43)

---

### Story 11.4 : Configuration monuments Paris et données associées

En tant qu'**administrateur**,
Je veux configurer les monuments de Paris avec leurs données et badges,
Afin que la gamification monuments soit opérationnelle au lancement. (FR44)

**Acceptance Criteria :**

**Given** la collection `/monuments/{monumentId}` dans Firestore
**When** Jo ajoute ou modifie un monument via Firebase Console
**Then** il peut saisir : `name`, `position` (GeoPoint), `proximityRadius` (mètres), `description`, `wikidataId`, `badgeId`, `badgeIcon`

**Given** un monument configuré avec `proximityRadius`
**When** un utilisateur passe à moins de ce rayon en session
**Then** `on_monument_proximity.go` débloque le badge correctement

**Given** le lancement de l'app
**When** les premiers utilisateurs explorent Paris
**Then** les monuments emblématiques (Tour Eiffel, Notre-Dame, Louvre, Sacré-Cœur, Arc de Triomphe, Musée d'Orsay, Centre Pompidou, Panthéon, Invalides, Sainte-Chapelle) sont configurés avec leurs badges

---

## Epic 12 : Déploiement App Store

L'app est soumise sur l'App Store avec conformité Apple complète, TestFlight beta, et CI/CD automatisé.

### Story 12.1 : Conformité App Store — App Privacy Labels + Background Location + politique UGC

En tant qu'**administrateur / Jo**,
Je veux que l'app soit conforme à toutes les exigences Apple avant soumission,
Afin d'éviter un rejet de l'App Store.

**Acceptance Criteria :**

**Given** l'App Store Connect configuré
**When** les App Privacy Labels sont remplis
**Then** les catégories de données déclarées incluent : Localisation (précise, arrière-plan), Identifiants (ID utilisateur), Photos (contenu utilisateur) — conformes aux données réellement collectées

**Given** `Info.plist` configuré
**When** il est soumis à Apple
**Then** `NSLocationAlwaysAndWhenInUseUsageDescription` contient : "Urbink trace ton exploration en temps réel pour colorier les rues que tu parcours" — `NSCameraUsageDescription` explique l'usage photo pour les pins

**Given** la politique de modération UGC documentée
**When** elle est soumise à Apple
**Then** elle décrit le processus de modération IA + signalement humain + suppression admin — conforme aux guidelines App Store pour le contenu communautaire

**Given** Sign in with Apple implémenté (Story 7.2)
**When** l'app propose d'autres logins sociaux
**Then** "Sign in with Apple" est visible en premier et au moins aussi proéminent que les autres options (règle Apple obligatoire)

---

### Story 12.2 : TestFlight beta + soumission App Store

En tant qu'**administrateur / Jo**,
Je veux publier l'app sur TestFlight pour la tester, puis la soumettre sur l'App Store,
Afin de valider l'expérience avant le lancement public.

**Acceptance Criteria :**

**Given** le pipeline Fastlane configuré (Story 1.6)
**When** un tag `v1.0.0-beta` est créé sur `main`
**Then** GitHub Actions déclenche le workflow deploy et Fastlane soumet un build à TestFlight automatiquement en ≤ 15 minutes

**Given** le build TestFlight disponible
**When** Jo (et éventuellement des testeurs invités) le testent
**Then** tous les journeys critiques (Epic 2, 4, 7) fonctionnent sur iPhone physique (iPhone 15 et iPhone SE 3)

**Given** les retours TestFlight intégrés
**When** le build final est prêt
**Then** Fastlane soumet à l'App Store Review avec les métadonnées complètes : description, screenshots, mots-clés, notes de version

**Given** l'app approuvée par Apple
**When** la mise en ligne est déclenchée
**Then** l'app est disponible sur l'App Store France en version 1.0.0 — le cold start Paris (Epic 11) a été exécuté préalablement

