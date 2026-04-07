---
status: Accepté
date: 2026-04
---

# 005 — Firebase comme backend complet

## Contexte

Choisir l'infrastructure backend pour Urbink (auth, base de données, stockage, push).

## Décision

Firebase (Auth + Firestore + Storage + FCM) avec 3 projets distincts : `urbink-dev`, `urbink-staging`, `urbink-prod`.

## Conséquences

**Positif :**
- Intégration Flutter native (FlutterFire)
- Firestore offre des streams temps réel — idéal pour le feed social et les mises à jour de progression
- Anonymous Auth permet un onboarding sans friction (linkWithCredential pour la conversion)
- FCM pour les push notifications sans serveur dédié
- 3 environnements isolés — pas de risque de contamination dev/prod

**Négatif :**
- Vendor lock-in Firebase/Google
- Coût Firestore à l'échelle (reads/writes)
- Règles de sécurité Firestore à maintenir rigoureusement

## Règle absolue

Jamais d'appel Firestore direct dans un widget — toujours via un provider Riverpod.
