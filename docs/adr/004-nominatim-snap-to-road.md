---
status: Accepté
date: 2026-04
---

# 004 — Nominatim pour le snap to road

## Contexte

Le GPS brut donne des coordonnées imprécises. Pour colorier les bonnes rues, il faut identifier quelle rue l'utilisateur emprunte réellement.

## Décision

Nominatim (OpenStreetMap) via `NominatimClient` dans `shared/utils/nominatim_client.dart`.

## Conséquences

**Positif :**
- Gratuit, cohérent avec OSM (même source de données que les tuiles)
- Reverse geocoding précis au niveau de la rue

**Négatif :**
- Online uniquement — pas de snap to road en mode hors-ligne
- Latence ~200ms par appel
- Rate limit : 1 req/s — la queue interne du client gère ça

## Gestion d'erreur

Retry x3 avec backoff exponentiel, fallback silencieux (on garde la coordonnée GPS brute).
