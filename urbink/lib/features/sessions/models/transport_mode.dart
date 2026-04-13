/// Mode de déplacement sélectionné par l'utilisateur.
enum TransportMode {
  walking,
  cycling,
  driving;

  String get emoji => switch (this) {
        TransportMode.walking => '🚶',
        TransportMode.cycling => '🚴',
        TransportMode.driving => '🚗',
      };

  String get label => switch (this) {
        TransportMode.walking => 'Marche',
        TransportMode.cycling => 'Vélo',
        TransportMode.driving => 'Voiture',
      };
}
