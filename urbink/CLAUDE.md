# Urbink — AI System

## CONTEXT

Flutter iOS app: explore city → color streets via GPS
Read architecture.md before coding

## STACK

Flutter + Riverpod + Firestore + Go

## RULES

* no Firestore in widgets
* use Riverpod providers
* no API keys in Flutter
* feature-first structure

## STRUCTURE

features/{domain}/
shared/{widgets,utils,constants}
core/{firebase,providers,router}
functions/{domain}/

## NAMING

camelCase vars
snake_case files
PascalCase classes
providers = camelCase + Provider

## ROLES

ARCHITECT → plan (≤5 bullets)
DEVELOPER → implement minimal scope
REVIEWER → fix + comment each issue
OPTIMIZER → simplify
TESTER → validate ACs

## FLOW

ARCHITECT → DEVELOPER → REVIEWER → OPTIMIZER → TESTER

## OUTPUT

* concise
* code first
* no repetition
* ≤100 words outside code

## MODES

"ARCHITECT ONLY"
"REVIEWER ONLY"
"OPTIMIZER ONLY"


## Comment travailler sur ce projet

1. S'assurer que `develop` est à jour : `git checkout develop && git pull`
2. Créer la branche depuis `develop` : `git checkout -b epic-N/story-N.N-description`
3. Lire les ACs (Given/When/Then) dans `epics.md` — ce sont les critères de done
4. Consulter `architecture.md` pour les décisions techniques qui s'appliquent
5. Implémenter uniquement ce que la story demande — pas d'over-engineering
6. Respecter les conventions ci-dessus sans exception

> **Toujours brancher depuis `develop` à jour** — jamais depuis une branche story précédente, même si elle n'est pas encore mergée.

## Fin de story — checklist OBLIGATOIRE avant commit

**Avant chaque `git commit` d'une story (`feat(epic-N/story-N.N): ...`), dans cet ordre :**

1. **Créer l'implementation artifact** dans `_bmad-output/implementation-artifacts/`
   - Nom du fichier : `N-N-<description-courte>.md` (ex: `1-3-bottom-nav-bottom-sheets.md`)
   - Modèle : copier la structure de `_bmad-output/implementation-artifacts/1-3-bottom-nav-bottom-sheets.md`
   - Sections obligatoires : Story · ACs · Tasks/Subtasks (avec `[x]`) · Dev Notes · Dev Agent Record · File List · Change Log · Status
   - `Status` = `done` quand tous les ACs sont implémentés

2. **Lancer `flutter test`** — tous les tests passent, y compris les nouveaux tests de la story

3. **Vérifier `flutter analyze --no-pub`** — zéro erreur (warnings autorisés si hors scope story)

4. **Committer l'artifact dans le même commit** que le code (ou commit séparé `docs:` immédiatement après)

5. **Pusher la branche** : `git push -u origin <branche>`

6. **Ouvrir la PR vers `develop`** — toujours `--base develop`, jamais vers `main` :
   ```bash
   gh pr create --base develop --title "[Epic N · Story N.N] <titre>" --body "..."
   ```
   Template body :
   ```
   ## Story
   Epic N · Story N.N — <titre>

   ## ACs implémentés
   - [x] Given ... When ... Then ...

   ## Hors scope
   (décisions de report avec justification)

   ## Notes techniques
   (décisions, compromis, points d'attention)
   ```

7. **Assigner Copilot en reviewer** :
   ```bash
   gh pr edit <numéro> --add-reviewer "Copilot"
   ```

> Ne jamais committer une story sans son implementation artifact.
> Ne jamais laisser une branche sans PR une fois la story terminée.

## Traitement des reviews Copilot — OBLIGATOIRE

Après chaque review Copilot sur une PR, appliquer le processus suivant **sans attendre** :

### 1. Lire tous les commentaires Copilot

```bash
gh pr view <numéro> --comments
gh api repos/deadelus/urbink/pulls/<numéro>/reviews
gh api repos/deadelus/urbink/pulls/<numéro>/comments
```

### 2. Corriger chaque point soulevé

- Appliquer la correction dans le code
- Un commit par groupe de corrections logiques :
  ```
  fix(epic-N/story-N.N): corrections review Copilot PR#<numéro>
  ```

### 3. Répondre à chaque commentaire Copilot sur GitHub

Pour chaque commentaire inline (sur une ligne de code) :
```bash
gh api repos/deadelus/urbink/pulls/comments/<comment_id>/replies \
  -f body="✅ Corrigé : <explication courte de ce qui a été fait>"
```

Pour les commentaires généraux (review-level) :
```bash
gh pr comment <numéro> --body "## Corrections review Copilot\n- ✅ <point 1> : <ce qui a été fait>\n- ✅ <point 2> : <ce qui a été fait>"
```

### 4. Pusher les corrections

```bash
git push origin <branche>
```

> **Règle :** Ne jamais laisser un commentaire Copilot sans réponse. Chaque correction doit être tracée avec une réponse explicite sur GitHub.

## Conventions Git — OBLIGATOIRES

### Branches

Format : `epic-<N>/story-<N.N>-<description-courte>`

```
epic-1/story-1.1-flutter-setup
epic-2/story-2.2-gps-tracking
epic-4/story-4.2-badge-quartier
```

Branches spéciales :
```
main          ← production — merge uniquement via PR après review
develop       ← intégration continue — base de toutes les branches story
hotfix/<desc> ← correctif urgent en prod (branché depuis main)
```

Règles :
- **Ne jamais committer directement sur `main` ou `develop`**
- Chaque story = une branche dédiée
- Une branche = une story (pas de regroupement d'epics)
- Brancher depuis `develop`, merger dans `develop` via PR

### Commits

Format Conventional Commits avec référence story :

```
<type>(epic-N/story-N.N): <description courte en français>
```

Types autorisés :
| Type | Usage |
|------|-------|
| `feat` | Nouvelle fonctionnalité (story implémentée) |
| `fix` | Correctif bug |
| `test` | Ajout ou modification de tests |
| `refactor` | Refactoring sans changement de comportement |
| `chore` | Config, CI, dépendances, tooling |
| `docs` | Documentation, ADR |
| `style` | Formatage, lint (pas de logique) |

Exemples :
```
feat(epic-2/story-2.2): tracking GPS temps réel avec snap to road Nominatim
feat(epic-4/story-4.2): détection complétion quartier + trigger badge Firestore
fix(epic-2/story-2.3): correction opacité polyline MapStreetOverlay sur iOS 16
test(epic-7/story-7.1): tests unitaires Firebase Anonymous Auth
chore(epic-1/story-1.6): configuration GitHub Actions + Fastlane
docs: ADR-002 choix sqflite pour cache local sessions GPS
```

Règles :
- Un commit = une intention (pas de "fix stuff" avec 10 fichiers différents)
- Le premier commit d'une branche inclut toujours la référence story
- Les commits intermédiaires peuvent être squashés avant merge PR
- **Jamais de `git push --force` sur `develop` ou `main`**

### Pull Requests

Titre : `[Epic N · Story N.N] Description de la story`

```
[Epic 2 · Story 2.2] Tracking GPS temps réel + snap to road Nominatim
[Epic 4 · Story 4.2] Détection complétion quartier + badge + secret local
```

Body PR (template) :
```markdown
## Story
Epic N · Story N.N — <titre de la story>

## ACs implémentés
- [ ] Given ... When ... Then ...
- [ ] Given ... When ... Then ...

## Notes techniques
(décisions, compromis, points d'attention)
```

### Epics → Branches de référence

| Epic | Domaine | Préfixe branche |
|------|---------|-----------------|
| Epic 1 | Fondation & Infrastructure | `epic-1/story-1.x-...` |
| Epic 2 | Carte & Exploration GPS | `epic-2/story-2.x-...` |
| Epic 3 | Historique & Filtrage | `epic-3/story-3.x-...` |
| Epic 4 | Gamification & Progression | `epic-4/story-4.x-...` |
| Epic 5 | Parcours | `epic-5/story-5.x-...` |
| Epic 6 | Points d'Intérêt | `epic-6/story-6.x-...` |
| Epic 7 | Compte & Auth | `epic-7/story-7.x-...` |
| Epic 8 | Communauté & Pins | `epic-8/story-8.x-...` |
| Epic 9 | Partage & Social | `epic-9/story-9.x-...` |
| Epic 10 | Notifications | `epic-10/story-10.x-...` |

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
