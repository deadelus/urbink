import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:urbink/features/sessions/models/transport_mode.dart';

/// Représente une session d'exploration circuit libre enregistrée.
class Session {
  final String sessionId;
  final String userId;
  final DateTime sessionStart;
  final DateTime? sessionEnd;
  final TransportMode mode;
  final List<String> streetIds;
  final double distanceMeters;

  const Session({
    required this.sessionId,
    required this.userId,
    required this.sessionStart,
    this.sessionEnd,
    required this.mode,
    required this.streetIds,
    required this.distanceMeters,
  });

  int get streetCount => streetIds.length;
  double get distanceKm => distanceMeters / 1000;

  Duration get duration {
    final end = sessionEnd ?? DateTime.now();
    return end.difference(sessionStart);
  }

  /// [clearSessionEnd] : passer `true` pour forcer `sessionEnd` à null
  /// (nécessaire car `sessionEnd: null` est ambigu avec "non fourni").
  Session copyWith({
    String? sessionId,
    String? userId,
    DateTime? sessionStart,
    DateTime? sessionEnd,
    bool clearSessionEnd = false,
    TransportMode? mode,
    List<String>? streetIds,
    double? distanceMeters,
  }) {
    return Session(
      sessionId: sessionId ?? this.sessionId,
      userId: userId ?? this.userId,
      sessionStart: sessionStart ?? this.sessionStart,
      sessionEnd: clearSessionEnd ? null : (sessionEnd ?? this.sessionEnd),
      mode: mode ?? this.mode,
      streetIds: streetIds ?? this.streetIds,
      distanceMeters: distanceMeters ?? this.distanceMeters,
    );
  }

  // ---------------------------------------------------------------------------
  // Firestore
  // ---------------------------------------------------------------------------

  /// Champs mutables mis à jour à chaque sauvegarde.
  ///
  /// `createdAt` est volontairement absent : il est écrit une seule fois
  /// lors de la création initiale via [toFirestoreCreate], de façon à ne pas
  /// être écrasé lors des resynchronisations offline.
  Map<String, dynamic> toFirestore() {
    return {
      'sessionStart': Timestamp.fromDate(sessionStart),
      if (sessionEnd != null) 'sessionEnd': Timestamp.fromDate(sessionEnd!),
      'mode': mode.firestoreValue,
      'streetIds': streetIds,
      'distanceMeters': distanceMeters,
    };
  }

  /// Champs complets pour la création initiale du document Firestore.
  /// Inclut `createdAt: serverTimestamp()` qui ne doit être écrit qu'une fois.
  Map<String, dynamic> toFirestoreCreate() {
    return {
      ...toFirestore(),
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  factory Session.fromFirestore(String sessionId, String userId, Map<String, dynamic> data) {
    return Session(
      sessionId: sessionId,
      userId: userId,
      sessionStart: (data['sessionStart'] as Timestamp).toDate(),
      sessionEnd: data['sessionEnd'] != null
          ? (data['sessionEnd'] as Timestamp).toDate()
          : null,
      mode: TransportMode.fromFirestoreValue(data['mode'] as String? ?? 'walk'),
      streetIds: List<String>.from(data['streetIds'] as List? ?? []),
      distanceMeters: (data['distanceMeters'] as num?)?.toDouble() ?? 0.0,
    );
  }

  // ---------------------------------------------------------------------------
  // sqflite
  // ---------------------------------------------------------------------------

  Map<String, dynamic> toSqflite() {
    return {
      'id': sessionId,
      'user_id': userId,
      'session_start': sessionStart.millisecondsSinceEpoch,
      'session_end': sessionEnd?.millisecondsSinceEpoch,
      'mode': mode.firestoreValue,
      'street_ids': jsonEncode(streetIds),
      'distance_meters': distanceMeters,
      'synced': 0,
    };
  }

  factory Session.fromSqflite(Map<String, dynamic> row) {
    return Session(
      sessionId: row['id'] as String,
      userId: row['user_id'] as String,
      sessionStart: DateTime.fromMillisecondsSinceEpoch(row['session_start'] as int),
      sessionEnd: row['session_end'] != null
          ? DateTime.fromMillisecondsSinceEpoch(row['session_end'] as int)
          : null,
      mode: TransportMode.fromFirestoreValue(row['mode'] as String? ?? 'walk'),
      streetIds: List<String>.from(
        jsonDecode(row['street_ids'] as String? ?? '[]') as List,
      ),
      distanceMeters: (row['distance_meters'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
