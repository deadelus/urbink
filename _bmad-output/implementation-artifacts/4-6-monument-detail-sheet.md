# Implementation Artifact — Story 4.6

## Story
Epic 4 · Story 4.6 — Monument Detail Bottom Sheet

## ACs implémentés

- [x] Given l'utilisateur tape sur une tuile monument dans la grille d'une collection / When `MonumentTile.onTap` est déclenché / Then une bottom sheet remonte avec le détail du monument
- [x] Given la sheet est ouverte / When le monument est verrouillé / Then la status card affiche l'icône 🔒 + "Pas encore visité" + hint "Approchez-vous à moins de 100 m"
- [x] Given la sheet est ouverte / When le monument est débloqué / Then la status card affiche 🏆 + "Badge débloqué" en couleur collection
- [x] Given la sheet est ouverte / Then la mini-carte stylisée positionne le pin selon les coordonnées GPS normalisées du monument
- [x] Given la sheet est ouverte / Then la pill arrondissement (top-left) et la pill "Visité ✓" (top-right, si débloqué) sont affichées sur la mini-carte
- [x] Given la sheet est ouverte / Then le header affiche : emoji 54×54, nom Crimson Pro 20sp, pill collection (couleur) + époque
- [x] Given la sheet est ouverte / Then la description du monument est affichée (13sp, lineHeight 1.5)
- [x] Given l'utilisateur tape "Partager" / Then `Share.share` est appelé avec nom · époque · arrondissement · description
- [x] Given l'utilisateur tape "Voir sur la carte" / Then la sheet se ferme, l'overlay collection se ferme, `mapFocusProvider` est mis à jour, et l'onglet Carte est affiché
- [x] Given drag handle, tap ×, tap backdrop / Then la sheet se ferme

## Tasks / Subtasks

- [x] Enrichir `CollectionMonument` : ajouter `arrondissement`, `era`, `description` (optionnels, défaut `''`)
- [x] Mettre à jour `paris_monuments.dart` : 70 monuments avec `arrondissement`, `era`, `description` en français
- [x] Créer `mini_map.dart` : `MiniMap` (CustomPainter V1) + halos, grille, Seine, parcs, pills overlay
- [x] Créer `monument_detail_sheet.dart` : `MonumentDetailSheet.show` + `_MonumentDetailContent` + `_MonumentHeader` + `_StatusCard` + `_ActionsRow`
- [x] Mettre à jour `monument_tile.dart` : paramètre `onTap` optionnel + `GestureDetector`
- [x] Mettre à jour `collection_detail_screen.dart` : méthode statique `_showMonumentDetail` + passage `onTap` aux `MonumentTile`
- [x] Ajouter clés i18n `btn_share`, `btn_show_on_map`, `mon_visited`, `mon_visited_sub`, `mon_locked`, `mon_locked_sub`, `mon_arr` dans `app_fr.arb` + `app_en.arb`
- [x] Tests `test/badges/monument_sheet_test.dart` : 20 tests (modèle × 3, MiniMap × 4, Sheet × 8 + backdrop)
- [x] `flutter analyze --no-pub` → 0 issue ✅
- [x] `flutter test` → 387/387 ✅

## Dev Notes

**Collision `latlong2.Path` / `ui.Path`** : `mini_map.dart` importe `latlong2` avec `hide Path` pour éviter l'ambiguïté avec le `Path` de `dart:ui` utilisé dans le `CustomPainter`.

**Coordonnées normalisées** : la bounding box Paris (48.815–48.902 lat, 2.224–2.466 lng) est utilisée pour convertir une `LatLng` en position (0–1) sur le canvas 200×140. Si `location` est null, le pin est centré (0.5, 0.5).

**Navigation "Voir sur la carte"** : `CollectionDetailScreen._showMonumentDetail` capture `rootNav` et `router` AVANT toute navigation (contexte stable), puis la callback `onShowOnMap` exécute `rootNav.pop()` + `router.go(AppRoutes.map)`. `mapFocusProvider` est mis à jour dans la sheet (via `Consumer`) avant d'appeler la callback.

**`share_plus` v10** : utilisation de `Share.share(text)` — API stable cross-platform.

**Strings codées en dur en français** : cohérent avec le reste de la feature badges qui n'utilise pas encore `AppLocalizations`. Les clés ARB sont ajoutées pour une migration future.

**Hors scope** : `visitedAt` (historique d'unlock), photos réelles, onglets Infos/Histoire/Photos, lien Wikipedia in-app, bouton "Y aller maintenant".

## File List

**Nouveaux :**
- `urbink/lib/features/badges/widgets/mini_map.dart`
- `urbink/lib/features/badges/screens/monument_detail_sheet.dart`
- `urbink/test/badges/monument_sheet_test.dart`

**Modifiés :**
- `urbink/lib/features/badges/data/collection_model.dart`
- `urbink/lib/features/badges/data/paris_monuments.dart`
- `urbink/lib/features/badges/widgets/monument_tile.dart`
- `urbink/lib/features/badges/screens/collection_detail_screen.dart`
- `urbink/lib/l10n/app_fr.arb`
- `urbink/lib/l10n/app_en.arb`

## Dev Agent Record

**Implementation Notes:**
- `CollectionMonument` reste `const`-compatible (champs `String` avec défauts `''`)
- `withLocked()` copie les 3 nouveaux champs — vérifié par test
- Tests widget sheet via `MonumentDetailSheet.show` dans une `MaterialApp` + `ProviderScope` sans GoRouter (callback `onShowOnMap` est un no-op dans les tests)
- `_MiniMapPainter.shouldRepaint` implémenté pour optimiser le repaint

## Change Log

- Ajout story 4.6 : Monument Detail Bottom Sheet — bottom sheet, mini-carte, status card, actions (2026-05-07)

## Status

done
