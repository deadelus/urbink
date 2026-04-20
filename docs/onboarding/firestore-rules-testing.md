# Test des règles Firestore

Valide les Security Rules de `firestore.rules` via les émulateurs Firebase locaux.

---

## Prérequis

```bash
npm install -g firebase-tools
```

Vérifier l'installation :
```bash
firebase --version
```

---

## Lancer les tests

```bash
cd ~/code/urbink
./scripts/test_firestore_rules.sh
```

Le script démarre automatiquement les émulateurs s'ils ne sont pas actifs, exécute les 3 suites de tests, puis arrête les émulateurs.

---

## Ce qui est testé

### Suite 1 — Accès autorisé (AC1)

Vérifie qu'un utilisateur authentifié peut lire et écrire **ses propres** données.

| Opération | Collection | Résultat attendu |
|---|---|---|
| GET | `users/{uid}/sessions` | 200 |
| GET | `users/{uid}/streets` | 200 |
| WRITE | `users/{uid}/sessions/{id}` | 200 |
| WRITE | `users/{uid}/streets/{id}` | 200 |

### Suite 2 — Accès refusé — UID différent (AC2)

Vérifie qu'un utilisateur **ne peut pas accéder aux données d'un autre**.

| Opération | Collection | Résultat attendu |
|---|---|---|
| GET | `users/{autre-uid}/sessions` | 403 |
| GET | `users/{autre-uid}/streets` | 403 |
| WRITE | `users/{autre-uid}/sessions/{id}` | 403 |

### Suite 3 — Accès refusé — non authentifié (AC2)

Vérifie qu'un appel sans token est rejeté.

| Opération | Collection | Résultat attendu |
|---|---|---|
| GET | `users/{uid}/sessions` | 403 |
| GET | `users/{uid}/streets` | 403 |
| WRITE | `users/{uid}/sessions/{id}` | 403 |

---

## Résultat attendu

```
🔥 Urbink — Test des règles Firestore

▶ Démarrage des émulateurs Firebase
✔ Émulateurs prêts (3s)

── Setup — création de 2 utilisateurs anonymes ──
▶ Utilisateur 1 : abc123...
▶ Utilisateur 2 : xyz456...

── Suite 1 — Accès autorisé (AC1) ──
✅ PASS — GET sessions — propriétaire (HTTP 200)
✅ PASS — GET streets — propriétaire (HTTP 200)
✅ PASS — WRITE session — propriétaire (HTTP 200)
✅ PASS — WRITE street — propriétaire (HTTP 200)

── Suite 2 — Accès refusé UID différent (AC2) ──
✅ PASS — GET sessions — autre utilisateur (HTTP 403)
✅ PASS — GET streets — autre utilisateur (HTTP 403)
✅ PASS — WRITE session — autre utilisateur (HTTP 403)

── Suite 3 — Accès refusé non authentifié (AC2) ──
✅ PASS — GET sessions — non authentifié (HTTP 403)
✅ PASS — GET streets — non authentifié (HTTP 403)
✅ PASS — WRITE session — non authentifié (HTTP 403)

── Résumé ──
Tests : 10 | 10 passés | 0 échoués
✅ Toutes les règles Firestore sont correctes.
```

---

## Déployer les règles en production

```bash
firebase deploy --only firestore
```

Déploie à la fois `firestore.rules` et `firestore.indexes.json`.

---

## Fichiers concernés

| Fichier | Rôle |
|---|---|
| `firestore.rules` | Règles de sécurité Firestore |
| `firestore.indexes.json` | Index composites Firestore |
| `firebase.json` | Configuration projet Firebase |
| `scripts/test_firestore_rules.sh` | Script de test local |
