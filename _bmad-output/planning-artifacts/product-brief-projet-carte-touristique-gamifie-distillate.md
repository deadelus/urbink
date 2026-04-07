---
title: "Product Brief Distillate: Urbink"
type: llm-distillate
source: "product-brief-projet-carte-touristique-gamifie.md"
created: "2026-04-06"
purpose: "Token-efficient context for downstream PRD creation"
---

# Urbink — Detail Pack PRD

## Identité Produit

- **Nom :** Urbink (Urb + Ink)
- **Tagline :** *"Every detour hides a discovery."*
- **Communauté :** Les Urbinkers
- **Concept core :** Les rues se colorient progressivement au fur et à mesure qu'on les parcourt. La carte est toujours visible en entier — pas de fog of war. C'est un surligneur personnel sur la ville.
- **Plateforme MVP :** iOS uniquement
- **Modèle :** Gratuit, sans pub

---

## Problème & Insight

- Les touristes repassent toujours aux mêmes endroits sans s'en rendre compte (cas vécu : Venise, Pont du Rialto)
- Google Maps sait où tu vas, pas où tu es déjà allé
- Le problème touche autant les touristes que les habitants (un Parisien ne connaît pas son 19ème)
- Moment "aha" : la première fois qu'un utilisateur voit une rue non colorée et choisit un autre chemin — c'est là que le comportement change

---

## MVP — Features Confirmées (iOS)

1. **Carte colorée progressive** — rues se colorient via GPS en temps réel. Multi-modal : pied, vélo, voiture. La carte reste toujours visible.
2. **Territoires/quartiers à compléter** — ville découpée en zones comme un puzzle. Compléter un quartier = badge + "secret local" débloqué.
3. **Parcours automatique** — bouton unique qui génère un circuit de X minutes couvrant le max de rues non explorées + 2-3 points d'intérêt.
4. **Badges monuments** — monuments emblématiques débloqués automatiquement par proximité GPS. 50 villes au lancement.
5. **Objectifs thématiques** — collections par catégorie (toutes les églises, tous les parcs...) variant selon la ville. Faisables à pied/vélo/voiture.
6. **Parcours personnalisé** — l'utilisateur trace son propre itinéraire sur la carte, le suit en temps réel, les rues se colorient.
7. **Pins communautaires** — épingles humaines non-officielles (une porte sculptée, une impasse, un point de vue caché). Contenu généré par ceux qui ont vraiment marché là.

---

## Hors MVP — V2/V3

- **Carte-souvenir exportable** — carte colorée + photos épinglées, exportable/partageable. Potentiellement payante (première monétisation). Fort potentiel viral (partage Instagram).
- **Android** — après validation iOS
- **Matching d'explorateurs** — trouver un compagnon de marche (profil : rythme, intérêts, durée). Type Tinder de l'exploration.
- **Carte fusionnée de groupe** — les explorations individuelles fusionnent sur une carte commune.
- **Audio guide contextuel** — 90 secondes auto-déclenché à l'arrêt devant un monument.
- **Heatmap d'affluence** — zones rouges/vertes comme Waze (données télécom ou partenaires).
- **Intégrations** — Strava, Get Your Guide (envisagées mais pas prioritaires).
- **Streak quotidienne** — flamme quotidienne. Secondaire pour les touristes, pertinente pour les locaux.
- **Leaderboard** — classement explorateurs par ville.
- **Marketplace expériences locales** — habitants vendent des circuits commentés.

---

## Contraintes Techniques Clés

- **Solo founder, budget zéro** — pas d'équipe, pas de budget dev externe
- **Coûts incompressibles :** App Store 99$/an + Google Play 25$ one-shot
- **Données cartographiques :** OpenStreetMap recommandé (gratuit, mondial, open source)
- **Défi technique majeur :** Matching GPS sur réseau routier OSM pour colorier les bonnes rues (sous-estimé initialement) — nécessite map matching library (ex: Valhalla, OSRM)
- **React Native ou Flutter** recommandé pour iOS first avec portabilité Android future
- **Géolocalisation :** GPS natif iOS suffisant pour le tracking de position

---

## Direction Esthétique

- **Référence :** Carte "Nouveau Paris Monumental" 1900 — monuments représentés comme des icônes illustratives grandes et reconnaissables
- **Style visuel :** Entre carte vintage illustrée et modernité fonctionnelle. Chaleureux, humain, pas froid comme Google Maps.
- **Monuments :** Icônes reconnaissables et stylisées (pas des marqueurs génériques), filtrables, activables/désactivables
- **Coloration rues :** Surligneur progressif — une couleur douce sur les rues parcourues, contraste clair avec les rues vierges

---

## Acquisition & Go-to-Market

- **Canal principal :** Instagram/TikTok — campagnes ciblées habitants grandes villes (pas touristes)
- **Viral loop :** Partage de sa carte colorée sur les réseaux = acquisition organique
- **Cible prioritaire au lancement :** Locaux curieux (rétention quotidienne) > touristes (usage rare)
- **Ville de lancement :** Paris recommandée — données OSM riches, marché local accessible pour beta

---

## Monétisation (Roadmap)

- **V1 :** Gratuit, zéro pub
- **V2 :** Carte-souvenir exportable payante (option légère)
- **V3 :** Partenariats institutionnels — offices de tourisme, collectivités, régions
- **Refus explicite :** Pas de vente de données, pas de pub intrusive, app reste gratuite pour les utilisateurs

---

## Concurrents — Raisons d'Élimination

- **Fog of World** — cache la carte (fog of war), pas de gamification sociale, payant
- **Wandrer** — niche cyclistes/coureurs, zéro touristique, aucune suggestion
- **Polarsteps** — archive après coup, pas d'exploration temps réel
- **Visited** — granularité pays/régions uniquement, pas de rue
- **CityStrides** — même concept de rue mais orienté running, pas exploration

---

## Noms Rejetés (ne pas re-proposer)

| Nom | Raison |
|---|---|
| Wander | Startup $148M + 5 apps existantes |
| Detour | Bose (ex-app audio guide) |
| Trace | App sports GPS financée |
| Mapstr | Startup française 3M users |
| ReMap | Trop générique, saturé tech |
| Strata | Trop proche Strava phonétiquement |
| Uncharted | Marque Sony PlayStation |
| Polo | Ralph Lauren Class 9 + Marco Polo app |
| Medina | Apps travel/GPS existantes + sensibilité religieuse |
| Plink | App musicale + plateforme loyalty |
| Flink | App épicerie européenne $750M |
| BetterPlan | Saturé, trop corporate |
| Nook | Barnes & Noble trademark |
| Flâneur | Trop français, non-anglophone |

---

## Questions Ouvertes pour le PRD

- Quelle librairie de map matching pour la coloration GPS des rues ? (Valhalla vs OSRM vs Mapbox)
- Comment gérer le cold start des pins communautaires ? (contenu pré-rempli au lancement ?)
- Quel seuil de vitesse pour distinguer marche/vélo/voiture et adapter la coloration ?
- Comment définir les "secrets locaux" à débloquer par quartier ? (contenu éditorial ou communautaire ?)
- Quelle API pour les données de monuments et points d'intérêt ? (OpenStreetMap POI, Wikidata ?)
- Système de compte utilisateur obligatoire ou optionnel au MVP ?
