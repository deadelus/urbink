# Mise en production — checklist de configuration

Tout ce qui est nécessaire avant de faire un premier vrai deploy vers TestFlight ou l'App Store.
Aucun de ces éléments n'est dans le repo (c'est voulu).

---

## 1. Firebase — fichiers options (tous environnements)

Les fichiers `firebase_options_*.dart` sont **exclus du repo** (clés API). Un template avec des placeholders est commité pour guider le setup.

### En local — setup initial (à faire une fois par machine)

```bash
cd ~/Code/urbink/urbink

# Dev : copier le template et remplir les vraies valeurs
cp lib/firebase_options_dev.template.dart lib/firebase_options_dev.dart
# → ouvrir le fichier et remplacer les PLACEHOLDER_* par les valeurs
#   du projet urbink-dev dans la console Firebase

# Staging et prod : générer via flutterfire CLI
flutterfire configure --project=urbink-staging --out=lib/firebase_options_staging.dart
flutterfire configure --project=urbink-prod    --out=lib/firebase_options_prod.dart
```

Sélectionner **iOS uniquement** à chaque fois pour staging/prod.

### CI — aucun secret Firebase nécessaire

La CI copie simplement le template pour que le build compile. Les placeholders ne connectent pas à Firebase, mais suffisent pour vérifier que le code compile correctement. Les vrais identifiants ne sont jamais sur GitHub.

### Mise à jour firebase_service.dart

Une fois les fichiers staging/prod générés, mettre à jour `lib/core/firebase/firebase_service.dart` pour les importer :

```dart
// En haut du fichier, ajouter :
import 'package:urbink/firebase_options_staging.dart' as staging;
import 'package:urbink/firebase_options_prod.dart' as prod;

// Remplacer les StateError par :
case 'prod':
  return prod.DefaultFirebaseOptions.currentPlatform;
case 'staging':
  return staging.DefaultFirebaseOptions.currentPlatform;
```

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
| `FIREBASE_OPTIONS` | `firebase_options_dev.dart` | `firebase_options_staging.dart` | `firebase_options_prod.dart` |
| `GOOGLE_SERVICE_INFO` | — | `GoogleService-Info-ios-staging.plist` | `GoogleService-Info-ios-prod.plist` |
| `APP_STORE_CONNECT_API_KEY_ID` | — | Key ID (Apple Developer) | Key ID (Apple Developer) |
| `APP_STORE_CONNECT_API_ISSUER_ID` | — | Issuer ID | Issuer ID |
| `APP_STORE_CONNECT_API_KEY_CONTENT` | — | Clé `.p8` base64 | Clé `.p8` base64 |
| `MATCH_PASSWORD` | — | mot de passe match | mot de passe match |
| `MATCH_GIT_URL` | — | URL repo certificats | URL repo certificats |

> Les secrets App Store Connect peuvent être identiques en staging et prod si tu n'as qu'un seul compte Apple Developer.

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
| Template `firebase_options_dev.template.dart` | Non (déjà commité) | Non (déjà commité) | — | — |
| Compte Apple Developer $99 | Non | Non | Oui | Oui |
| ExportOptions.plist Team ID | Non | Non | Oui | Oui |
| App Store Connect API Key | Non | Non | Oui | Oui |
| GitHub Secrets App Store | Non | Non | Oui | Oui |
| Fastlane Match | Non | Non | Oui | Oui |
