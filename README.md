# Urbink

> *Every detour hides a discovery.*

Urbink transforme la carte de n'importe quelle ville en empreinte personnelle d'exploration. Les rues se colorient progressivement via GPS au fil de tes déplacements — à pied, à vélo ou en voiture. Pas de fog of war : juste un surligneur personnel qui révèle ce que tu as déjà parcouru.

**Google Maps sait où tu vas. Urbink sait où tu es déjà allé.**

---

## Fonctionnalités

- **Exploration GPS en temps réel** — snap to road sur le réseau OSM, coloration progressive des rues
- **Historique & Filtrage** — agrégation de toutes tes sessions, filtrée par période (jour / semaine / mois / tout)
- **Gamification légère** — badges quartiers et monuments, secrets locaux, objectifs thématiques
- **Parcours** — génération automatique de circuit optimal ou tracé manuel
- **Points d'intérêt** — monuments illustrés, descriptions Wikidata, lecture audio TTS
- **Communauté** — pins photo géolocalisés, modération IA, réactions, profils public/privé
- **Mode invité** — aucun compte requis, progression Firestore dès le départ

---

## Stack technique

| Couche | Technologie |
|--------|-------------|
| Application mobile | Flutter (iOS 16+, MVP — Android V2) |
| State management | Riverpod + freezed |
| Carte | flutter_map + tuiles OpenStreetMap (ODbL) |
| Snap to road | Nominatim API |
| Backend | Firebase (Auth, Firestore, Storage, FCM) |
| Logique serveur | Cloud Functions Go |
| Navigation | go_router |
| Cache local | sqflite (local-first, sync cloud) |
| CI/CD | GitHub Actions + Fastlane |

---

## Setup local

### Prérequis

- Flutter SDK ≥ 3.11
- Xcode 15+ (iOS)
- Firebase CLI + FlutterFire CLI
- Go 1.22+ (Cloud Functions)

### Installation

```bash
cd urbink
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### Fichiers Firebase (ne jamais committer)

```bash
# iOS
ios/Runner/GoogleService-Info.plist      ← depuis le vault d'équipe

# Android (V2)
android/app/google-services.json        ← depuis le vault d'équipe
```

### Lancer l'app

```bash
flutter run                                        # dev (défaut)
flutter run --dart-define=FLUTTER_ENV=staging
flutter build ipa --dart-define=FLUTTER_ENV=prod   # CI uniquement
```

---

## Environnements Firebase

| Env | Projet Firebase |
|-----|-----------------|
| dev | urbink-dev |
| staging | urbink-staging |
| prod | urbink-prod |

---

## Structure du projet

```
urbink/
  lib/
    features/
      map/            ← carte, coloration, flutter_map
      sessions/       ← GPS tracking, snap to road, agrégation
      gamification/   ← badges, quartiers, objectifs, secrets
      parcours/       ← automatique, personnalisé, guidage
      pins/           ← création, modération, affichage
      auth/           ← Firebase Auth, mode invité, sync
      notifications/  ← FCM, préférences
      profile/        ← compte, badges, historique
    shared/
      widgets/        ← composants custom Urbink
      utils/          ← NominatimClient, gps_utils, date_utils
      constants/      ← colors.dart, typography.dart, spacing.dart
    core/
      firebase/
      providers/
      router/

functions/            ← Cloud Functions Go
docs/
  adr/                ← Architecture Decision Records
  api/                ← docs APIs externes
  onboarding/         ← setup & workflow
_bmad-output/
  planning-artifacts/ ← PRD, architecture, epics, UX spec
```

---

## Design system

| Token | Valeur |
|-------|--------|
| Ocre Chaud | `#B8832E` — boutons, accents |
| Vert Sauge | `#5A7A5A` — rues explorées |
| Brun Profond | `#1E1610` — texte principal |
| Fond chaud | `#FAFAF7` — background |
| Typographie | Crimson Pro (display) + Inter (body) |
| Grille | base 8px |

---

## Documentation

| Document | Contenu |
|----------|---------|
| [`_bmad-output/planning-artifacts/prd.md`](_bmad-output/planning-artifacts/prd.md) | 47 exigences fonctionnelles + NFRs |
| [`_bmad-output/planning-artifacts/architecture.md`](_bmad-output/planning-artifacts/architecture.md) | Stack, Firestore, conventions de code |
| [`_bmad-output/planning-artifacts/epics.md`](_bmad-output/planning-artifacts/epics.md) | 12 epics, 56+ stories avec ACs |
| [`_bmad-output/planning-artifacts/ux-design-specification.md`](_bmad-output/planning-artifacts/ux-design-specification.md) | Design system, composants, parcours UX |
| [`docs/onboarding/`](docs/onboarding/) | Onboarding développeur, setup iOS |
| [`docs/adr/`](docs/adr/) | Décisions techniques archivées |

---

## Crédits

Données cartographiques © [OpenStreetMap contributors](https://www.openstreetmap.org/copyright) (ODbL).
