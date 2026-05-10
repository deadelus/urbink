# Implementation Artifact — Story 4.7

## Story
Epic 4 · Story 4.7 — Objectifs thématiques — activation et suivi progression

## ACs implémentés

- [x] Given l'onglet Badges → onglet Objectifs / When l'écran est affiché / Then les 12 collections sont listées sous forme de cards : titre, description, icône, barre de progression N/Total, pills mode de déplacement compatible
- [x] Given un objectif activé par l'utilisateur / When il explore et passe près d'un monument de l'objectif / Then le point est coché automatiquement (via le système monument_proximity existant) et la progression se met à jour
- [x] Given un objectif complété à 100% / When le dernier monument est débloqué / Then CelebrationOverlay se déclenche en mode `badge` avec l'icône et le nom de la collection
- [x] Given la fiche d'un objectif (CollectionDetailScreen) / When l'utilisateur tape "Voir sur la carte" sur un monument non atteint / Then l'onglet Carte s'ouvre et se centre sur ce point via mapFocusProvider

## Tasks / Subtasks

- [x] Ajouter `transportModes: List<String>` à `MonumentCollection` (défaut `const ['foot']`)
- [x] Mettre à jour `paris_collections.dart` : ajouter `transportModes` sur les 12 collections (foot / bike / all)
- [x] Créer `lib/features/badges/providers/objectif_activation_provider.dart` : `activeObjectifIdsStreamProvider` + `writeObjectifActivation` + `deleteObjectifActivation`
- [x] Créer `lib/features/badges/widgets/objectif_card.dart` : `ObjectifCard` avec barre de progression, pills transport, toggle activation, onTap → CollectionDetailScreen
- [x] Mettre à jour `badges_screen.dart` : ajouter onglet `_Tab.objectifs` + `ObjectifCard` list + listener complétion 100% → `celebrationQueueProvider`
- [x] Ajouter clés i18n dans `app_fr.arb` + `app_en.arb` : `tab_objectifs`, `objectif_activate`, `objectif_deactivate`, `transport_foot`, `transport_bike`, `objectif_complete`
- [x] Régénérer `app_localizations.dart` via `flutter gen-l10n`
- [x] Écrire `test/badges/objectif_activation_test.dart` (modèle transportModes + data paris_collections)
- [x] Écrire `test/badges/objectif_card_test.dart` (widget tests affichage + interactions)
- [x] Écrire `test/badges/collection_completion_test.dart` (détection 100% → celebration)
- [x] `flutter analyze --no-pub` → 0 issue ✅
- [x] `flutter test` → 408/408 tests passent ✅

## Dev Notes

### Architecture
- Les 12 collections (`paris_collections.dart`) SONT les objectifs thématiques — pas de nouveau modèle de données distinct
- Progress déjà calculé client-side via `collectionsProvider` → `MonumentCollection.stats`
- Proximity detection déjà opérationnelle : monument_proximity_events → Cloud Function → badge dans Firestore
- `mapFocusProvider` + `CollectionDetailScreen` → `MonumentDetailSheet` → "Voir sur la carte" couvre l'AC4

### Activation Firestore
- Path : `/users/{uid}/objectifs/{collectionId}`
- Document : `{ activatedAt: Timestamp }`
- Provider : `StreamProvider<Set<String>>` qui retourne les IDs activés
- Toggle : `writeObjectifActivation` (set) / `deleteObjectifActivation` (delete)

### Complétion 100% → Celebration
- Listener dans `_BadgesScreenState.initState` via `ref.listenManual(collectionsProvider, ...)`
- Guard "initial load" : ignorer le premier appel (prev == null) pour éviter rafale au démarrage
- Déduplique via `CelebrationEvent.id = 'collection-{collectionId}'`
- `CelebrationMode.badge` avec `iconEmoji = collection.icon`

### Transport modes
- Valeurs string constantes : `'foot'`, `'bike'`, `'all'`
- Affiché comme pills colorées dans `ObjectifCard`
- Collections à pied : indispensables, lumieres-cathedrales, ponts-berges, palais-musees, place-squares, art-nouveau, revolution, romantisme
- Collections vélo aussi : moderne-contemporain, jardins-parcs, marches-gastronomie, sport-stades

### ObjectifCard design
- Fond surface, radius 16, border UrbinkColors.border
- Row header : emoji 40px | titre bold + sous-titre | pills transport
- Barre progress LinearProgressIndicator avec couleur collection
- Footer : "N/M monuments" + bouton Activer/Désactiver (OutlinedButton si inactif, FilledButton si actif)
- onTap carte entière → CollectionDetailScreen.show

### Providers existants réutilisés
- `collectionsProvider` (badges_provider.dart)
- `celebrationQueueProvider` (celebration_queue_provider.dart)
- `currentUidProvider` (session_lifecycle_provider.dart)
- `firestoreProvider` (quartier_badges_provider.dart)

## Dev Agent Record

### Debug Log
- Les 12 collections `paris_collections.dart` sont les objectifs thématiques — aucun nouveau modèle distinct requis
- Proximity detection + badge monument déjà opérationnel : AC2 satisfait via le système existant
- `CollectionDetailScreen` → `MonumentDetailSheet` → "Voir sur la carte" → `mapFocusProvider` : AC4 satisfait sans code supplémentaire
- `const MaterialApp` dans les tests de complétion nécessite `AppLocalizations.localizationsDelegates` (const) + `AppLocalizations.supportedLocales` (const)

### Completion Notes
- `MonumentCollection` : nouveau champ `transportModes: List<String>` (défaut `['foot']`), préservé dans `withUnlockedIds`
- 12 collections mises à jour avec modes foot/bike selon la nature de chaque parcours
- `activeObjectifIdsStreamProvider` : stream Firestore `/users/{uid}/objectifs/` → Set<String>
- `ObjectifCard` : card complète avec progress bar colorée (couleur collection), pills transport, bouton Activer/Actif/Complété
- `BadgesScreen` : 3ème onglet "🎯 Objectifs" + tri (actifs en tête, puis % décroissant) + listener `listenManual(collectionsProvider)` → celebration à 100%
- 6 nouvelles clés i18n (fr + en) : tab_objectifs, objectif_activate, objectif_deactivate, objectif_complete, transport_foot, transport_bike
- 3 nouveaux fichiers de tests : 41 tests badges spécifiques (8 activation/data, 10 card widget, 3 completion listener) + 387 tests existants = 408/408 ✅

## File List

- `_bmad-output/implementation-artifacts/4-7-objectifs-thematiques.md`
- `urbink/lib/features/badges/data/collection_model.dart` (modifié)
- `urbink/lib/features/badges/data/paris_collections.dart` (modifié)
- `urbink/lib/features/badges/providers/objectif_activation_provider.dart` (nouveau)
- `urbink/lib/features/badges/widgets/objectif_card.dart` (nouveau)
- `urbink/lib/features/badges/screens/badges_screen.dart` (modifié)
- `urbink/lib/l10n/app_fr.arb` (modifié)
- `urbink/lib/l10n/app_en.arb` (modifié)
- `urbink/lib/l10n/app_localizations.dart` (regénéré)
- `urbink/lib/l10n/app_localizations_fr.dart` (regénéré)
- `urbink/lib/l10n/app_localizations_en.dart` (regénéré)
- `urbink/test/badges/objectif_activation_test.dart` (nouveau)
- `urbink/test/badges/objectif_card_test.dart` (nouveau)
- `urbink/test/badges/collection_completion_test.dart` (nouveau)

## Change Log

- Ajout Story 4.7 — Objectifs thématiques : onglet Objectifs dans BadgesScreen, ObjectifCard, activation Firestore, listener celebration 100%, transportModes sur les 12 collections Paris (Date: 2026-05-09)

## Status

done
