import 'package:urbink/features/session_end/models/badge_unlock.dart';
import 'package:urbink/features/sessions/models/session_data.dart';

class SessionEndData {
  final SessionData session;
  final List<BadgeUnlock> newBadges;

  const SessionEndData({
    required this.session,
    required this.newBadges,
  });
}
