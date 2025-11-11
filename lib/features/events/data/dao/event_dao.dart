import 'package:sqflite/sqflite.dart';
import '../../../../core/db/app_database.dart';
import '../models/event_dto.dart';

class EventDao {
  Future<Database> get _db async => await AppDatabase.database;

  /// Récupérer tous les events, avec option de recherche sur titre/description.
  Future<List<EventDto>> getAll({String? search}) async {
    final db = await _db;

    String? where;
    List<Object?>? args;

    if (search != null && search.trim().isNotEmpty) {
      where =
      'WHERE ${EventTable.titre} LIKE ? OR ${EventTable.description} LIKE ?';
      final q = '%${search.trim()}%';
      args = [q, q];
    }

    final rows = await db.rawQuery('''
      SELECT * FROM ${EventTable.table}
      ${where ?? ''}
      ORDER BY ${EventTable.date} ASC, ${EventTable.titre} ASC
    ''', args);

    return rows.map((m) => EventDto.fromMap(m)).toList();
  }

  /// Récupérer un event par son id_evenement.
  Future<EventDto?> getById(int idEvenement) async {
    final db = await _db;
    final rows = await db.query(
      EventTable.table,
      where: '${EventTable.id} = ?',
      whereArgs: [idEvenement],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return EventDto.fromMap(rows.first);
  }

  /// Insérer un event. Retourne l'id nouvellement inséré.
  Future<int> insert(EventDto dto) async {
    final db = await _db;
    return await db.insert(
      EventTable.table,
      dto.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  /// Mettre à jour un event par id_evenement. Retourne nb de lignes affectées.
  Future<int> update(EventDto dto) async {
    if (dto.idEvenement == null) {
      throw ArgumentError('id_evenement requis pour update');
    }
    final db = await _db;
    return await db.update(
      EventTable.table,
      dto.toMap(),
      where: '${EventTable.id} = ?',
      whereArgs: [dto.idEvenement],
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  /// Supprimer un event. Retourne nb de lignes affectées.
  Future<int> delete(int idEvenement) async {
    final db = await _db;
    return await db.delete(
      EventTable.table,
      where: '${EventTable.id} = ?',
      whereArgs: [idEvenement],
    );
  }
}
