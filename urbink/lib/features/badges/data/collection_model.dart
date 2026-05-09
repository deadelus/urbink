import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

// ---------------------------------------------------------------------------
// CollectionMonument — monument dans une collection (avec état locked)
// ---------------------------------------------------------------------------

class CollectionMonument {
  final String id;
  final String emoji;
  final String name;
  final LatLng? location;
  final bool locked;
  final String arrondissement;
  final String era;
  final String description;

  const CollectionMonument({
    required this.id,
    required this.emoji,
    required this.name,
    this.location,
    this.locked = true,
    this.arrondissement = '',
    this.era = '',
    this.description = '',
  });

  CollectionMonument withLocked(bool locked) => CollectionMonument(
        id: id,
        emoji: emoji,
        name: name,
        location: location,
        locked: locked,
        arrondissement: arrondissement,
        era: era,
        description: description,
      );
}

// ---------------------------------------------------------------------------
// MonumentCollection
// ---------------------------------------------------------------------------

class MonumentCollection {
  final String id;
  final String name;
  final String subtitle;
  final String icon;
  final Color color;
  final List<CollectionMonument> monuments;
  final List<String> transportModes;

  const MonumentCollection({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.monuments,
    this.transportModes = const ['foot'],
  });

  CollectionStats get stats {
    final unlocked = monuments.where((m) => !m.locked).length;
    final total = monuments.length;
    return CollectionStats(
      total: total,
      unlocked: unlocked,
      pct: total > 0 ? (unlocked / total * 100).round() : 0,
    );
  }

  MonumentCollection withUnlockedIds(Set<String> unlockedIds) =>
      MonumentCollection(
        id: id,
        name: name,
        subtitle: subtitle,
        icon: icon,
        color: color,
        monuments: monuments
            .map((m) => m.withLocked(!unlockedIds.contains(m.id)))
            .toList(),
        transportModes: transportModes,
      );
}

// ---------------------------------------------------------------------------
// CollectionStats
// ---------------------------------------------------------------------------

class CollectionStats {
  final int total;
  final int unlocked;
  final int pct;

  const CollectionStats({
    required this.total,
    required this.unlocked,
    required this.pct,
  });
}
