import 'package:sqflite/sqflite.dart';

/// Contrat DAO pour la feature "Courses".
abstract class CourseDao {
  Future<List<Map<String, Object?>>> fetchCourses({String? q, int? level, int? language});
  Future<Map<String, Object?>?> fetchCourseById(int id);
  Future<int> toggleBookmark({required int userId, required int courseId});
  Future<int> addReview({required int userId, required int courseId, required int rating, String? comment});
  Future<int> upsertProgress({required int userId, required int courseId, required double percent});

  /// Helpers DEV
  Future<int> insertDummyCourse();
  Future<void> seedIfEmpty(List<Map<String, Object?>> rows);
  Future<void> dumpCoursesToLog();
}

/// Implémentation SQLite avec sqflite.
class CourseDaoImpl implements CourseDao {
  final Future<Database> _db;
  CourseDaoImpl(this._db);

  Future<int> _countCourses() async {
    final db = await _db;
    final r = await db.rawQuery('SELECT COUNT(*) AS c FROM course');
    final v = r.first['c'];
    if (v is int) return v;
    if (v is num) return v.toInt();
    return 0;
  }

  @override
  Future<void> seedIfEmpty(List<Map<String, Object?>> rows) async {
    final db = await _db;
    if (await _countCourses() > 0) return;
    final batch = db.batch();
    for (final row in rows) {
      batch.insert('course', row);
    }
    await batch.commit(noResult: true);
  }

  @override
  Future<List<Map<String, Object?>>> fetchCourses({String? q, int? level, int? language}) async {
    final db = await _db;
    final where = <String>[];
    final args = <Object?>[];

    if (q != null && q.trim().isNotEmpty) { where.add('title LIKE ?'); args.add('%$q%'); }
    if (level != null)    { where.add('level = ?');    args.add(level); }
    if (language != null) { where.add('language = ?'); args.add(language); }

    final sql = [
      'SELECT id, title, rating_avg, rating_count, students_count, created_at',
      'FROM course',
      if (where.isNotEmpty) 'WHERE ${where.join(' AND ')}',
      'ORDER BY created_at DESC'
    ].join(' ');

    return db.rawQuery(sql, args);
  }

  @override
  Future<Map<String, Object?>?> fetchCourseById(int id) async {
    final db = await _db;
    final rows = await db.query('course', where: 'id = ?', whereArgs: [id], limit: 1);
    return rows.isEmpty ? null : rows.first;
  }

  @override
  Future<int> toggleBookmark({required int userId, required int courseId}) async {
    // TODO: implémenter la vraie logique sur table course_bookmark
    return 1;
  }

  @override
  Future<int> addReview({required int userId, required int courseId, required int rating, String? comment}) async {
    // TODO: insert dans course_review, puis mettre à jour rating_avg/rating_count
    return 1;
  }

  @override
  Future<int> upsertProgress({required int userId, required int courseId, required double percent}) async {
    // TODO: upsert dans course_progress
    return 1;
  }

  @override
  Future<int> insertDummyCourse() async {
    final db = await _db;
    final now = DateTime.now().millisecondsSinceEpoch;
    return db.insert('course', {
      'mentor_id': 1,
      'title': 'Cours démo PDF',
      'description_html': '<p>Intro</p>',
      'level': 1,
      'language': 0,
      'duration_minutes': 90,
      'pdf_path': 'assets/pdfs/demo_course.pdf',
      'rating_avg': 4.3,
      'rating_count': 7,
      'students_count': 120,
      'created_at': now,
      'updated_at': now,
    });
  }

  @override
  Future<void> dumpCoursesToLog() async {
    final db = await _db;
    final r = await db.rawQuery('SELECT * FROM course ORDER BY id');
    // ignore: avoid_print
    for (final row in r) { print(row); }
  }
}
