# Story 1.6 : CI/CD pipeline + monitoring

## Story

En tant que **développeur**,
Je veux un pipeline CI/CD automatisé et un monitoring de production,
Afin de détecter les régressions rapidement et publier sur l'App Store en confiance.

## Acceptance Criteria

- [x] **AC1 — CI sur push** : `.github/workflows/ci.yml` déclenche `flutter analyze + test` + build iOS (no codesign) sur push vers `main` ou `develop`, et sur toutes les PRs ciblant ces branches. Résultat visible dans l'interface GitHub.
- [x] **AC2 — Deploy TestFlight / App Store** : deux workflows distincts — `deploy-ios-staging.yml` (tag `vX.Y.Z-beta` → TestFlight) et `deploy-ios-prod.yml` (tag `vX.Y.Z` → App Store). Chacun utilise un GitHub Environment dédié (`ios-staging`, `ios-prod`) pour isoler les secrets sans préfixes. Fastlane lanes `staging` et `production` correspondantes. Identifiants App Store Connect lus depuis les secrets GitHub, jamais committés.
- [x] **AC3 — Crashlytics** : `FirebaseCrashlytics.instance` initialisé dans `FirebaseService.initialize()`. `FlutterError.onError` redirige vers `recordFlutterFatalError`. `PlatformDispatcher.instance.onError` capture les erreurs async fatales. Collection désactivée en `kDebugMode`.
- [x] **AC4 — Analytics app_open** : `firebase_analytics: ^11.3.4` ajouté. `FirebaseAnalytics.instance` configuré dans `FirebaseService`. L'événement `app_open` est loggué automatiquement par le SDK. Collection désactivée en `kDebugMode`.

## Tasks / Subtasks

- [x] Créer `.github/workflows/ci.yml` (test + analyze + build iOS no codesign, environment `ios-dev`)
- [x] Créer `.github/workflows/deploy-ios-staging.yml` (tag `vX.Y.Z-beta` → Fastlane `staging` → TestFlight)
- [x] Créer `.github/workflows/deploy-ios-prod.yml` (tag `vX.Y.Z` → Fastlane `production` → App Store)
- [x] Créer `urbink/ios/fastlane/Fastfile` (lanes `staging` + `production`)
- [x] Créer `urbink/ios/fastlane/Appfile` (app_identifier)
- [x] Créer `urbink/ios/fastlane/Gemfile` (gem fastlane)
- [x] Créer `urbink/ios/ExportOptions.plist` (method: app-store, placeholder Team ID)
- [x] Ajouter `firebase_analytics: ^11.3.4` dans pubspec.yaml + `flutter pub get`
- [x] Brancher Crashlytics + Analytics dans `firebase_service.dart`
- [x] `flutter analyze --no-pub` : 0 issue ✓
- [x] `flutter test --no-pub` : 102/102 ✓

## Dev Notes

**Secrets GitHub à configurer** avant le premier deploy :
- `APP_STORE_CONNECT_API_KEY_ID` — Key ID depuis App Store Connect
- `APP_STORE_CONNECT_API_ISSUER_ID` — Issuer ID depuis App Store Connect
- `APP_STORE_CONNECT_API_KEY_CONTENT` — Contenu clé .p8 encodé en base64
- `MATCH_PASSWORD` — Mot de passe chiffrement match
- `MATCH_GIT_URL` — URL du repo Git privé des certificates

**ExportOptions.plist** : le `TEAM_ID_PLACEHOLDER` doit être remplacé par le Team ID Apple Developer lors de la config prod (compte Developer $99/an requis).

**Crashlytics kDebugMode** : la collection est désactivée en debug pour éviter le bruit dans le dashboard Firebase. En staging/prod, elle s'active automatiquement.

**app_open Analytics** : Firebase Analytics loggue cet événement automatiquement à chaque démarrage — aucun appel manuel nécessaire. Délai standard d'apparition dans la console Firebase : 24h.

**CI macos-15** : le runner macOS est nécessaire pour le build iOS. `flutter-action` avec `cache: true` réduit le temps de téléchargement Flutter entre les runs.

## Dev Agent Record

- Agent : Claude Sonnet 4.6
- Date : 2026-04-09
- Branche : `epic-1/story-1.6-ci-cd-monitoring`
- Tests : aucun nouveau (pas de logique testable unitairement pour CI/CD), 102 existants ✓

## File List

### Créés
- `.github/workflows/ci.yml` — pipeline CI (test + analyze + build iOS no codesign)
- `.github/workflows/deploy-ios-staging.yml` — deploy staging vers TestFlight (tag `-beta`)
- `.github/workflows/deploy-ios-prod.yml` — deploy prod vers App Store
- `urbink/ios/fastlane/Fastfile` — lanes `staging` et `production`
- `urbink/ios/fastlane/Appfile` — app identifier Fastlane
- `urbink/ios/fastlane/Gemfile` — dépendance gem fastlane
- `urbink/ios/ExportOptions.plist` — options export IPA App Store

### Modifiés
- `urbink/pubspec.yaml` — ajout `firebase_analytics: ^11.3.4`
- `urbink/lib/core/firebase/firebase_service.dart` — Crashlytics + Analytics init

## Change Log

| Version | Date | Auteur | Description |
|---------|------|--------|-------------|
| 1.0 | 2026-04-09 | Claude Sonnet 4.6 | Implémentation initiale Story 1.6 |
| 1.1 | 2026-04-10 | Claude Sonnet 4.6 | Refactor : firebase_options.dart unique + GoogleService-Info.plist unique, GitHub Environments isolent les secrets |

## Status

done
