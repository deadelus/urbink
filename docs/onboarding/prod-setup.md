# Mise en production — checklist de configuration

Tout ce qui est nécessaire avant de faire un premier vrai deploy vers TestFlight ou l'App Store.
Aucun de ces éléments n'est dans le repo (c'est voulu).

---

## 1. Firebase — fichiers options (tous environnements)

Les fichiers `firebase_options_*.dart` sont **exclus du repo** (clés API). Ils sont recréés en CI depuis des GitHub Secrets, et localement via `flutterfire configure`.

### En local (à faire une fois par machine)

```bash
cd ~/Code/urbink/urbink

flutterfire configure --project=urbink-dev     --out=lib/firebase_options_dev.dart
flutterfire configure --project=urbink-staging --out=lib/firebase_options_staging.dart
flutterfire configure --project=urbink-prod    --out=lib/firebase_options_prod.dart
```

Sélectionner **iOS uniquement** à chaque fois.

### GitHub Secrets — pour la CI

Va dans **github.com/deadelus/urbink → Settings → Secrets and variables → Actions**.

Pour chaque fichier généré, créer un secret avec le contenu complet du fichier Dart :

```bash
# Copier le contenu d'un fichier dans le presse-papier
cat lib/firebase_options_dev.dart | pbcopy
```

| Secret | Fichier source |
|--------|---------------|
| `FIREBASE_OPTIONS_DEV` | `lib/firebase_options_dev.dart` |
| `FIREBASE_OPTIONS_PROD` | `lib/firebase_options_prod.dart` |

> `FIREBASE_OPTIONS_STAGING` n'est pas encore utilisé en CI (pas de pipeline staging). À ajouter si besoin.

La CI (`ci.yml`) recrée `firebase_options_dev.dart` depuis `FIREBASE_OPTIONS_DEV` avant chaque build.
Le deploy (`deploy.yml`) recrée `firebase_options_prod.dart` depuis `FIREBASE_OPTIONS_PROD`.

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

## 5. GitHub Secrets — récapitulatif complet

| Secret | Usage | Valeur |
|--------|-------|--------|
| `FIREBASE_OPTIONS_DEV` | CI test + build | Contenu de `firebase_options_dev.dart` |
| `FIREBASE_OPTIONS_PROD` | Deploy TestFlight | Contenu de `firebase_options_prod.dart` |
| `APP_STORE_CONNECT_API_KEY_ID` | Fastlane upload | Key ID de l'étape 4 |
| `APP_STORE_CONNECT_API_ISSUER_ID` | Fastlane upload | Issuer ID de l'étape 4 |
| `APP_STORE_CONNECT_API_KEY_CONTENT` | Fastlane upload | Contenu `.p8` encodé base64 |
| `MATCH_PASSWORD` | Fastlane match | Mot de passe chiffrement certificats |
| `MATCH_GIT_URL` | Fastlane match | URL SSH repo Git privé certificats |

---

## 6. Fastlane Match — certificats et profiles

```bash
cd urbink/ios
bundle exec fastlane match init
# → renseigner l'URL Git privée (ex: git@github.com:deadelus/urbink-certs.git)

bundle exec fastlane match appstore
```

---

## 7. Déclencher le premier deploy

```bash
git tag v1.0.0
git push origin v1.0.0
# → déclenche deploy.yml → Fastlane beta → TestFlight
```

---

## Résumé — ce qui bloque quoi

| Étape | CI (tests) | Build iOS | TestFlight | App Store |
|-------|-----------|-----------|------------|-----------|
| Secret `FIREBASE_OPTIONS_DEV` | Oui | Oui | — | — |
| Secret `FIREBASE_OPTIONS_PROD` | — | — | Oui | Oui |
| Compte Apple Developer $99 | Non | Non | Oui | Oui |
| ExportOptions.plist Team ID | Non | Non | Oui | Oui |
| App Store Connect API Key | Non | Non | Oui | Oui |
| GitHub Secrets App Store | Non | Non | Oui | Oui |
| Fastlane Match | Non | Non | Oui | Oui |
