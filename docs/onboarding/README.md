# Onboarding développeur Urbink

## Avant de commencer

1. Lis `CLAUDE.md` à la racine — conventions obligatoires
2. Lis `_bmad-output/planning-artifacts/architecture.md` — décisions techniques
3. Lis `_bmad-output/planning-artifacts/epics.md` — stories à implémenter

## Setup local

```bash
# Flutter
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs

# Firebase
# Copie google-services.json (iOS: GoogleService-Info.plist) depuis le vault d'équipe
# Ne jamais committer ces fichiers
```

## Environnements Firebase

| Env | Projet Firebase |
|-----|----------------|
| dev | urbink-dev |
| staging | urbink-staging |
| prod | urbink-prod |

Switch via `.env.dev` / `.env.prod` — voir `architecture.md` pour les détails.

## Workflow par story

1. Prends une story dans `_bmad-output/planning-artifacts/epics.md`
2. Lis ses ACs (Given/When/Then)
3. Implémente uniquement ce que la story demande
4. Les ACs sont les critères de done
