// lib/features/courses/data/dao/course_summary_dao.dart
import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../../../../core/db/app_database.dart';
import '../models/course_summary_dto.dart';

class CourseSummaryDao {
  static const table = 'course_summaries';

  Future<Database> get _db async => AppDatabase.database;

  Future<void> ensureTable() async {
    final db = await _db;
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $table (
        course_id INTEGER NOT NULL,
        language TEXT NOT NULL,
        title TEXT NOT NULL,
        overview TEXT NOT NULL,
        key_points TEXT NOT NULL,
        next_steps TEXT NOT NULL,
        highlights TEXT NOT NULL,
        outline TEXT NOT NULL,
        key_terms TEXT NOT NULL,
        reading_time_min INTEGER NOT NULL,
        cache_hit INTEGER NOT NULL,
        generated_at INTEGER NOT NULL,
        PRIMARY KEY (course_id, language)
      )
    ''');
  }

  Future<CourseSummaryDto?> getByCourseIdLanguage({
    required int courseId,
    required String language,
  }) async {
    final db = await _db;
    final rows = await db.query(
      table,
      where: 'course_id = ? AND language = ?',
      whereArgs: [courseId, language],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return CourseSummaryDto.fromMap(rows.first);
  }

  Future<void> upsert(CourseSummaryDto dto) async {
    final db = await _db;
    await db.insert(
      table,
      dto.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Helpers si besoin ailleurs
  static String encodeList(List<String> list) => jsonEncode(list);
  static List<String> decodeList(dynamic v) {
    if (v == null) return const [];
    if (v is String) {
      final x = jsonDecode(v);
      if (x is List) return x.map((e) => e.toString()).toList();
    }
    if (v is List) return v.map((e) => e.toString()).toList();
    return const [];
  }
}
