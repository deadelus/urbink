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

  String get firestoreValue => switch (this) {
        TransportMode.walking => 'walk',
        TransportMode.cycling => 'bike',
        TransportMode.driving => 'car',
      };

  static TransportMode fromFirestoreValue(String value) => switch (value) {
        'bike' => TransportMode.cycling,
        'car' => TransportMode.driving,
        _ => TransportMode.walking,
      };
}
