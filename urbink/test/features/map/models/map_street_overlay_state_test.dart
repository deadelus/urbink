import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:urbink/features/map/models/map_street_overlay_state.dart';

void main() {
  group('MapStreetOverlayState', () {
    test('isEmpty retourne true quand aucune rue explorée', () {
      const state = MapStreetOverlayState();
      expect(state.isEmpty, isTrue);
    });

    test('isEmpty retourne false quand des rues sont explorées', () {
      const state = MapStreetOverlayState(
        exploredStreets: {
          'way:123': [LatLng(48.8566, 2.3522)],
        },
      );
      expect(state.isEmpty, isFalse);
    });

    test('copyWith met à jour exploredStreets', () {
      const state = MapStreetOverlayState();
      final updated = state.copyWith(
        exploredStreets: {
          'way:456': [const LatLng(48.8570, 2.3530)],
        },
      );
      expect(updated.exploredStreets, hasLength(1));
      expect(updated.exploredStreets['way:456'], isNotNull);
    });

    test('copyWith clearCurrentStreetId efface la rue courante', () {
      const state = MapStreetOverlayState(currentStreetId: 'way:123');
      final updated = state.copyWith(clearCurrentStreetId: true);
      expect(updated.currentStreetId, isNull);
    });

    test('copyWith sans argument préserve les valeurs existantes', () {
      const state = MapStreetOverlayState(
        exploredStreets: {'way:789': []},
        currentStreetId: 'way:789',
      );
      final updated = state.copyWith();
      expect(updated.exploredStreets, state.exploredStreets);
      expect(updated.currentStreetId, 'way:789');
    });
  });
}
