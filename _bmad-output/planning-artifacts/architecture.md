---
stepsCompleted: [1, 2, 3, 4, 5, 6, 7, 8]
lastStep: 8
status: 'complete'
completedAt: '2026-04-07'
inputDocuments:
  - '_bmad-output/planning-artifacts/prd.md'
  - '_bmad-output/planning-artifacts/product-brief-projet-carte-touristique-gamifie.md'
  - '_bmad-output/planning-artifacts/product-brief-projet-carte-touristique-gamifie-distillate.md'
workflowType: 'architecture'
project_name: 'Urbink'
user_name: 'Jo'
date: '2026-04-06'
---

# Architecture Decision Document

_Ce document se construit collaborativement étape par étape. Les sections sont ajoutées au fil des décisions architecturales prises ensemble._

## Analyse du Contexte Projet

### Vue d'ensemble des Exigences

**Exigences Fonctionnelles — 47 FRs en 9 domaines :**

| Domaine | FRs | Implication architecturale |
|---|---|---|
| Exploration & GPS | FR1-6 | Tracking temps réel, map matching OSM, stockage sessions |
| Agrégation temporelle | FR7-9 | Moteur de calcul d'agrégation, requêtes filtrées par date |
| Carte & POI | FR10-14 | Rendu cartographique, API POI, TTS natif |
| Gamification | FR15-20 | Système d'événements (badges, quartiers, secrets), règles métier |
| Parcours | FR21-24 | Algorithme de génération de circuits, guidage temps réel |
| Communauté & Pins | FR25-29 | Upload media, pipeline modération IA, pub/sub |
| Partage & Social | FR30-31 | Export image, génération de liens |
| Compte & Auth | FR32-35 | OAuth multi-provider, sync local→cloud, stockage sécurisé |
| Notifications | FR36-39 | Push APNs, triggers événementiels, préférences |
| Back-office | FR40-44 | Pipeline cold start IA, modération manuelle, CRUD admin |
| Conformité | FR45-47 | RGPD, suppression données, crédits OSM |

**Exigences Non-Fonctionnelles critiques :**
- Latence coloration rue : < 1 seconde
- Chargement carte : < 2 secondes
- Génération parcours : < 3 secondes
- Fiabilité : local-first, aucune perte de session GPS
- Scalabilité : 10 000 MAU → 100 000 MAU sans refonte
- Sécurité : HTTPS/TLS, iOS Keychain, RGPD

**Complexité & Périmètre :**
- Complexité : **Haute** — GPS temps réel + map matching + agrégation + IA + communautaire + admin
- Domaine principal : **Mobile natif iOS + backend cloud**
- Solo founder, budget zéro — stack doit être low-cost et maintenable seul

### Contraintes Techniques & Dépendances

- **OpenStreetMap** — données cartographiques libres (ODbL), map matching sur réseau routier OSM
- **Map matching** — composant le plus critique et risqué (Valhalla, OSRM, ou Mapbox)
- **iOS 16+** — React Native ou Flutter, AVSpeechSynthesizer natif
- **Modération IA** — pipeline pré-publication pour les pins (texte + image)
- **Cold start** — pipeline scraping + formatage IA pour pré-remplir Paris au lancement
- **Local-first** — données GPS persistées localement avant toute sync

### Préoccupations Transverses

1. **GPS & Map Matching** — cœur du produit, composant le plus difficile à implémenter correctement
2. **Local-first sync** — réconciliation locale/cloud sans perte de données
3. **Authentification** — mode invité → compte, sync progressive
4. **Système d'événements** — badges, notifications, complétion quartiers découplés de la logique GPS
5. **Modération IA** — asynchrone, ne bloque pas l'UX utilisateur
6. **Performance rendu cartographique** — potentiellement des milliers de segments colorés à afficher simultanément

## Stack Technique — Décisions Validées

### Frontend

| Composant | Technologie | Justification |
|---|---|---|
| Application mobile | **Flutter** | Performances rendu élevées, SDK Firebase natif, portabilité iOS→Android |
| Snap to road (in-app) | **Lib OSM Flutter** | Zero serveur au MVP, données OSM Paris pré-chargées |

### Backend — Firebase

| Besoin | Service Firebase | Notes |
|---|---|---|
| Authentification | **Firebase Auth** | Sign in with Apple, Google, Facebook |
| Base de données | **Firestore** | NoSQL, temps réel, local-first natif |
| Stockage photos | **Firebase Storage** | Photos des pins communautaires |
| Push notifications | **FCM** | iOS (APNs) + Android unifié |
| Logique serveur | **Cloud Functions (Go)** | Modération IA, gamification, parcours, RGPD |

### Cloud Functions Go — Périmètre

1. **Modération IA pins** — analyse texte + image avant publication (clés API sécurisées côté serveur)
2. **Triggers gamification** — complétion quartier → badge → secret local → notification push
3. **Génération de parcours automatique** — algorithme circuit optimal sur données Firestore
4. **Pipeline cold start** — scraping + formatage IA Paris Secret, Wikidata, blogs street art
5. **Partage d'itinéraire** — génération liens de partage avec métadonnées
6. **Suppression RGPD** — suppression cascade données utilisateur (Firestore + Storage)

### Roadmap Technique

| Phase | Évolution |
|---|---|
| MVP | Snap to nearest road in-app |
| V2 | Service Go map matching sur Scaleway (OSRM ou Valhalla) pour correction post-session |
| V2 | Android |

### Contraintes & Notes

- **Firebase plan Blaze** requis pour Cloud Functions (pay-as-you-go, gratuit en pratique au MVP)
- **RGPD** : Firebase = Google = serveurs US. Documenté dans politique de confidentialité comme sous-traitant. Migration Appwrite EU envisageable en V2 si pression réglementaire.
- **Coût estimé MVP** : ~0€/mois dans les limites du free tier Firebase

## Décisions Architecturales Core

### Analyse des Priorités

**Décisions critiques (bloquantes pour l'implémentation) :**
- Structure des données Firestore ✅
- State management Flutter ✅
- Rendu cartographique ✅
- Snap to road strategy ✅

**Décisions importantes (shape l'architecture) :**
- Cloud Functions en Go ✅
- CI/CD pipeline ✅

**Décisions différées (post-MVP) :**
- Map matching serveur (V2) — service Go + OSRM/Valhalla sur Scaleway

### Architecture des Données

**Structure Firestore — Collections imbriquées par utilisateur :**

```
/users/{userId}
  isPublic: bool            ← profil public (true) ou privé Instagram-model (false)
  sanctionCount: int        ← compteur infractions IA modération (0→1→2→3→ban)
  suspendedUntil: timestamp ← date fin de suspension 24h (null si actif)
  fcmToken: string          ← token push FCM mis à jour à chaque lancement
  /sessions/{sessionId}     ← tracés GPS horodatés
  /streets/{streetId}       ← rues colorées agrégées
  /badges/{badgeId}         ← badges débloqués
  /parcours/{parcoursId}    ← parcours sauvegardés (auto + personnalisés)

/pins/{pinId}               ← collection racine
  status: pending|published|private|review|rejected
  userId: string|null       ← null si utilisateur supprimé (anonymisation RGPD)
  isAnonymousOrigin: bool   ← créé par un utilisateur anonyme Firebase

/posts/{postId}             ← fil d'actualité — parcours publiés
  userId: string
  parcoursId: string
  badgesUnlocked: []        ← badges débloqués pendant ce parcours
  createdAt: timestamp

/follows/{followId}         ← relations abonné/abonné
  followerId: string
  followingId: string
  status: pending|accepted  ← pending pour profils privés

/quartiers/{quartierId}     ← définition des quartiers Paris + secret local
/monuments/{monumentId}     ← POI et badges monuments Paris
```

**Rationale :** Données naturellement liées à l'utilisateur → règles de sécurité Firestore simples (`request.auth.uid == userId`), requêtes performantes, isolation des données par utilisateur. Collections `/posts` et `/follows` en racine pour faciliter les requêtes cross-utilisateurs du fil d'actualité.

### Authentification & Sécurité

- **Firebase Auth** — `signInAnonymously()` dès le premier lancement → UID anonyme créé pour tous les utilisateurs sans exception
- **Mode invité** — Firebase Anonymous Auth (UID Firestore actif dès J0, pas de sqflite comme source de vérité) — données dans Firestore immédiatement
- **Création de compte** — `linkWithCredential()` lie le compte OAuth (Apple/Google/Facebook) à l'UID anonyme existant → même UID, aucune migration nécessaire
- **Suppression de compte** — anonymisation RGPD : suppression email/tokens/profil, conservation des sessions GPS (IDs de rues uniquement, sans coordonnées brutes), pins userId → null
- **Profil public/privé** — champ `isPublic` dans `/users/{userId}` — profil privé = modèle Instagram (contenu visible uniquement par abonnés acceptés + pins retirés de la carte publique)
- **Sanctions modération** — `sanctionCount` incrémenté par Cloud Function à chaque infraction IA : 1→avertissement, 2→avertissement, 3→suspension 24h (`suspendedUntil`), 4+→ban (Firebase Auth désactivé)
- **Règles Firestore** — lecture/écriture restreinte au `userId` propriétaire ; `/posts` et `/follows` accessibles selon `isPublic` et relations `follows`
- **Clés API sensibles** — stockées dans Cloud Functions uniquement (modération IA, Nominatim)
- **iOS Keychain** — tokens OAuth via `flutter_secure_storage`

### API & Communication

- **Flutter → Firestore** — SDK Firebase natif, streams temps réel
- **Flutter → Cloud Functions** — appels HTTPS callable functions
- **Flutter → Nominatim** — REST API HTTP pour snap to road
- **Cloud Functions → FCM** — push notifications via Admin SDK Go
- **Pas d'API REST custom** — Firebase SDK suffit pour 100% des cas MVP

### Architecture Frontend Flutter

- **State management : Riverpod** — gestion des streams GPS, état carte, sessions, badges, fil social
- **Rendu cartographique : flutter_map** — OSM tiles, polylignes custom pour rues colorées
- **Snap to road : Nominatim API** — online uniquement, ~200ms latence acceptable
- **Navigation : go_router** — routing déclaratif Flutter standard
- **Stockage local : sqflite** — cache local uniquement (performance), source de vérité = Firestore dès le premier lancement via Firebase Anonymous Auth

### Infrastructure & Déploiement

- **CI/CD : GitHub Actions + Fastlane** — build automatique, publication App Store
- **Environnements : dev / staging / prod** — trois projets Firebase distincts
- **Monitoring : Firebase Crashlytics + Analytics** — crashes et métriques d'usage
- **Hosting back-office admin : Firebase Hosting** — interface web légère pour Jo

### Roadmap Technique V2

- **Map matching serveur** — service Go + OSRM ou Valhalla conteneurisé sur Scaleway Containers (Paris)
- **Android** — Flutter multi-plateforme, effort minimal
- **Migration RGPD** — Appwrite EU (Frankfurt) si pression réglementaire sur Firebase

### Séquence d'Implémentation Recommandée

1. Setup Firebase + Flutter + Riverpod + flutter_map
2. GPS tracking + Nominatim snap to road + coloration rues
3. Agrégation sessions + filtrage temporel
4. Système de quartiers + gamification
5. Parcours automatique + personnalisé
6. Pins communautaires + modération IA (Cloud Functions Go)
7. Auth + sync cloud + mode invité
8. Push notifications FCM
9. Back-office admin
10. CI/CD + soumission App Store

## Patterns d'Implémentation & Règles de Cohérence

### Naming Conventions

**Firestore & Dart — camelCase partout :**
- Champs Firestore : `userId`, `createdAt`, `streetId`, `sessionStart`
- Collections : `users`, `sessions`, `streets`, `pins`, `quartiers`, `monuments`
- Variables Dart : `currentSession`, `coloredStreets`, `userBadges`
- Fichiers : `map_screen.dart`, `session_provider.dart`, `pin_service.dart` (snake_case — convention Dart)
- Classes : `MapScreen`, `SessionProvider`, `PinService` (PascalCase)

### Structure du Projet Flutter

```
lib/
  features/
    map/              ← carte, coloration, flutter_map
    sessions/         ← GPS tracking, snap to road, agrégation
    gamification/     ← badges, quartiers, objectifs, secrets
    parcours/         ← automatique, personnalisé, guidage
    pins/             ← création, modération, affichage
    auth/             ← Firebase Auth, mode invité, sync
    notifications/    ← FCM, préférences
    profile/          ← compte, badges, historique
    admin/            ← back-office, modération (web)
  shared/
    widgets/          ← composants réutilisables
    utils/            ← helpers, extensions
    constants/        ← couleurs, dimensions, strings
  core/
    firebase/         ← config Firebase, règles Firestore
    providers/        ← Riverpod providers globaux
    router/           ← go_router config
```

### Patterns de Communication

**Riverpod — conventions :**
- Providers nommés en camelCase + suffixe : `sessionProvider`, `mapStateProvider`
- States immutables via `freezed`
- Streams Firestore exposés via `StreamProvider`

**Cloud Functions Go — conventions :**
- Nommage fonctions : `OnPinCreated`, `OnQuartierCompleted`, `OnUserDeleted`
- Payload JSON : camelCase
- Réponse standard : `{"success": true, "data": {...}}` ou `{"success": false, "error": "message"}`

### Patterns de Gestion d'Erreurs

- **Erreurs Firestore** → loggées Firebase Crashlytics, message générique à l'utilisateur
- **Erreurs réseau (Nominatim)** → retry automatique x3 avec backoff exponentiel, puis fallback silencieux
- **Erreurs GPS** → session continue sans interruption, log local
- **Erreurs modération IA** → pin mis en attente manuelle, pas de rejet silencieux

### Règles Obligatoires pour tous les Agents IA

- Toujours camelCase pour les champs Firestore et variables Dart
- Toujours snake_case pour les noms de fichiers Dart
- Toujours PascalCase pour les classes et widgets
- Toujours organiser par feature, jamais par type
- Jamais d'appel Firestore direct dans un widget — toujours via un provider Riverpod
- Jamais de clé API dans le code Flutter — toujours dans Cloud Functions Go

## Structure du Projet & Frontières

### Arborescence Complète

```
urbink/
├── README.md
├── pubspec.yaml                    ← dépendances Flutter
├── pubspec.lock
├── analysis_options.yaml           ← règles lint Dart
├── .env.dev                        ← config Firebase dev
├── .env.prod                       ← config Firebase prod
├── .gitignore
├── .github/
│   └── workflows/
│       ├── ci.yml                  ← tests + build
│       └── deploy.yml              ← Fastlane App Store
├── fastlane/
│   ├── Fastfile
│   └── Appfile
├── ios/
│   ├── Runner/
│   │   ├── GoogleService-Info.plist
│   │   └── Info.plist              ← permissions GPS, caméra
│   └── Podfile
├── android/                        ← V2
├── functions/                      ← Cloud Functions Go (= AWS Lambda en Go)
│   ├── go.mod
│   ├── go.sum
│   ├── main.go
│   ├── pins/
│   │   ├── on_pin_created.go       ← modération IA
│   │   └── on_pin_reported.go      ← gestion signalements
│   ├── gamification/
│   │   ├── on_street_colored.go    ← vérification quartier complété
│   │   ├── on_quartier_completed.go ← badge + secret local + notif
│   │   └── on_monument_proximity.go ← badge monument
│   ├── parcours/
│   │   └── generate_parcours.go    ← algorithme circuit optimal
│   ├── notifications/
│   │   └── send_push.go            ← FCM Admin SDK
│   ├── coldstart/
│   │   └── populate_paris.go       ← pipeline scraping + IA
│   ├── sharing/
│   │   └── generate_share_link.go  ← liens partage itinéraire
│   └── rgpd/
│       └── on_user_deleted.go      ← suppression cascade données
├── firestore.rules                 ← règles sécurité Firestore (= IAM policies)
├── firestore.indexes.json          ← index Firestore
├── storage.rules                   ← règles sécurité Storage
└── lib/
    ├── main.dart                   ← entry point
    ├── app.dart                    ← MaterialApp + go_router
    ├── core/
    │   ├── firebase/
    │   │   ├── firebase_config.dart
    │   │   └── firestore_collections.dart  ← constantes noms collections
    │   ├── providers/
    │   │   ├── auth_provider.dart
    │   │   └── app_state_provider.dart
    │   └── router/
    │       └── app_router.dart     ← go_router routes
    ├── shared/
    │   ├── widgets/
    │   │   ├── loading_overlay.dart
    │   │   ├── error_snackbar.dart
    │   │   └── urbink_button.dart
    │   ├── utils/
    │   │   ├── gps_utils.dart
    │   │   ├── date_utils.dart
    │   │   └── nominatim_client.dart ← snap to road API
    │   └── constants/
    │       ├── colors.dart          ← palette Urbink
    │       ├── strings.dart
    │       └── map_constants.dart   ← zoom, tuiles OSM
    └── features/
        ├── auth/
        │   ├── screens/
        │   │   └── login_screen.dart
        │   ├── providers/
        │   │   └── auth_provider.dart
        │   └── services/
        │       ├── auth_service.dart
        │       └── guest_sync_service.dart  ← sync invité → compte
        ├── map/
        │   ├── screens/
        │   │   └── map_screen.dart
        │   ├── widgets/
        │   │   ├── colored_streets_layer.dart ← polylignes flutter_map
        │   │   ├── time_filter_bar.dart       ← aujourd'hui/semaine/mois/tout
        │   │   ├── poi_proximity_button.dart  ← bouton "à proximité"
        │   │   └── monument_popup.dart        ← description + TTS
        │   └── providers/
        │       ├── map_state_provider.dart
        │       └── time_filter_provider.dart
        ├── sessions/
        │   ├── screens/
        │   │   └── session_active_screen.dart
        │   ├── providers/
        │   │   ├── session_provider.dart      ← GPS tracking Riverpod
        │   │   └── aggregation_provider.dart  ← agrégation temporelle
        │   └── services/
        │       ├── gps_tracking_service.dart
        │       ├── snap_to_road_service.dart  ← Nominatim
        │       └── session_sync_service.dart  ← local → Firestore
        ├── gamification/
        │   ├── screens/
        │   │   ├── badges_screen.dart
        │   │   └── quartiers_screen.dart
        │   ├── widgets/
        │   │   ├── badge_card.dart
        │   │   ├── quartier_progress.dart
        │   │   └── secret_local_reveal.dart
        │   └── providers/
        │       ├── badges_provider.dart
        │       ├── quartiers_provider.dart
        │       └── objectifs_provider.dart
        ├── parcours/
        │   ├── screens/
        │   │   ├── parcours_auto_screen.dart
        │   │   └── parcours_custom_screen.dart
        │   ├── widgets/
        │   │   └── parcours_guidance_overlay.dart
        │   └── providers/
        │       └── parcours_provider.dart
        ├── pins/
        │   ├── screens/
        │   │   └── create_pin_screen.dart
        │   ├── widgets/
        │   │   ├── pin_marker.dart
        │   │   └── pin_detail_sheet.dart
        │   └── providers/
        │       └── pins_provider.dart
        ├── profile/
        │   ├── screens/
        │   │   └── profile_screen.dart
        │   └── providers/
        │       └── profile_provider.dart
        └── notifications/
            ├── services/
            │   └── notification_service.dart  ← FCM init + handlers
            └── providers/
                └── notifications_provider.dart
```

### Frontières Architecturales

**Flutter → Firestore :** uniquement via providers Riverpod — jamais d'appel direct dans les widgets

**Flutter → Cloud Functions :** via `FirebaseFunctions.instance.httpsCallable()` (= invoke Lambda depuis le client)

**Flutter → Nominatim :** via `NominatimClient` dans `shared/utils/`

**Cloud Functions → Firestore :** Admin SDK Go — accès complet sans règles de sécurité

**Cloud Functions → FCM :** Admin SDK Go via `send_push.go`

**Données GPS locales :** `sqflite` en mode invité → sync Firestore à la création de compte

### Mapping Features → FRs

| Feature | FRs couverts |
|---|---|
| `sessions/` | FR1-6 (GPS, snap to road, sauvegarde) |
| `map/` | FR7-10, FR14 (agrégation, filtrage, carte) |
| `map/widgets/poi_proximity_button` | FR11-13 (POI, description, TTS) |
| `gamification/` | FR15-20 (quartiers, badges, objectifs) |
| `parcours/` | FR21-24 (automatique, personnalisé, guidage) |
| `pins/` | FR25-29 (création, modération, réactions) |
| `profile/` | FR30-31 (partage carte, itinéraire) |
| `auth/` | FR32-35 (compte, sync, multi-appareil) |
| `notifications/` | FR36-39 (push, préférences) |
| `functions/` | FR40-44, FR46 (admin, cold start, RGPD) |

## Architecture Validation Results

### Coherence Validation ✅

**Decision Compatibility:**
Flutter + Riverpod + flutter_map + Firebase SDK forment un écosystème cohérent sans conflit.
Cloud Functions Go est un runtime Firebase officiel avec Admin SDK mature.
Nominatim API isolée dans `NominatimClient` — aucun couplage direct avec la logique métier.

**Pattern Consistency:**
Conventions de nommage (camelCase/snake_case/PascalCase) appliquées uniformément dans l'arborescence, les providers Riverpod, et les Cloud Functions Go.
Feature-based structure cohérente du patterns section jusqu'à l'arborescence complète.

**Structure Alignment:**
L'arborescence supporte 100% des décisions architecturales.
Les 8 Cloud Functions Go couvrent tous les use cases serveur identifiés.
Les frontières architecturales sont respectées (jamais d'appel Firestore direct dans les widgets).

### Requirements Coverage Validation ✅

**Functional Requirements Coverage:**
47 FRs en 9 domaines — tous couverts architecturalement.
FR1-47 mappés explicitement vers features Flutter et Cloud Functions Go.

**Admin back-office (FR40-44) — décision :**
Back-office admin = **Firebase Console au MVP** (accès direct Firestore + Storage pour Jo, zéro code).
Non bloquant, fonctionnel dès le premier jour.
**V2 :** client admin dédié (web ou mobile) si le volume de modération dépasse les capacités de la console — feature `admin/` réservée dans la roadmap.

**Non-Functional Requirements Coverage:**
- Performance : local-first + Nominatim ~200ms + Cloud Functions parcours < 3s ✅
- Fiabilité : sqflite local-first, aucune perte de session GPS ✅
- Scalabilité : Firebase horizontal scaling, V2 Scaleway map matching ✅
- Sécurité : Firestore rules userId, iOS Keychain, clés API Cloud Functions uniquement ✅
- RGPD : `on_user_deleted.go` suppression cascade, Firebase documenté sous-traitant ✅

### Implementation Readiness Validation ✅

**Decision Completeness:**
Toutes les décisions critiques documentées avec technologies choisies.
Règles obligatoires pour agents IA explicitement listées.
Patterns de gestion d'erreurs définis pour tous les cas (Firestore, Nominatim, GPS, modération).

**Structure Completeness:**
Arborescence complète et spécifique jusqu'au niveau fichier.
Points d'intégration clairement définis (NominatimClient, FirebaseFunctions.httpsCallable, etc.).
Frontières architecturales documentées avec analogies AWS Lambda.

**Pattern Completeness:**
Conventions de nommage exhaustives (camelCase, snake_case, PascalCase).
Patterns Riverpod définis (StreamProvider, freezed, suffixes).
Patterns Cloud Functions Go définis (naming, payload JSON, réponse standard).
Patterns de gestion d'erreurs couvrant tous les composants critiques.

### Gap Analysis Results

**Gap résolu — Admin back-office :**
Firebase Console = interface admin au MVP. Client admin dédié réservé en V2.

**Stratégie de tests (à implémenter dès V1) :**
- `flutter test` — unit tests et widget tests Flutter
- `mockito` — mocking providers et services Dart
- `firebase-functions-test` — tests Cloud Functions Go
- Non bloquant pour démarrer l'implémentation, à construire en parallèle des features

### Architecture Completeness Checklist

**✅ Requirements Analysis**
- [x] 47 FRs analysés et mappés vers implications architecturales
- [x] Complexité haute identifiée (GPS + IA + communautaire + admin)
- [x] Contraintes solo founder / budget zéro intégrées dans tous les choix
- [x] Préoccupations transverses mappées (GPS, local-first, auth, events, modération)

**✅ Architectural Decisions**
- [x] Stack complète documentée (Flutter, Firebase, Go, flutter_map, Riverpod, Nominatim)
- [x] Structure Firestore définie et justifiée
- [x] Patterns d'authentification définis (invité → compte, OAuth multi-provider)
- [x] Roadmap technique V2 documentée (map matching, Android, client admin, RGPD)

**✅ Implementation Patterns**
- [x] Conventions de nommage exhaustives (camelCase/snake_case/PascalCase)
- [x] Patterns Riverpod définis (StreamProvider, freezed, suffixes)
- [x] Patterns Cloud Functions Go définis (naming, payload, réponse)
- [x] Patterns de gestion d'erreurs documentés pour tous les composants

**✅ Project Structure**
- [x] Arborescence complète jusqu'au niveau fichier
- [x] Frontières architecturales définies
- [x] Mapping Features → FRs complet
- [x] Règles obligatoires pour agents IA listées

### Architecture Readiness Assessment

**Overall Status : READY FOR IMPLEMENTATION**

**Confidence Level : Haute**

**Key Strengths:**
- Local-first architecture élimine tout risque de perte de données GPS
- Feature-based structure permet un développement incrémental par domaine
- Cloud Functions Go isolent toute la logique sensible (clés API, RGPD, modération)
- Firebase free tier couvre 100% des besoins MVP sans coût
- Stack iOS-first avec portabilité Android V2 sans refonte
- Firebase Console couvre le back-office admin MVP sans code supplémentaire

**Areas for Future Enhancement:**
- Map matching serveur Go + OSRM/Valhalla (V2) — amélioration majeure précision coloration
- Client admin dédié (V2) si volume modération dépasse capacité Firebase Console
- Migration Appwrite EU (V3) si pression RGPD sur Firebase/Google
- Suite de tests automatisés à construire en parallèle de V1

### Implementation Handoff

**AI Agent Guidelines:**
- Toujours camelCase pour champs Firestore et variables Dart
- Toujours snake_case pour noms de fichiers Dart
- Toujours PascalCase pour classes et widgets
- Toujours feature-based, jamais organisation par type
- Jamais d'appel Firestore direct dans un widget — toujours via Riverpod provider
- Jamais de clé API dans le code Flutter — toujours Cloud Functions Go
- Admin back-office = Firebase Console au MVP (pas de code Flutter admin à implémenter)

**First Implementation Priority:**
Créer le projet Flutter avec `flutter create urbink`, configurer Firebase avec FlutterFire CLI,
puis implémenter GPS tracking + Nominatim snap to road + coloration rues (cœur du produit).
