---
status: Accepté
date: 2026-04
---

# 001 — Flutter, MVP iOS uniquement

## Contexte

Choisir le framework mobile et le scope de plateforme pour le MVP d'Urbink.

## Décision

Flutter pour le développement mobile, ciblant iOS 16+ uniquement pour le MVP.

## Conséquences

**Positif :**
- Un seul codebase Dart pour une future extension Android
- Hot reload rapide, widgets riches
- iOS 16+ permet d'utiliser les APIs modernes (SwiftUI interop, Background Tasks)
- Réduction du scope MVP = livraison plus rapide

**Négatif :**
- Pas d'utilisateurs Android avant v2
- Certains packages Flutter ont une meilleure qualité sur Android
