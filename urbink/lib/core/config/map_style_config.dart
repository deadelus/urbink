/// Configuration d'un style de carte MapTiler.
///
/// Plusieurs styles peuvent être proposés à l'utilisateur (Urbink, Nuit,
/// Satellite, etc.). L'ID actif est stocké dans [activeMapStyleProvider].
class MapStyleConfig {
  final String id;       // identifiant interne : 'urbink_default', 'dark', ...
  final String name;     // nom affiché à l'utilisateur
  final String tileId;   // ID de la map MapTiler

  const MapStyleConfig({
    required this.id,
    required this.name,
    required this.tileId,
  });
}

// ---------------------------------------------------------------------------
// Registre des styles disponibles
// ---------------------------------------------------------------------------

const mapStylesRegistry = <MapStyleConfig>[
  MapStyleConfig(
    id: 'urbink_default',
    name: 'Urbink',
    tileId: '019d8380-71b7-7e7b-9a8e-db45546c20e5',
  ),
  // Nouveaux styles à ajouter ici — l'UI de sélection sera dans une story dédiée.
];
