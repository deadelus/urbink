---
status: Accepté
date: 2026-04
---

# 003 — flutter_map + OpenStreetMap

## Contexte

Choisir la solution de cartographie pour afficher les rues et les tracés GPS.

## Décision

`flutter_map` avec les tuiles OpenStreetMap (tile.openstreetmap.org).

## Conséquences

**Positif :**
- Gratuit, pas de clé API, pas de quota
- OSM a une couverture mondiale excellente pour les rues
- `flutter_map` permet des couches custom (polylines, polygons) — nécessaire pour colorier les rues
- Open source, pas de dépendance commerciale (Google Maps SDK)

**Négatif :**
- Qualité des tuiles inférieure à Google Maps visuellement
- Pas de vue satellite
- Rate limit OSM : max 2 req/s tile server — à surveiller en prod

## Note

Les tuiles peuvent être mises en cache localement pour le mode hors-ligne partiel.
