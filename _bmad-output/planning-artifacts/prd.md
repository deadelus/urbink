---
stepsCompleted: ['step-01-init', 'step-02-discovery', 'step-02b-vision', 'step-02c-executive-summary', 'step-03-success', 'step-04-journeys', 'step-05-domain', 'step-06-innovation', 'step-07-project-type', 'step-08-scoping', 'step-09-functional', 'step-10-nonfunctional', 'step-11-polish']
inputDocuments:
  - '_bmad-output/planning-artifacts/product-brief-projet-carte-touristique-gamifie.md'
  - '_bmad-output/planning-artifacts/product-brief-projet-carte-touristique-gamifie-distillate.md'
  - '_bmad-output/brainstorming/brainstorming-session-2026-04-04-1400.md'
workflowType: 'prd'
---

# Product Requirements Document — Urbink

**Auteur :** Jo
**Date :** 2026-04-06

---

## Résumé Exécutif

Urbink est une application mobile iOS qui transforme la carte de n'importe quelle ville en empreinte personnelle d'exploration. Les rues se colorient progressivement via GPS au fil des déplacements — à pied, à vélo ou en voiture. La carte reste toujours entièrement visible : pas de fog of war, juste un surligneur personnel qui révèle ce que l'utilisateur a déjà parcouru. Chaque session d'exploration est sauvegardée individuellement. La carte affiche l'agrégation de toutes les sessions — les rues colorées représentent l'union de tous les parcours effectués. L'utilisateur peut filtrer l'agrégation par période (aujourd'hui / semaine / mois / tout l'historique) pour visualiser sa progression sans noyer l'historique.

Cible : tout curieux urbain de 25 à 55 ans — touriste de passage ou habitant de longue date — qui se retrouve à repasser dans les mêmes rues sans s'en rendre compte. Gratuit, sans publicité, sans modèle freemium.

### Ce qui rend Urbink unique

Google Maps sait où tu vas. Urbink sait où tu es déjà allé. Ce vide — entre navigation et exploration — est le positionnement qu'aucun acteur majeur n'occupe.

L'avantage défendable : carte toujours visible + moteur d'agrégation de sessions + gamification légère (badges, quartiers à compléter, objectifs thématiques) + pins communautaires humains (contenu généré par ceux qui ont vraiment marché là). Aucun concurrent ne combine ces quatre dimensions.

Le moment "aha" : la première fois qu'un utilisateur regarde sa carte et dit *"je ne suis pas passé par là"* — et choisit un autre chemin. C'est là que le comportement change.

**Tagline :** *"Every detour hides a discovery."*

## Classification du Projet

- **Type :** Application Mobile (iOS — MVP, Android V2)
- **Domaine :** Exploration urbaine & Tourisme
- **Complexité :** Moyenne (map matching GPS sur réseau OSM techniquement exigeant, fonctionnalités communautaires, pas de contraintes réglementaires lourdes)
- **Contexte :** Greenfield — nouveau projet from scratch
- **Fondateur :** Solo, budget zéro, coûts incompressibles App Store uniquement

## Direction Esthétique

Référence visuelle : carte *"Nouveau Paris Monumental"* (1900) — monuments représentés comme des icônes illustratives grandes et reconnaissables, chaleureux et distinctifs.

**Principes :**
- Style entre carte vintage illustrée et modernité fonctionnelle — chaleureux, humain, pas froid comme Google Maps
- Monuments : icônes stylisées reconnaissables (pas des marqueurs génériques), filtrables, activables/désactivables
- Coloration des rues : surligneur progressif — couleur douce sur les rues parcourues, contraste clair avec les rues vierges
- Tons chauds, typographie lisible, densité visuelle maîtrisée pour ne pas surcharger la carte

Cette direction s'applique à toutes les décisions de design UI/UX en aval.

## Critères de Succès

### Succès Utilisateur

- L'utilisateur ouvre l'app et voit sa progression colorée en moins de 3 secondes
- L'utilisateur complète son premier quartier dans les 7 premiers jours
- L'utilisateur revient sur l'app après une première session d'exploration
- Moment "aha" déclenché : l'utilisateur choisit un chemin non exploré en regardant sa carte

### Succès Business

- **Téléchargements :** 10 000 téléchargements à 6 mois post-lancement (Paris uniquement)
- **Rétention :** Streak moyenne > 4 jours
- **Engagement :** Temps moyen par session > 15 minutes en mode exploration active
- **Activation :** 30% des utilisateurs complètent au moins un quartier entier
- **Communauté :** 1 000 pins communautaires créés
- **Conversion :** 20% des utilisateurs en mode invité créent un compte

### Succès Technique

- Précision GPS équivalente à Google Maps — rue correctement identifiée et colorée dans la grande majorité des cas
- Sync locale → cloud sans perte de données
- Détection automatique du mode de déplacement (marche / vélo / voiture) sans intervention utilisateur
- Temps de chargement carte < 2 secondes au lancement

### Indicateurs Mesurables

- Nombre de parcours automatiques générés et complétés
- Nombre d'objectifs thématiques complétés par utilisateur
- Taux d'ouverture quotidienne (DAU/MAU)
- Nombre de rues colorées par session

## User Journeys

### Journey 1 — Le Touriste : Premier pas dans une ville inconnue

**Personnage :** Sofia, 32 ans, architecte italienne. Elle arrive à Paris pour 4 jours. Elle a déjà visité Paris il y a 5 ans et a l'impression de n'avoir vu que les mêmes spots. Cette fois, elle veut autre chose.

**Scène d'ouverture :** Sofia descend du Eurostar à la Gare du Nord. Elle cherche sur l'App Store une app pour explorer Paris autrement. Elle télécharge Urbink, lance l'app en mode invité — pas envie de créer un compte tout de suite.

**Action montante :** Elle voit Paris s'afficher sur la carte — toutes les rues visibles, aucune colorée. Elle marche vers son hôtel dans le Marais. Les rues se colorient derrière elle en temps réel. Elle s'arrête, regarde sa carte : un fil coloré trace exactement son chemin depuis la gare. Elle sourit.

Le lendemain, elle ouvre l'app au réveil. Elle voit que le layer "aujourd'hui" est vierge — nouvelle journée, nouvelle exploration. Elle tape "Parcours automatique" — 45 minutes. L'app génère un circuit qui couvre le maximum de rues non explorées dans le Marais, avec 3 points d'intérêt sur le chemin.

**Climax :** Au bout du 3ème jour, Sofia regarde sa carte en vue "tout l'historique". Une grande partie du Marais est colorée, mais elle voit une zone blanche à deux rues de son hôtel. Elle n'y est jamais passée. Elle change son chemin pour aller dîner — et découvre une cour intérieure avec une fontaine du XVIIème que personne ne lui avait jamais mentionnée.

**Résolution :** Sofia crée un compte pour sauvegarder sa carte avant de rentrer à Milan. Elle épingle la cour avec un pin communautaire : *"Cour de la fontaine cachée — entrée au 14 rue de Bretagne."* Elle repart avec une carte colorée unique — son Paris à elle.

**Capabilities révélées :** onboarding sans friction, mode invité, parcours automatique, filtrage temporel, coloration GPS temps réel, création de compte post-usage, pins communautaires.

---

### Journey 2 — Le Local : Le Parisien qui ne connaît pas Paris

**Personnage :** Marcus, 41 ans, développeur web à Paris depuis 12 ans. Il habite le 11ème, travaille dans le 2ème, connaît 5 arrondissements sur 20. Il a téléchargé Urbink après avoir vu une carte colorée partagée sur Instagram.

**Scène d'ouverture :** Marcus crée un compte dès l'installation — il veut que sa progression soit sauvegardée. Il voit sa carte de Paris : entièrement blanche. Légèrement honteux. *"12 ans ici et j'ai jamais mis les pieds dans le 19ème."*

**Action montante :** Marcus utilise l'app chaque matin pour aller au bureau en changeant de chemin. Le filtre "aujourd'hui" lui montre sa route quotidienne. Au bout d'une semaine, le filtre "semaine" révèle un réseau de rues colorées dans le 11ème. Il active l'objectif thématique *"Tous les squares et jardins de Paris"* — il en a fait 3 sur 47.

**Climax :** Un samedi, Marcus décide de compléter le quartier Belleville. Il lui manque 8 rues. Il crée un parcours personnalisé pour les couvrir toutes. Quand la dernière rue se colorie, l'app affiche : *"Quartier Belleville complété — secret local débloqué."* Le secret : une fresque murale cachée dans une impasse que seuls les habitués connaissent.

**Résolution :** Marcus partage sa carte en vue "tout l'historique" sur Instagram. 3 amis téléchargent l'app la semaine suivante. Il est devenu, sans le vouloir, un ambassadeur d'Urbink.

**Capabilities révélées :** compte optionnel, filtrage temporel, objectifs thématiques, parcours personnalisé, complétion de quartier, secrets locaux, partage social.

---

### Journey 3 — Le Contributeur Communautaire : Celui qui laisse une trace

**Personnage :** Aminata, 28 ans, photographe de street art à Paris. Elle connaît des dizaines de spots invisibles sur Google Maps. Elle utilise Urbink depuis 3 semaines et a déjà colorié une grande partie de son 13ème.

**Scène d'ouverture :** Aminata s'arrête devant une porte sculptée dans une ruelle du 13ème. Elle se dit que personne ne sait que ça existe. Elle ouvre Urbink, appuie longuement sur la carte à l'emplacement exact.

**Action montante :** Le formulaire de pin s'ouvre — photo, description courte, catégorie. Elle écrit : *"Porte Art Déco oubliée — 1924, sculpteur inconnu. Cherchez les visages dans les médaillons."* Elle ajoute une photo. Le pin est soumis à la modération IA.

**Climax :** 2 heures plus tard, le pin est validé et apparaît sur la carte publique. Le lendemain, quelqu'un d'autre passe devant la porte, voit le pin d'Aminata, et lui laisse un ❤️. Ce geste de reconnaissance la pousse à créer 5 nouveaux pins dans la semaine.

**Résolution :** Aminata devient l'une des contributrices les plus actives de Paris sur Urbink. Ses pins sont les mieux notés du 13ème.

**Capabilities révélées :** création de pin (photo + texte + position GPS), modération IA, validation/publication, système de réaction.

---

### Journey 4 — L'Admin (Fondateur) : Lancer Paris from Scratch

**Personnage :** Jo, fondateur solo d'Urbink. J-7 avant le lancement sur l'App Store. La carte de Paris est prête, les quartiers sont définis, mais les pins communautaires sont vides et les secrets locaux n'existent pas encore.

**Scène d'ouverture :** Jo ouvre le back-office d'Urbink. Il lance le pipeline de cold start : scraping de Paris Secret, des blogs de street art, des données Wikidata pour les monuments de Paris. L'IA structure les résultats en pins formatés et en secrets locaux par quartier.

**Action montante :** Jo passe en revue les pins générés — certains sont parfaits, d'autres trop génériques ou mal géolocalisés. Il supprime les pins faibles, ajuste les descriptions, valide les 200 meilleurs. Les secrets locaux par quartier sont relus et affinés.

**Climax :** Un pin signalé par un utilisateur arrive dans la file de modération. L'IA l'a automatiquement masqué. Jo confirme la suppression en un clic.

**Résolution :** Au lancement, Paris a 200 pins pré-remplis et 20 arrondissements avec leurs secrets locaux. Les premiers utilisateurs trouvent du contenu dès le premier jour.

**Capabilities révélées :** back-office admin, pipeline cold start IA, modération manuelle, gestion des signalements, curation de contenu.

---

### Tableau de Couverture des Capabilities

| Capability | Journeys |
|---|---|
| Onboarding sans friction / mode invité | J1 |
| Coloration GPS temps réel + map matching | J1, J2, J3 |
| Filtrage temporel des sessions | J1, J2 |
| Parcours automatique | J1 |
| Parcours personnalisé | J2 |
| Objectifs thématiques | J2 |
| Complétion de quartier + secrets locaux | J2 |
| Badges monuments | J1, J2 |
| Pins communautaires + modération IA | J1, J3, J4 |
| Compte optionnel + sync cloud | J1, J2 |
| Partage social | J2 |
| Back-office admin + cold start pipeline | J4 |

## Exigences Domaine

### Conformité & Réglementaire

- **RGPD** — Données de géolocalisation en temps réel = données personnelles sensibles. Consentement explicite au premier lancement. Politique de confidentialité obligatoire. Durée de rétention à définir (recommandé : suppression automatique après inactivité prolongée).
- **Licence OpenStreetMap (ODbL)** — Mention obligatoire d'OpenStreetMap comme source dans l'app et les mentions légales.

### Contraintes Techniques

- **Géolocalisation en arrière-plan (iOS)** — Justification explicite requise par Apple. Usage déclaré : *"tracking de l'exploration en temps réel"*. Permission `Always` ou `When In Use` selon comportement cible.
- **App Store Guidelines** — App Privacy Labels (données de localisation, identifiants), Sign in with Apple obligatoire si login social proposé, politique de modération UGC documentée.

### Gestion des Contenus Communautaires

- Modération IA obligatoire avant publication de tout pin (texte + image)
- Signalement accessible à tous les utilisateurs
- Suppression admin sans préavis en cas de violation
- Pas de contenu permettant l'identification de personnes (photos de visages interdites)

### Risques et Mitigations

| Risque | Mitigation |
|---|---|
| Fuite de données de localisation | Chiffrement HTTPS/TLS en transit et au repos, zéro revente |
| Contenu inapproprié sur les pins | Modération IA + signalement humain + suppression admin |
| Refus App Store (background GPS) | Justification claire, usage limité à l'exploration active |
| Violation licence OSM | Mention dans les crédits et les mentions légales |

## Innovation & Différenciation

### Innovations Clés

**1. Moteur d'agrégation de sessions d'exploration**
Chaque sortie est enregistrée comme une session distincte (modèle Strava). La carte est le résultat visuel de l'agrégation. L'utilisateur filtre par période (aujourd'hui / semaine / mois / tout l'historique). Architecture inédite dans le domaine de l'exploration urbaine.

**2. Positionnement exploration vs navigation**
Tous les acteurs majeurs optimisent l'efficacité (chemin le plus court). Urbink optimise l'inverse : couvrir le maximum de territoire inexploré. Renversement de paradigme, pas amélioration incrémentale.

**3. Contenu communautaire humain**
Les pins sont créés par des gens qui ont physiquement marché là — mémoire collective de l'exploration réelle. Aucun concurrent ne fait ça à l'échelle de la rue.

**4. Cold start par IA sémantique**
Pipeline d'agrégation de sources spécialisées (Paris Secret, blogs street art, Wikidata) → pins géolocalisés cohérents. Approche originale pour amorcer une communauté sans masse critique initiale.

### Contexte Concurrentiel

| Concurrent | Limite |
|---|---|
| Fog of World | Cache la carte (philosophie opposée), pas d'évolution récente |
| CityStrides | Orienté running uniquement, zéro dimension touristique |
| Wandrer | Cyclistes uniquement, aucune suggestion |
| Google Maps | Navigation seulement, ne trace pas où l'on est déjà allé |

Le positionnement "exploration urbaine grand public" est **non occupé** par les acteurs majeurs.

### Signaux de Validation

- Taux de complétion des quartiers (changement de comportement mesuré)
- Retour d'utilisateurs dans une ville déjà visitée pour compléter leur carte
- 1 000 pins créés organiquement dans les 6 premiers mois

## Exigences Mobile App

### Plateforme & Framework

- **MVP :** iOS uniquement (App Store), iOS 16+
- **V2 :** Android (Google Play)
- **Framework :** React Native ou Flutter — décision à prendre en phase technique (critère : maturité des libs de map matching et de rendu cartographique)
- **Mode offline :** Non requis — connexion internet obligatoire

### Permissions Appareil

| Permission | Usage | Déclenchement |
|---|---|---|
| Localisation "Always" | Tracking GPS en arrière-plan | Premier lancement en mode exploration |
| Caméra | Photo pour les pins | Création d'un premier pin |
| Notifications | Badges, quartiers, pins | Après le premier moment "aha" |

### Stratégie Push Notifications

Activées par défaut au MVP, désactivables dans les paramètres :

- *"Tu viens de débloquer le badge Tour Eiffel !"* — déblocage badge
- *"Plus que 3 rues pour compléter Belleville !"* — quartier presque complet
- *"Quelqu'un a aimé ton pin dans le Marais"* — réaction pin
- *"Tu n'as pas exploré depuis 3 jours — la ville t'attend"* — rappel (max 1 fois / 3 jours)

### Conformité App Store

- Sign in with Apple obligatoire (règle Apple si login social tiers proposé)
- App Privacy Labels à compléter (localisation, identifiants)
- Background Location — justification : *"Urbink trace ton exploration en temps réel pour colorier les rues que tu parcours"*
- Politique de modération UGC documentée requise par Apple

### Considérations d'Implémentation

- Map matching GPS sur réseau OSM — bibliothèque à valider (Valhalla, OSRM, ou Mapbox Map Matching API)
- Détection mode de déplacement via Core Motion + vitesse GPS
- Stockage local-first (SQLite ou Realm) + sync NoSQL cloud (Firebase Firestore ou équivalent)
- Rendu cartographique : MapLibre GL (open source, compatible OSM) ou Mapbox SDK

## Périmètre & Roadmap

### MVP — Phase 1 (Paris, iOS)

**Approche :** MVP d'expérience — déclencher le moment "aha" chez les early adopters parisiens. Zéro monétisation, zéro social, une seule ville. Validation du comportement d'exploration avant tout.

**Ressources :** Solo fondateur, budget zéro. Stack open source prioritaire (OSM, MapLibre, React Native/Flutter).

**Fonctionnalités :**
- Coloration GPS temps réel via map matching OSM
- Moteur d'agrégation de sessions + filtrage temporel (aujourd'hui / semaine / mois / tout)
- Détection automatique du mode de déplacement
- Système de quartiers à compléter + secrets locaux
- Parcours automatique (générateur 1-tap)
- Parcours personnalisé (traçage manuel)
- Badges monuments (Paris)
- Description monument à la demande — texte + audio TTS (Wikidata/Wikipedia, AVSpeechSynthesizer). Déclenchement manuel : bouton "à proximité" → liste POI → choix lecture ou écoute
- Objectifs thématiques (Paris)
- Pins communautaires + modération IA
- Mode invité + compte optionnel (Sign in with Apple / Google / Facebook)
- Stockage local-first + sync NoSQL cloud
- Push notifications (badges, quartiers, pins, rappels)
- Partage carte colorée sur réseaux sociaux
- Partage d'itinéraire par lien
- Back-office admin + pipeline cold start IA
- Cold start Paris : 200 pins pré-remplis + secrets locaux 20 arrondissements

### Phase 2 — Croissance

- Extension à d'autres villes (50 villes mondiales)
- Android (Google Play)
- Carte-souvenir exportable (première monétisation)
- **Intégration Strava** — import activités GPS → rues colorées. À approfondir : conditions API, rate limits, modèle commercial.
- **Matching d'explorateurs** — compagnon de balade disponible à proximité, matching par affinité (rythme, intérêts, durée). Nécessite masse critique utilisateurs.
- **Intégration Get Your Guide** — guides locaux et expériences réservables à proximité
- Streak quotidienne & leaderboard

### Phase 3 — Expansion

- Carte fusionnée de groupe
- Marketplace d'expériences locales
- Partenariats institutionnels (offices de tourisme, collectivités)
- La carte colorée devient le journal de vie cartographique de chaque utilisateur

### Stratégie de Mitigation des Risques

| Risque | Type | Mitigation |
|---|---|---|
| Map matching GPS trop imprécis | Technique | Prototype map matching sur Paris avant de coder le reste — risque #1 |
| Scope trop large pour solo founder | Ressources | Séquencer : map matching → gamification → communautaire |
| Cold start vide | Marché | Pipeline IA opérationnel avant lancement, 200 pins J0 minimum |
| Rejet App Store (background GPS) | Compliance | Justification soumise en avance, TestFlight beta |
| Faible rétention post-onboarding | Marché | Ciblage locaux (usage quotidien) > touristes (usage rare) |

## Exigences Fonctionnelles

### Exploration & Coloration GPS

- **FR1 :** L'utilisateur peut démarrer une session d'exploration qui enregistre son tracé GPS en temps réel
- **FR2 :** Le système fait correspondre le tracé GPS aux rues du réseau OSM (map matching) et les colorie
- **FR3 :** L'utilisateur voit ses rues explorées colorées sur la carte en temps réel pendant une session
- **FR4 :** Le système détecte automatiquement le mode de déplacement (marche / vélo / voiture) sans intervention
- **FR5 :** L'utilisateur peut arrêter et reprendre une session d'exploration
- **FR6 :** Chaque session est sauvegardée individuellement avec horodatage et mode de déplacement

### Agrégation & Filtrage Temporel

- **FR7 :** L'utilisateur peut visualiser l'agrégation de toutes ses sessions sur la carte (vue "tout l'historique")
- **FR8 :** L'utilisateur peut filtrer l'affichage des sessions par période : aujourd'hui / cette semaine / ce mois / tout l'historique
- **FR9 :** Le système calcule et affiche le pourcentage de rues explorées par quartier

### Carte & Points d'Intérêt

- **FR10 :** L'utilisateur voit la carte complète de Paris en tout temps (aucune zone masquée)
- **FR11 :** L'utilisateur peut consulter la liste des points d'intérêt à proximité de sa position
- **FR12 :** L'utilisateur peut lire la description textuelle d'un monument ou point d'intérêt
- **FR13 :** L'utilisateur peut écouter la description audio d'un monument (TTS à la demande)
- **FR14 :** L'utilisateur peut activer ou désactiver l'affichage des couches (monuments, pins, quartiers)

### Gamification & Progression

- **FR15 :** L'utilisateur peut voir la progression de complétion de chaque quartier de Paris
- **FR16 :** Le système débloque automatiquement un badge quartier quand toutes les rues sont explorées
- **FR17 :** Le système révèle un "secret local" lors de la complétion d'un quartier
- **FR18 :** Le système débloque automatiquement un badge monument quand l'utilisateur passe à proximité
- **FR19 :** L'utilisateur peut consulter tous ses badges obtenus et leur progression
- **FR20 :** L'utilisateur peut activer un objectif thématique et suivre sa progression

### Parcours

- **FR21 :** L'utilisateur peut générer en un tap un parcours automatique couvrant le maximum de rues non explorées avec une durée cible
- **FR22 :** L'utilisateur peut créer un parcours personnalisé en traçant manuellement un itinéraire sur la carte
- **FR23 :** L'utilisateur peut suivre un parcours en temps réel avec guidage visuel
- **FR24 :** Les rues se colorient au fur et à mesure de la progression sur un parcours

### Communauté & Pins

- **FR25 :** L'utilisateur peut créer un pin communautaire avec une description courte et une photo publique, positionné sur la carte
- **FR26 :** Le système soumet automatiquement chaque pin à la modération IA avant publication (texte + image) — sanction progressive : avertissement → avertissement → suspension 24h → ban
- **FR27 :** L'utilisateur peut voir les pins communautaires sur la carte (clustering par zoom, pins des profils privés visibles uniquement par leurs abonnés)
- **FR28 :** L'utilisateur peut réagir négativement à un pin ("Pas ouf") — 5 réactions négatives rendent le pin privé automatiquement sans suppression ni notification intrusive
- **FR29 :** L'utilisateur peut signaler un pin comme inapproprié (contenu illicite → modération IA + sanction progressive)

### Partage & Social

- **FR30 :** L'utilisateur peut exporter une image de sa carte colorée (watermark Urbink) et la partager sur les réseaux sociaux
- **FR31 :** L'utilisateur peut partager un itinéraire avec un lien (aperçu web pour les non-utilisateurs)
- **FR31b :** L'utilisateur peut suivre d'autres explorateurs (profil public : abonnement immédiat ; profil privé : demande à accepter)
- **FR31c :** L'utilisateur peut configurer son profil en public ou privé (modèle Instagram — profil privé : contenu visible uniquement par abonnés acceptés, pins retirés de la carte publique)
- **FR31d :** L'utilisateur peut publier un parcours terminé dans un fil d'actualité visible par ses abonnés (tracé + durée + rues colorées + badges débloqués pendant ce parcours)

### Compte & Authentification

- **FR32 :** L'utilisateur peut utiliser l'app en mode invité sans compte — un UID anonyme Firebase est créé automatiquement au premier lancement, la progression est sauvegardée dans Firestore dès le départ
- **FR33 :** L'utilisateur peut créer un compte via Sign in with Apple, Google ou Facebook — l'UID anonyme est lié au compte OAuth via `linkWithCredential()` sans perte de données
- **FR34 :** La progression est déjà dans Firestore sous l'UID anonyme — aucune migration nécessaire à la création de compte
- **FR35 :** L'utilisateur peut accéder à sa progression depuis un nouvel appareil après connexion

### Notifications

- **FR36 :** L'utilisateur peut recevoir une notification lors du déblocage d'un badge
- **FR37 :** L'utilisateur peut recevoir une notification de rappel d'exploration (max 1 fois / 3 jours)
- **FR38 :** L'utilisateur peut recevoir une notification quand quelqu'un réagit à son pin
- **FR39 :** L'utilisateur peut gérer ses préférences de notification

### Administration & Back-office

- **FR40 :** L'administrateur peut importer et valider des pins pré-remplis via le pipeline cold start IA
- **FR41 :** L'administrateur peut définir et associer des secrets locaux à chaque quartier
- **FR42 :** L'administrateur peut consulter la file de modération des pins signalés
- **FR43 :** L'administrateur peut supprimer un pin sans préavis
- **FR44 :** L'administrateur peut configurer les monuments et leurs données (description, position, badge associé)

### Conformité & Données

- **FR45 :** L'utilisateur peut consulter et accepter la politique de confidentialité au premier lancement
- **FR46 :** L'utilisateur peut supprimer son compte — anonymisation RGPD : données personnelles supprimées, sessions GPS conservées (IDs de rues uniquement, sans coordonnées brutes), pins anonymisés (userId → null)
- **FR47 :** Le système affiche les crédits OpenStreetMap conformément à la licence ODbL

## Exigences Non-Fonctionnelles

### Performance

- Chargement initial de la carte au lancement : < 2 secondes
- Coloration d'une rue après passage GPS : < 1 seconde (latence perçue)
- Génération d'un parcours automatique : < 3 secondes
- Agrégation et affichage des sessions filtrées : < 2 secondes
- Liste des POI à proximité : < 1 seconde

### Fiabilité

- Aucune perte de données de session GPS — chaque session persistée localement avant sync cloud
- Échec de sync cloud : données locales conservées et re-synchronisées automatiquement à la prochaine connexion
- Disponibilité cible du backend : 99,5% (l'app fonctionne en local-first, le cloud n'est pas bloquant)

### Sécurité & Confidentialité

- Données en transit chiffrées via HTTPS/TLS
- Données de localisation accessibles uniquement au compte utilisateur propriétaire
- Aucune revente ni partage de données de localisation avec des tiers
- Suppression complète et irréversible des données sur demande (RGPD)
- Tokens OAuth stockés dans iOS Keychain

### Scalabilité

- Architecture backend supportant 10 000 utilisateurs actifs mensuels au lancement
- Conçue pour scaler à 10x sans refonte majeure lors de l'extension multi-villes
- Volume estimé : ~1 Mo/utilisateur/mois de données GPS — base NoSQL à dimensionner en conséquence

### Intégrations Externes

- **OpenStreetMap** — tuiles cartographiques + réseau routier pour map matching
- **Wikidata / Wikipedia** — descriptions textuelles des monuments (API publique gratuite)
- **Apple Push Notification Service (APNs)** — notifications iOS
- **Sign in with Apple / Google OAuth / Facebook Login** — authentification sociale
- **AVSpeechSynthesizer (TTS natif iOS)** — lecture audio des descriptions, sans coût externe
