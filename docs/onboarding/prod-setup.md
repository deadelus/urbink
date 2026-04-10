# Mise en production — checklist de configuration

Tout ce qui est nécessaire avant de faire un premier vrai deploy vers TestFlight ou l'App Store.
Aucun de ces éléments n'est dans le repo (c'est voulu).

---

## 1. Firebase — fichiers options (tous environnements)

Le fichier `lib/firebase_options.dart` est **exclu du repo** (clés API). Un seul fichier est utilisé dans tous les environnements — c'est le GitHub Environment qui isole les valeurs via le secret `FIREBASE_OPTIONS`.

### En local — setup initial (à faire une fois par machine)

```bash
cd ~/Code/urbink/urbink

# Générer le fichier attendu par l'app depuis le projet Firebase dev
flutterfire configure --project=urbink-dev --out=lib/firebase_options.dart
```

Sélectionner **iOS uniquement** (MVP iOS).

### CI — jobs test/analyze

Le job `test` n'a pas accès aux secrets Firebase (pas d'environment configuré). Il génère un stub compilable `lib/firebase_options.dart` avec des valeurs placeholder. Les tests ne contactent pas Firebase réellement — ils mockent les services via les providers Riverpod.

### CI — jobs build et deploy

Les jobs `build-ios`, `deploy-ios-staging` et `deploy-ios-prod` utilisent les GitHub Environments (`ios-dev`, `ios-staging`, `ios-prod`). Le secret `FIREBASE_OPTIONS` de chaque environment contient le vrai contenu du fichier `firebase_options.dart` pour l'environnement correspondant — écrit via `printf '%s'` pour préserver le format multi-lignes exact.

### `firebase_service.dart` — architecture simplifiée

Depuis cette story, `firebase_service.dart` utilise directement `DefaultFirebaseOptions.currentPlatform` sans switch sur l'environnement. C'est le contenu du fichier `firebase_options.dart` qui détermine le projet Firebase — injecté via le secret GitHub de l'environment correspondant en CI.

---

## 2. Apple Developer — compte $99/an

**Obligatoire pour TestFlight et l'App Store.** Le compte personnel actuel suffit uniquement pour lancer sur device en développement.

Après avoir souscrit :
1. Créer l'App ID `com.urbink.app` dans [developer.apple.com → Certificates, Identifiers & Profiles](https://developer.apple.com/account/resources/identifiers/list)
2. Créer une App dans [App Store Connect](https://appstoreconnect.apple.com)
3. Relever le **Team ID** (visible dans developer.apple.com → Membership)

---

## 3. ExportOptions.plist — Team ID

Fichier : `urbink/ios/ExportOptions.plist`

Remplacer `TEAM_ID_PLACEHOLDER` par le vrai Team ID Apple :

```xml
<key>teamID</key>
<string>ABCDE12345</string>
```

---

## 4. App Store Connect API Key

Nécessaire pour que Fastlane uploade vers TestFlight sans mot de passe.

1. [App Store Connect → Utilisateurs et accès → Clés](https://appstoreconnect.apple.com/access/api)
2. Générer une clé avec le rôle **App Manager**
3. Télécharger le fichier `.p8` (une seule fois)
4. Noter le **Key ID** et l'**Issuer ID**

Encoder la clé en base64 :
```bash
base64 -i AuthKey_XXXX.p8 | pbcopy
```

---

## 5. GitHub Environments + Secrets

Créer 3 environments dans **github.com/deadelus/urbink → Settings → Environments** :
`ios-dev`, `ios-staging`, `ios-prod`

Les secrets ont le **même nom** dans chaque environment — c'est l'environment qui isole les valeurs.

| Secret | `ios-dev` | `ios-staging` | `ios-prod` |
|--------|----------|--------------|-----------|
| `FIREBASE_OPTIONS` | Contenu de `lib/firebase_options.dart` (projet `urbink-dev`) | Contenu de `lib/firebase_options.dart` (projet `urbink-staging`) | Contenu de `lib/firebase_options.dart` (projet `urbink-prod`) |
| `GOOGLE_SERVICE_INFO` | `GoogleService-Info.plist` (projet `urbink-dev`) | `GoogleService-Info.plist` (projet `urbink-staging`) | `GoogleService-Info.plist` (projet `urbink-prod`) |
| `APP_STORE_CONNECT_API_KEY_ID` | — | Key ID (Apple Developer) | Key ID (Apple Developer) |
| `APP_STORE_CONNECT_API_ISSUER_ID` | — | Issuer ID | Issuer ID |
| `APP_STORE_CONNECT_API_KEY_CONTENT` | — | Clé `.p8` base64 | Clé `.p8` base64 |
| `APPLE_TEAM_ID` | — | Team ID Apple Developer | Team ID Apple Developer |
| `MATCH_PASSWORD` | — | mot de passe match | mot de passe match |
| `MATCH_GIT_URL` | — | URL repo certificats | URL repo certificats |

> Les secrets App Store Connect peuvent être identiques en staging et prod si tu n'as qu'un seul compte Apple Developer.
> Pour générer le contenu du secret `FIREBASE_OPTIONS` : `flutterfire configure --project=urbink-<env> --out=lib/firebase_options.dart` puis copier le fichier généré comme valeur du secret.

---

## 6. Fastlane Match — certificats et profiles

```bash
cd urbink/ios
bundle exec fastlane match init
# → renseigner l'URL Git privée (ex: git@github.com:deadelus/urbink-certs.git)

bundle exec fastlane match appstore
```

---

## 7. Déclencher un deploy

```bash
# Staging → TestFlight (tag avec suffixe -beta)
git tag v1.0.0-beta
git push origin v1.0.0-beta
# → déclenche deploy-staging.yml → Fastlane staging → TestFlight

# Prod → App Store (tag sans suffixe)
git tag v1.0.0
git push origin v1.0.0
# → déclenche deploy-prod.yml → Fastlane production → App Store
```

---

## Résumé — ce qui bloque quoi

| Étape | CI (tests) | Build iOS | TestFlight | App Store |
|-------|-----------|-----------|------------|-----------|
| Secret `FIREBASE_OPTIONS` (environment `ios-dev`) | Non (stub généré automatiquement) | Oui | — | — |
| Secret `FIREBASE_OPTIONS` (environment `ios-staging`) | Non | — | Oui | — |
| Secret `FIREBASE_OPTIONS` (environment `ios-prod`) | Non | — | — | Oui |
| Secret `GOOGLE_SERVICE_INFO` (ios-dev) | Non | Oui | — | — |
| Compte Apple Developer $99 | Non | Non | Oui | Oui |
| ExportOptions.plist Team ID | Non | Non | Oui | Oui |
| App Store Connect API Key | Non | Non | Oui | Oui |
| GitHub Secrets App Store | Non | Non | Oui | Oui |
| Fastlane Match | Non | Non | Oui | Oui |
