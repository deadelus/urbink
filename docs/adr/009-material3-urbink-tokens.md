---
status: Accepté
date: 2026-04
---

# 009 — Material 3 avec tokens Urbink

## Contexte

Choisir le design system de base et définir l'identité visuelle d'Urbink.

## Décision

Material 3 comme fondation, avec override complet des tokens de couleur et typographie pour l'identité Urbink.

## Tokens principaux

| Token | Valeur | Usage |
|-------|--------|-------|
| Ocre Chaud | `#B8832E` | Primary, boutons, accents |
| Vert Sauge | `#5A7A5A` | Rues explorées |
| Brun Profond | `#1E1610` | Texte principal |
| Fond chaud | `#FAFAF7` | Background |

## Typographie

- **Crimson Pro** — display, headings (caractère culturel/parisien)
- **Inter** — body, UI labels (lisibilité)

## Grille

Base 8px : `space-sm=8`, `space-md=16`, `space-lg=24`, `space-xl=32`

## Conséquences

**Positif :**
- M3 gère l'accessibilité de base (contrastes, tailles min)
- Override via `ThemeData` — pas de composants custom inutiles
- Cohérence garantie sur toute l'app

**Négatif :**
- Certains composants M3 difficiles à styler (BottomNavigationBar → NavigationBar)
