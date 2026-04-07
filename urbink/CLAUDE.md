# Urbink — Instructions pour Claude Code

## Projet

**Urbink** est une app mobile iOS (Flutter) qui colorie les rues d'une ville au fur et à mesure que l'utilisateur les explore via GPS. Tagline : *"Every detour hides a discovery."*

## Documents de référence

Tous les documents de planification sont dans `_bmad-output/planning-artifacts/` :

| Document | Rôle |
|---|---|
| `prd.md` | 51 exigences fonctionnelles (FR1–FR47) + NFRs |
| `architecture.md` | Stack technique, structure Firestore, conventions de code |
| `ux-design-specification.md` | Design system, composants custom, parcours utilisateurs |
| `epics.md` | 12 epics, 56 stories avec ACs Given/When/Then |

**Avant d'implémenter quoi que ce soit, lis `architecture.md` pour connaître les conventions.**

## Stack technique

- **App mobile :** Flutter (iOS 16+, MVP)
- **State management :** Riverpod (`StreamProvider` pour Firestore, `freezed` pour les states)
- **Carte :** flutter_map + tuiles OpenStreetMap
- **Snap to road :** Nominatim API via `NominatimClient` (`shared/utils/nominatim_client.dart`)
- **Backend :** Firebase (Auth, Firestore, Storage, FCM)
- **Logique serveur :** Cloud Functions Go
- **Navigation :** go_router
- **Cache local :** sqflite (cache uniquement — source de vérité = Firestore)
- **CI/CD :** GitHub Actions + Fastlane

## Conventions de code — OBLIGATOIRES

```
camelCase   → champs Firestore, variables Dart
snake_case  → noms de fichiers Dart (map_screen.dart)
PascalCase  → classes et widgets Flutter (MapScreen, SessionProvider)
```

**Règles absolues :**
- Jamais d'appel Firestore direct dans un widget — toujours via un provider Riverpod
- Jamais de clé API dans le code Flutter — uniquement dans Cloud Functions Go
- Toujours organiser par feature (`lib/features/`), jamais par type
- Providers Riverpod nommés en camelCase + suffixe : `sessionProvider`, `mapStateProvider`

## Structure du projet Flutter

```
lib/
  features/
    map/          ← carte, coloration, flutter_map
    sessions/     ← GPS tracking, snap to road, agrégation
    gamification/ ← badges, quartiers, objectifs, secrets
    parcours/     ← automatique, personnalisé, guidage
    pins/         ← création, modération, affichage
    auth/         ← Firebase Auth, mode invité, sync
    notifications/← FCM, préférences
    profile/      ← compte, badges, historique
  shared/
    widgets/      ← UrbinkButton, UrbinkSnackBar, composants custom
    utils/        ← NominatimClient, gps_utils, date_utils
    constants/    ← colors.dart, typography.dart, spacing.dart
  core/
    firebase/     ← config Firebase, firestore_collections.dart
    providers/    ← Riverpod providers globaux
    router/       ← go_router config (app_router.dart)

functions/        ← Cloud Functions Go
  pins/           ← on_pin_created.go, on_pin_reported.go
  gamification/   ← on_street_colored.go, on_quartier_completed.go, on_monument_proximity.go
  parcours/       ← generate_parcours.go
  notifications/  ← send_push.go
  coldstart/      ← populate_paris.go
  sharing/        ← generate_share_link.go
  rgpd/           ← on_user_deleted.go
```

## Structure Firestore

```
/users/{userId}
  isPublic: bool
  sanctionCount: int
  suspendedUntil: timestamp
  fcmToken: string
  /sessions/{sessionId}
  /streets/{streetId}
  /badges/{badgeId}
  /parcours/{parcoursId}

/pins/{pinId}          ← status: pending|published|private|review|rejected
/posts/{postId}        ← fil d'actualité
/follows/{followId}    ← status: pending|accepted
/quartiers/{quartierId}← secretLocal, streetIds[]
/monuments/{monumentId}← proximityRadius, wikidataId, badgeId
```

## Design system Urbink

- **Ocre Chaud :** `#B8832E` (primary, boutons, accents)
- **Vert Sauge :** `#5A7A5A` (rues explorées)
- **Brun Profond :** `#1E1610` (texte principal)
- **Fond chaud :** `#FAFAF7` (background)
- **Typographie :** Crimson Pro (display/heading) + Inter (body)
- **Grille :** base 8px — `space-sm=8`, `space-md=16`, `space-lg=24`, `space-xl=32`
- **Design system :** Material 3 avec tokens Urbink overridés

## Composants custom à créer dans `shared/widgets/`

| Composant | Description |
|---|---|
| `MapStreetOverlay` | Couche flutter_map pour les rues colorées |
| `SessionCounter` | Pill flottant top-center métriques session |
| `CelebrationOverlay` | Animation plein écran badge/quartier (Lottie) |
| `FeedActivityItem` | Item feed social avec tracé miniature |
| `WeekHistogram` | Histogramme 7 jours activité |
| `BadgeGrid` | Grille badges monuments/quartiers |
| `RouteMapPreview` | Carte miniature tracé (small/medium/thumbnail) |
| `TransportModeSelector` | 3 chips segmentés 🚶🚴🚗 |

## Gestion d'erreurs

- **Firestore** → log Firebase Crashlytics, message générique à l'utilisateur
- **Nominatim** → retry x3 avec backoff exponentiel, fallback silencieux
- **GPS** → session continue sans interruption, log local
- **Réseau absent pendant session** → persist sqflite local, sync à la reconnexion

## Environnements

3 projets Firebase distincts : `urbink-dev` / `urbink-staging` / `urbink-prod`

Switch via `--dart-define=FLUTTER_ENV=<env>` (natif Flutter, pas de package) :

```bash
flutter run                                        # dev (défaut)
flutter run --dart-define=FLUTTER_ENV=staging
flutter build ipa --dart-define=FLUTTER_ENV=prod   # CI uniquement
```

Dans `main.dart` :
```dart
const env = String.fromEnvironment('FLUTTER_ENV', defaultValue: 'dev');
```

Flutter n'a aucun secret à gérer localement : Firebase config = `GoogleService-Info.plist` (déjà committé, non-secret), Nominatim = pas de clé, toutes les autres API = Cloud Functions Go.

Les secrets prod/staging (ex: clés Cloud Functions) vivent dans **Firebase Secret Manager**, jamais dans le repo Flutter.

`flutterfire configure` a été fait pour `urbink-dev` uniquement. Pour staging/prod (CI) :
```bash
flutterfire configure --project=urbink-staging --out=lib/firebase_options_staging.dart
flutterfire configure --project=urbink-prod    --out=lib/firebase_options_prod.dart
```

## Device de développement iOS

- iPhone configuré en mode développeur (Réglages → Confidentialité & Sécurité)
- Compte Apple **personnel** connecté dans Xcode — suffisant pour run sur device en dev
- **Limite :** compte personnel insuffisant pour l'App Store (nécessite Apple Developer $99/an)
- Lancer sur device : `flutter run -d <device-id>` | lister : `flutter devices`

## Comment travailler sur ce projet

1. Choisis une story dans `_bmad-output/planning-artifacts/epics.md`
2. Lis les ACs (Given/When/Then) — ce sont les critères de done
3. Consulte `architecture.md` pour les décisions techniques qui s'appliquent
4. Implémente uniquement ce que la story demande — pas d'over-engineering
5. Respecte les conventions ci-dessus sans exception

## Maintenance de la documentation `docs/`

Mets à jour `docs/` dès qu'une des situations suivantes se présente :

### `docs/adr/` — nouvelle décision technique

Crée un nouvel ADR si tu :
- Choisis une librairie ou un package (ex: `cached_network_image` plutôt que `image_cached`)
- Adoptes un pattern architectural non évident (ex: repository pattern pour le cache)
- Abandonnes ou remplaces une technologie choisie précédemment
- Fais un compromis technique avec des implications durables

Format du fichier : `NNN-titre-court.md` (incrémente le numéro). Ajoute l'entrée dans `docs/adr/README.md`.

### `docs/api/` — nouvelle API ou contrainte externe

Mets à jour si tu :
- Intègres une nouvelle API externe (endpoint, auth, rate limit)
- Découvres une contrainte ou un comportement non documenté d'une API existante
- Ajoutes un wrapper ou client custom pour une API

### `docs/onboarding/` — setup ou workflow non évident

Mets à jour si tu :
- Ajoutes une étape de setup qui n'est pas dans le README Flutter standard
- Découvres un piège ou une subtilité d'environnement (Firebase, iOS signing, etc.)
- Changes le workflow de dev (nouveau script, nouvelle commande nécessaire)
