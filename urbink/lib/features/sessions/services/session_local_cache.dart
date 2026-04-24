import 'dart:convert';

import 'package:path/path.dart' show join;
import 'package:sqflite/sqflite.dart';
import 'package:urbink/features/sessions/models/session.dart';

const _kDbName = 'urbink_local.db';
const _kDbVersion = 1;
const _kTable = 'local_sessions';

/// Cache local sqflite pour les sessions en cours et non-synchronisées.
///
/// Source de vérité pour le crash recovery et le fallback offline.
/// Firestore reste la source de vérité cloud.
///
/// [dbPath] est injectable pour les tests (ex: `inMemoryDatabasePath`).
/// En production, le chemin absolu est construit via [getDatabasesPath()].
class SessionLocalCache {
  final String? dbPath;
  Database? _db;

  SessionLocalCache({this.dbPath});

  Future<Database> _getDb() async {
    if (_db == null) {
      // Construire le chemin absolu si aucun chemin explicite n'est fourni.
      // Évite les comportements non-déterministes de sqflite avec un nom seul.
      final resolvedPath = dbPath ?? join(await getDatabasesPath(), _kDbName);
      _db = await openDatabase(
        resolvedPath,
        version: _kDbVersion,
        onCreate: (db, version) => db.execute('''
          CREATE TABLE IF NOT EXISTS $_kTable (
            id TEXT PRIMARY KEY,
            user_id TEXT NOT NULL,
            session_start INTEGER NOT NULL,
            session_end INTEGER,
            mode TEXT NOT NULL DEFAULT 'walk',
            street_ids TEXT NOT NULL DEFAULT '[]',
            distance_meters REAL NOT NULL DEFAULT 0.0,
            synced INTEGER NOT NULL DEFAULT 0
          )
        '''),
      );
    }
    return _db!;
  }

  /// Insère une nouvelle session (session_end = null → session active).
  Future<void> insertSession(Session session) async {
    final db = await _getDb();
    await db.insert(
      _kTable,
      session.toSqflite(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Met à jour une session existante (fin de session, métriques finales).
  Future<void> updateSession(Session session) async {
    final db = await _getDb();
    await db.update(
      _kTable,
      {
        'session_end': session.sessionEnd?.millisecondsSinceEpoch,
        'mode': session.mode.firestoreValue,
        'street_ids': jsonEncode(session.streetIds),
        'distance_meters': session.distanceMeters,
      },
      where: 'id = ?',
      whereArgs: [session.sessionId],
    );
  }

  /// Retourne la session interrompue de l'utilisateur [userId]
  /// (session_end IS NULL AND synced = 0).
  ///
  /// Filtrage par userId pour éviter d'afficher une session d'un autre
  /// compte sur un device partagé (logout/login).
  Future<Session?> getInterruptedSession(String userId) async {
    final db = await _getDb();
    final rows = await db.query(
      _kTable,
      where: 'session_end IS NULL AND synced = 0 AND user_id = ?',
      whereArgs: [userId],
      orderBy: 'session_start DESC',
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return Session.fromSqflite(rows.first);
  }

  /// Retourne toutes les sessions non-synchronisées de [userId].
  ///
  /// Filtrage par userId pour éviter de re-syncer des sessions
  /// appartenant à un ancien compte après un logout/login.
  Future<List<Session>> getUnsyncedSessions(String userId) async {
    final db = await _getDb();
    final rows = await db.query(
      _kTable,
      where: 'synced = 0 AND session_end IS NOT NULL AND user_id = ?',
      whereArgs: [userId],
    );
    return rows.map(Session.fromSqflite).toList();
  }

  /// Marque une session comme synchronisée avec Firestore.
  Future<void> markSynced(String sessionId) async {
    final db = await _getDb();
    await db.update(
      _kTable,
      {'synced': 1},
      where: 'id = ?',
      whereArgs: [sessionId],
    );
  }

  /// Marque une session interrompue comme abandonnée (session_end = now).
  Future<void> markCancelled(String sessionId) async {
    final db = await _getDb();
    await db.update(
      _kTable,
      {
        'session_end': DateTime.now().millisecondsSinceEpoch,
        'synced': 1, // pas besoin de sync — session abandonnée
      },
      where: 'id = ?',
      whereArgs: [sessionId],
    );
  }

  /// Retourne toutes les sessions complètes de [userId] pour la semaine
  /// commençant à [weekStart] (lundi minuit, heure locale).
  Future<List<Session>> getSessionsForWeek(
    String userId,
    DateTime weekStart,
  ) async {
    final db = await _getDb();
    final weekEnd = weekStart.add(const Duration(days: 7));
    final rows = await db.query(
      _kTable,
      where:
          'user_id = ? AND session_start >= ? AND session_start < ? AND session_end IS NOT NULL',
      whereArgs: [
        userId,
        weekStart.millisecondsSinceEpoch,
        weekEnd.millisecondsSinceEpoch,
      ],
      orderBy: 'session_start DESC',
    );
    return rows.map(Session.fromSqflite).toList();
  }

  /// Ferme la base de données (utile en test).
  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}
