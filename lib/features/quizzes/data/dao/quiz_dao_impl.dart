// lib/features/quizzes/data/dao/quiz_dao_impl.dart
import 'package:sqflite/sqflite.dart';
import 'quiz_dao.dart';
import '../quiz_seeds.dart';

class QuizDaoImpl implements QuizDao {
  final Future<Database> _db;
  QuizDaoImpl(this._db);

  @override
  Future<List<Map<String, Object?>>> fetchQuizzes({int? courseId}) async {
    final db = await _db;
    return db.query(
      'quiz',
      where: courseId != null ? 'course_id = ?' : null,
      whereArgs: courseId != null ? [courseId] : null,
    );
  }

  @override
  Future<Map<String, Object?>?> fetchQuizById(int id) async {
    final db = await _db;
    final rows = await db.query(
      'quiz',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first;
  }

  @override
  Future<List<Map<String, Object?>>> fetchQuestions(int quizId) async {
    final db = await _db;
    return db.query('question', where: 'quiz_id = ?', whereArgs: [quizId]);
  }

  // ✅ Questions par difficulté
  @override
  Future<List<Map<String, Object?>>> fetchQuestionsByDifficulty(
    int quizId,
    String difficulty,
  ) async {
    final db = await _db;
    return db.query(
      'question',
      where: 'quiz_id = ? AND difficulty = ?',
      whereArgs: [quizId, difficulty],
    );
  }

  // ✅ Mélange de questions (toutes difficultés)
  @override
  Future<List<Map<String, Object?>>> fetchMixedQuestions(int quizId) async {
    final db = await _db;
    final rows = await db.query(
      'question',
      where: 'quiz_id = ?',
      whereArgs: [quizId],
    );
    rows.shuffle();
    return rows;
  }

  @override
  Future<int> insertQuiz(Map<String, Object?> quiz) async {
    final db = await _db;
    return db.insert('quiz', quiz);
  }

  @override
  Future<int> insertQuestion(Map<String, Object?> question) async {
    final db = await _db;
    return db.insert('question', question);
  }

  @override
  Future<int> insertResult({
    required int userId,
    required int quizId,
    required int score,
    required int total,
  }) async {
    final db = await _db;
    return db.insert('result', {
      'user_id': userId,
      'quiz_id': quizId,
      'score': score,
      'total': total,
      'date': DateTime.now().toIso8601String(),
    });
  }

  @override
  Future<void> seedQuizWithQuestions(int courseId) async {
    final db = await _db;

    // Vérifier cours
    final course = await db.query(
      'course',
      where: 'id = ?',
      whereArgs: [courseId],
    );
    if (course.isEmpty) {
      print('❌ seedQuizWithQuestions: cours $courseId inexistant.');
      return;
    }

    // Éviter doublon
    final existingQuiz = await db.query(
      'quiz',
      where: 'course_id = ?',
      whereArgs: [courseId],
    );
    if (existingQuiz.isNotEmpty) {
      print(
        '⚠️ seedQuizWithQuestions: quiz déjà présent pour le cours $courseId.',
      );
      return;
    }

    // Récup seed
    final seed = quizSeeds[courseId];
    if (seed == null) {
      print('❌ Aucun seed pour le cours $courseId.');
      return;
    }

    // Insérer quiz
    final quizId = await db.insert('quiz', {
      'course_id': courseId,
      'title': seed['title'],
    });

    // Insérer questions
    final batch = db.batch();
    final List questions = seed['questions'] as List;
    for (final q in questions) {
      batch.insert('question', {
        'quiz_id': quizId,
        'text': q['text'],
        'option_a': q['option_a'],
        'option_b': q['option_b'],
        'option_c': q['option_c'],
        'option_d': q['option_d'],
        'correct_index': q['correct_index'],
        'explanation': q['explanation'],
        'difficulty': q['difficulty'],
      });
    }
    await batch.commit(noResult: true);

    print('📝 Quiz "${seed['title']}" inséré pour le cours $courseId.');
  }

  @override
  Future<List<Map<String, Object?>>> topScores({int limit = 10}) async {
    final db = await _db;
    return db.query('result', orderBy: 'score DESC', limit: limit);
  }
}
