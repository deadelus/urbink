class QuartierProgression {
  final String id;
  final String name;
  final int totalStreets;
  final int exploredStreets;

  const QuartierProgression({
    required this.id,
    required this.name,
    required this.totalStreets,
    required this.exploredStreets,
  });

  double get completionPercent =>
      totalStreets == 0 ? 0.0 : exploredStreets / totalStreets * 100;
}
