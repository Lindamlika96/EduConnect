// lib/features/courses/data/dao/course_dao.dart
import 'package:sqflite/sqflite.dart';

import '../../../../core/db/app_database.dart';
import '../../domain/entities/course.dart';

class CourseDao {
  Future<Database> get _db async => AppDatabase.database;

  // ---------------------------------------------------------------------------
  // SEED de démo (id fixes; INSERT OR IGNORE pour éviter les doublons)
  // ---------------------------------------------------------------------------
  Future<void> ensureSeed() async {
    final db = await _db;
    final now = DateTime.now().millisecondsSinceEpoch;

    // ⚠️ IMPORTANT: pdf_path doit pointer vers des fichiers qui existent vraiment
    // dans assets/pdfs/ (cf. ton arborescence).
    final demo = [
      {
        'id': 1,
        'mentor_id': 101,
        'title': 'Flutter – Démarrage',
        'description_html': '<p>Intro à Flutter</p>',
        'level': 1,
        'language': 0,
        'duration_minutes': 90,
        'rating_avg': 4.5,
        'rating_count': 25,
        'pdf_path': 'assets/pdfs/flutter_basics.pdf', // <-- corrigé
        'created_at': now,
        'updated_at': now,
      },
      {
        'id': 2,
        'mentor_id': 101,
        'title': 'Bases de données',
        'description_html': '<p>Intro aux BD</p>',
        'level': 1,
        'language': 0,
        'duration_minutes': 120,
        'rating_avg': 4.3,
        'rating_count': 12,
        'pdf_path': 'assets/pdfs/sql.pdf',            // <-- OK
        'created_at': now,
        'updated_at': now,
      },
      {
        'id': 3,
        'mentor_id': 101,
        'title': 'Algo – Notions de base',
        'description_html': '<p>Algo 101</p>',
        'level': 1,
        'language': 0,
        'duration_minutes': 100,
        'rating_avg': 4.2,
        'rating_count': 10,
        'pdf_path': 'assets/pdfs/algo.pdf',           // <-- OK
        'created_at': now,
        'updated_at': now,
      },
    ];

    final batch = db.batch();
    for (final m in demo) {
      batch.rawInsert(
        '''
        INSERT OR IGNORE INTO course(
          id, mentor_id, title, description_html, level, language,
          duration_minutes, rating_avg, rating_count, pdf_path, created_at, updated_at
        ) VALUES(?,?,?,?,?,?,?,?,?,?,?,?)
        ''',
        [
          m['id'],
          m['mentor_id'],
          m['title'],
          m['description_html'],
          m['level'],
          m['language'],
          m['duration_minutes'],
          (m['rating_avg'] as num).toDouble(),
          m['rating_count'],
          m['pdf_path'],
          m['created_at'],
          m['updated_at'],
        ],
      );
    }
    await batch.commit(noResult: true);
  }

  // ---------------------------------------------------------------------------
  // LISTES
  // ---------------------------------------------------------------------------
  Future<List<Map<String, Object?>>> fetchCourses({
    String? q,
    int? level,
    int? language,
  }) async {
    final db = await _db;

    final where = <String>[];
    final args = <Object?>[];

    if (q != null && q.trim().isNotEmpty) {
      where.add('title LIKE ?');
      args.add('%${q.trim()}%');
    }
    if (level != null) {
      where.add('level = ?');
      args.add(level);
    }
    if (language != null) {
      where.add('language = ?');
      args.add(language);
    }

    final sql = '''
      SELECT
        c.id, c.title, c.level, c.language, c.duration_minutes,
        c.rating_avg, c.rating_count,
        -- favori bool pour l’utilisateur 1 (démo)
        CASE WHEN EXISTS(
          SELECT 1 FROM course_bookmark b WHERE b.course_id = c.id AND b.user_id = 1
        ) THEN 1 ELSE 0 END AS is_bookmarked
      FROM course c
      ${where.isEmpty ? '' : 'WHERE ${where.join(' AND ')}'}
      ORDER BY c.updated_at DESC
    ''';

    return db.rawQuery(sql, args);
  }

  // ---------------------------------------------------------------------------
  // DETAIL
  // ---------------------------------------------------------------------------
  Future<Map<String, Object?>?> fetchCourseById(int id) async {
    final db = await _db;
    final rows = await db.query(
      'course',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;

    final row = rows.first;

    // Normalisation du chemin PDF: si on a juste "sql.pdf", on préfixe.
    final raw = row['pdf_path'] as String?;
    if (raw != null && raw.isNotEmpty && !raw.startsWith('assets/')) {
      row['pdf_path'] = 'assets/pdfs/$raw';
    }

    return row;
  }

  // ---------------------------------------------------------------------------
  // FAVORIS
  // ---------------------------------------------------------------------------
  Future<void> toggleBookmark({
    required int userId,
    required int courseId,
    required int nowMs,
  }) async {
    final db = await _db;
    final exists = Sqflite.firstIntValue(await db.rawQuery(
      'SELECT COUNT(*) FROM course_bookmark WHERE user_id=? AND course_id=?',
      [userId, courseId],
    ))!;
    if (exists > 0) {
      await db.delete('course_bookmark',
          where: 'user_id=? AND course_id=?', whereArgs: [userId, courseId]);
    } else {
      await db.insert('course_bookmark', {
        'user_id': userId,
        'course_id': courseId,
        'created_at': nowMs,
      });
    }
  }

  Future<List<Course>> getBookmarks(int userId) async {
    final db = await _db;
    final rows = await db.rawQuery('''
      SELECT c.*
      FROM course c
      JOIN course_bookmark b ON b.course_id = c.id
      WHERE b.user_id = ?
      ORDER BY b.created_at DESC
    ''', [userId]);

    return rows.map((m) {
      return Course(
        id: (m['id'] as num).toInt(),
        title: (m['title'] as String?) ?? '',
        level: (m['level'] as num?)?.toInt() ?? 1,
        language: (m['language'] as num?)?.toInt() ?? 0,
        durationMinutes: (m['duration_minutes'] as num?)?.toInt() ?? 0,
        ratingAvg: (m['rating_avg'] as num?)?.toDouble() ?? 0.0,
      );
    }).toList();
  }

  // ---------------------------------------------------------------------------
  // REVIEWS
  // ---------------------------------------------------------------------------
  Future<void> addReview({
    required int userId,
    required int courseId,
    required int rating,
    String? comment,
  }) async {
    final db = await _db;
    final now = DateTime.now().millisecondsSinceEpoch;
    await db.insert('course_review', {
      'user_id': userId,
      'course_id': courseId,
      'rating': rating,
      'comment': comment,
      'created_at': now,
    });
  }

  // ---------------------------------------------------------------------------
  // PROGRESSION
  // ---------------------------------------------------------------------------
  Future<void> enrollIfNeeded({
    required int userId,
    required int courseId,
    required int nowMs,
  }) async {
    final db = await _db;
    final count = Sqflite.firstIntValue(await db.rawQuery(
      'SELECT COUNT(*) FROM course_progress WHERE user_id=? AND course_id=?',
      [userId, courseId],
    ))!;
    if (count == 0) {
      await db.insert('course_progress', {
        'user_id': userId,
        'course_id': courseId,
        'progress_percent': 0.0,
        'updated_at': nowMs,
      });
    }
  }

  Future<void> upsertProgressMax({
    required int userId,
    required int courseId,
    required double percent,
    required int nowMs,
  }) async {
    final db = await _db;
    final row = await db.query(
      'course_progress',
      where: 'user_id=? AND course_id=?',
      whereArgs: [userId, courseId],
      limit: 1,
    );

    if (row.isEmpty) {
      await db.insert('course_progress', {
        'user_id': userId,
        'course_id': courseId,
        'progress_percent': percent,
        'updated_at': nowMs,
      });
    } else {
      final current = (row.first['progress_percent'] as num?)?.toDouble() ?? 0.0;
      final next = percent > current ? percent : current;
      await db.update(
        'course_progress',
        {'progress_percent': next, 'updated_at': nowMs},
        where: 'user_id=? AND course_id=?',
        whereArgs: [userId, courseId],
      );
    }
  }

  Future<List<Map<String, Object?>>> getMyCoursesOngoing(int userId) async {
    final db = await _db;
    return db.rawQuery('''
      SELECT c.id, c.title, c.level, c.language, c.duration_minutes,
             c.rating_avg, c.rating_count,
             p.progress_percent, p.updated_at,
             CASE WHEN EXISTS(
               SELECT 1 FROM course_bookmark b WHERE b.course_id = c.id AND b.user_id = ?
             ) THEN 1 ELSE 0 END AS is_bookmarked
      FROM course_progress p
      JOIN course c ON c.id = p.course_id
      WHERE p.user_id = ? AND p.progress_percent < 100.0
      ORDER BY p.updated_at DESC
    ''', [userId, userId]);
  }

  Future<List<Map<String, Object?>>> getMyCoursesCompleted(int userId) async {
    final db = await _db;
    return db.rawQuery('''
      SELECT c.id, c.title, c.level, c.language, c.duration_minutes,
             c.rating_avg, c.rating_count,
             p.progress_percent, p.updated_at,
             CASE WHEN EXISTS(
               SELECT 1 FROM course_bookmark b WHERE b.course_id = c.id AND b.user_id = ?
             ) THEN 1 ELSE 0 END AS is_bookmarked
      FROM course_progress p
      JOIN course c ON c.id = p.course_id
      WHERE p.user_id = ? AND p.progress_percent >= 100.0
      ORDER BY p.updated_at DESC
    ''', [userId, userId]);
  }

  // ---------------------------------------------------------------------------
  // DEBUG (optionnel, à retirer ensuite)
  // ---------------------------------------------------------------------------
  Future<List<Map<String, Object?>>> debugAllCourses() async {
    final db = await _db;
    return db.query('course', orderBy: 'id ASC');
  }

  Future<Map<String, Object?>?> debugCourseById(int id) async {
    final db = await _db;
    final rows = await db.query('course', where: 'id=?', whereArgs: [id], limit: 1);
    return rows.isEmpty ? null : rows.first;
  }
}