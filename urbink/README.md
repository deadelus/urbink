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
flutterfire configure --project=urbink-dev --out=lib/firebase_options.dart
```

#### GoogleService-Info.plist (SDK natif Firebase iOS)

Télécharger depuis [Firebase Console](https://console.firebase.google.com) → projet `urbink-dev` → ⚙️ Paramètres → iOS et placer dans `ios/Runner/GoogleService-Info.plist`.

> Ce fichier est gitignore. En CI, il est écrit automatiquement depuis le secret GitHub `GOOGLE_SERVICE_INFO` de l'environment `ios-dev`/`ios-staging`/`ios-prod`.

#### google-services.json (Android)

**Requis pour tout build ou run Android** — optionnel uniquement si vous ciblez exclusivement iOS (MVP).

Télécharger depuis Firebase Console → projet `urbink-dev` → ⚙️ Paramètres → Android et placer dans `android/app/google-services.json`.

> Ce fichier est gitignored. Sans lui, `flutter run` ou `flutter build` Android échoue (le plugin `google-services` est actif). La CI actuelle ne cible qu'iOS — aucun build Android n'est déclenché.

### 3. Lancer l'app

```bash
flutter run   # dev — utilise le firebase_options.dart présent localement
```

> **Note sur `--dart-define=FLUTTER_ENV`** : ce flag alimente uniquement `FirebaseService.currentEnv` (valeur lisible côté code), mais **ne sélectionne pas** un environnement Firebase différent. L'environnement Firebase effectivement utilisé est déterminé par le contenu du fichier `firebase_options.dart` (gitignored) — en local, le fichier dev ; en CI, le fichier injecté depuis l'Environment GitHub (`ios-dev`, `ios-staging` ou `ios-prod`).

---

Pour la configuration CI/CD et le deploy TestFlight/App Store, voir [docs/onboarding/prod-setup.md](../docs/onboarding/prod-setup.md).
