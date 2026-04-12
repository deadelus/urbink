import 'package:flutter_test/flutter_test.dart';
import 'package:urbink/core/utils/tile_error_utils.dart';

// Simule la classe interne CancelledException du package executor.
// Le nom doit correspondre exactement à ce que runtimeType.toString() retourne.
class CancelledException implements Exception {
  const CancelledException();
}

// Autre exception quelconque pour vérifier que le filtre est sélectif.
class OtherException implements Exception {
  const OtherException();
}

const _tileStack = '''
#0  TileLayer._loadTile (package:vector_map_tiles/src/tile_layer.dart:42:5)
#1  ExecutorPool.run (package:executor/src/pool.dart:88:11)
''';

const _executorStack = '''
#0  SomeClass.method (package:myapp/src/foo.dart:10:3)
#1  ExecutorPool.run (package:some_lib/src/executor/pool.dart:88:11)
''';

const _unrelatedStack = '''
#0  SomeWidget.build (package:myapp/src/widgets/foo.dart:20:5)
#1  main (package:myapp/main.dart:15:3)
''';

void main() {
  group('isCancelledTileError', () {
    test('retourne true — CancelledException + stack vector_map_tiles', () {
      expect(
        isCancelledTileError(
          const CancelledException(),
          StackTrace.fromString(_tileStack),
        ),
        isTrue,
      );
    });

    test('retourne true — CancelledException + stack /executor/', () {
      expect(
        isCancelledTileError(
          const CancelledException(),
          StackTrace.fromString(_executorStack),
        ),
        isTrue,
      );
    });

    test('retourne false — CancelledException mais stack sans frame tuile', () {
      // Protège contre un CancelledException d'une lib non liée aux tuiles.
      expect(
        isCancelledTileError(
          const CancelledException(),
          StackTrace.fromString(_unrelatedStack),
        ),
        isFalse,
      );
    });

    test('retourne false — exception différente, même stack tile', () {
      expect(
        isCancelledTileError(
          const OtherException(),
          StackTrace.fromString(_tileStack),
        ),
        isFalse,
      );
    });

    test('retourne false — exception différente, stack vide', () {
      expect(
        isCancelledTileError(const OtherException(), StackTrace.empty),
        isFalse,
      );
    });

    test('retourne false — CancelledException, stack vide', () {
      // Sans frame identifiable, on ne filtre pas pour éviter les faux positifs.
      expect(
        isCancelledTileError(const CancelledException(), StackTrace.empty),
        isFalse,
      );
    });
  });
}
