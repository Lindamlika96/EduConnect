import 'package:sqflite/sqflite.dart';

abstract class CourseDao {
  Future<List<Map<String, Object?>>> fetchCourses({String? q, int? level, int? language});
  Future<Map<String, Object?>?> fetchCourseById(int id);
  Future<int> toggleBookmark({required int userId, required int courseId});
  Future<int> addReview({required int userId, required int courseId, required int rating, String? comment});
  Future<int> upsertProgress({required int userId, required int courseId, required double percent});

  // 👉 helper DEV (pour insérer vite un cours de test)
  Future<int> insertDummyCourse();
}

class CourseDaoImpl implements CourseDao {
  final Future<Database> _db;
  CourseDaoImpl(this._db);

  @override
  Future<List<Map<String, Object?>>> fetchCourses({String? q, int? level, int? language}) async {
    final db = await _db;
    final where = <String>[];
    final args = <Object?>[];

    if (q != null && q.isNotEmpty) { where.add('title LIKE ?'); args.add('%$q%'); }
    if (level != null) { where.add('level = ?'); args.add(level); }
    if (language != null) { where.add('language = ?'); args.add(language); }

    return db.query(
      'course',
      columns: ['id','title','rating_avg','rating_count','students_count'],
      where: where.isEmpty ? null : where.join(' AND '),
      whereArgs: args,
      orderBy: 'rating_avg DESC, rating_count DESC',
    );
  }

  @override
  Future<Map<String, Object?>?> fetchCourseById(int id) async {
    final db = await _db;
    final rows = await db.query('course', where: 'id = ?', whereArgs: [id], limit: 1);
    return rows.isEmpty ? null : rows.first;
  }

  @override
  Future<int> toggleBookmark({required int userId, required int courseId}) async => 1;

  @override
  Future<int> addReview({required int userId, required int courseId, required int rating, String? comment}) async => 1;

  @override
  Future<int> upsertProgress({required int userId, required int courseId, required double percent}) async => 1;

  // 👉 helper DEV pour peupler rapidement
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
      'pdf_path': 'assets/pdfs/demo_course.pdf', // <<< ici
      'rating_avg': 4.3,
      'rating_count': 7,
      'students_count': 120,
      'created_at': now,
      'updated_at': now,
    });
  }
}
