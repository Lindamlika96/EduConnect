import 'package:sqflite/sqflite.dart';
import '../../../../core/db/app_database.dart';
import '../models/participation_dto.dart';

class ParticipationDao {
  Future<Database> get _db async => await AppDatabase.database;

  /// Upsert via INSERT OR REPLACE (PK composite).
  Future<void> setStatus({
    required int evenementId,
    required int userId,
    required String status,
  }) async {
    final db = await _db;
    await db.insert(
      ParticipationTable.table,
      ParticipationDto(evenementId: evenementId, userId: userId, status: status).toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<ParticipationDto?> getStatus({
    required int evenementId,
    required int userId,
  }) async {
    final db = await _db;
    final rows = await db.query(
      ParticipationTable.table,
      where:
      '${ParticipationTable.evenementId} = ? AND ${ParticipationTable.userId} = ?',
      whereArgs: [evenementId, userId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return ParticipationDto.fromMap(rows.first);
  }

  Future<List<int>> getEventIdsByStatus({
    required int userId,
    required String status,
  }) async {
    final db = await _db;
    final rows = await db.query(
      ParticipationTable.table,
      columns: [ParticipationTable.evenementId],
      where:
      '${ParticipationTable.userId} = ? AND ${ParticipationTable.status} = ?',
      whereArgs: [userId, status],
      orderBy: '${ParticipationTable.evenementId} ASC',
    );
    return rows
        .map((m) => m[ParticipationTable.evenementId] as int)
        .toList(growable: false);
  }

  Future<int> remove({
    required int evenementId,
    required int userId,
  }) async {
    final db = await _db;
    return await db.delete(
      ParticipationTable.table,
      where:
      '${ParticipationTable.evenementId} = ? AND ${ParticipationTable.userId} = ?',
      whereArgs: [evenementId, userId],
    );
  }

  Future<int> countByStatus({
    required int evenementId,
    required String status,
  }) async {
    final db = await _db;
    final rows = await db.rawQuery('''
      SELECT COUNT(*) as c
      FROM ${ParticipationTable.table}
      WHERE ${ParticipationTable.evenementId} = ? AND ${ParticipationTable.status} = ?
    ''', [evenementId, status]);

    final m = rows.first;
    final n = m['c'];
    if (n is int) return n;
    if (n is BigInt) return n.toInt();
    if (n is num) return n.toInt();
    return 0;
  }
}
