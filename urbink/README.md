# Urbink — Flutter App

## Setup développement

### 1. Cloner et installer les dépendances

```bash
flutter pub get
cd ios && pod install && cd ..
```

### 2. Configurer Firebase (dev)

Tous les fichiers Firebase sont gitignorés — ils contiennent des clés API. À faire une fois par machine.

#### Fichier Dart (options Firebase)

```bash
flutterfire configure --project=urbink-dev --out=lib/firebase_options_dev.dart
```

#### GoogleService-Info.plist (SDK natif Firebase iOS)

Télécharger depuis [Firebase Console](https://console.firebase.google.com) → projet `urbink-dev` → ⚙️ Paramètres → iOS et placer dans `ios/Runner/GoogleService-Info.plist`.

> Ce fichier est gitignore. En CI, il est écrit automatiquement depuis le secret GitHub `GOOGLE_SERVICE_INFO` de l'environment `ios-dev`/`ios-staging`/`ios-prod`.

#### google-services.json (Android — optionnel pour le MVP iOS)

Télécharger depuis Firebase Console → projet `urbink-dev` → ⚙️ Paramètres → Android et placer dans `android/app/`.

### 3. Lancer l'app

```bash
flutter run                                       # dev (défaut)
flutter run --dart-define=FLUTTER_ENV=staging
flutter build ipa --dart-define=FLUTTER_ENV=prod  # CI uniquement
```

---

Pour la configuration CI/CD et le deploy TestFlight/App Store, voir [docs/onboarding/prod-setup.md](../docs/onboarding/prod-setup.md).
