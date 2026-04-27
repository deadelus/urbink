import 'package:flutter/widgets.dart';

enum CelebrationMode { badge, district }

/// Événement dans la file d'attente des célébrations.
///
/// [id] est utilisé pour la déduplication (ex: "district-marais", "badge-eiffel").
class CelebrationEvent {
  final String id;
  final CelebrationMode mode;

  /// Nom du quartier (district) ou du badge (badge).
  final String title;

  /// Description du badge ou secret local du quartier.
  final String? subtitle;

  /// Emoji affiché dans l'icône centrale (ex: "🏆", "🗼").
  final String iconEmoji;

  /// Callback partage — mode district uniquement.
  final VoidCallback? onShare;

  const CelebrationEvent({
    required this.id,
    required this.mode,
    required this.title,
    this.subtitle,
    this.iconEmoji = '🏆',
    this.onShare,
  });
}
