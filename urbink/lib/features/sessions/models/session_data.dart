/// Données temps réel d'une session active.
class SessionData {
  final bool active;
  final double km;
  final int streets;
  final int secs;
  final int zonePercent;
  final int newStreets;
  final int calories;
  // Non-null en production → _LiveTimerDisplay gère son propre horloge.
  // Null en test → secs est utilisé directement.
  final DateTime? sessionStartTime;

  const SessionData({
    required this.active,
    required this.km,
    required this.streets,
    required this.secs,
    this.zonePercent = 0,
    this.newStreets = 0,
    this.calories = 0,
    this.sessionStartTime,
  });
}
