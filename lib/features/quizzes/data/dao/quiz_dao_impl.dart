// lib/features/quizzes/data/dao/quiz_dao_impl.dart
import 'package:sqflite/sqflite.dart';
import 'quiz_dao.dart';
import '../../data/quiz_seeds.dart';
import '../../data/pratique_quiz_seeds.dart';

class QuizDaoImpl implements QuizDao {
  final Future<Database> _db;
  QuizDaoImpl(this._db);

  // =====================================================
  // 🧩 MÉTHODES DE BASE
  // =====================================================
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

  @override
  Future<List<Map<String, Object?>>> fetchQuestionsByDifficulty(
      int quizId, String difficulty) async {
    final db = await _db;
    return db.query(
      'question',
      where: 'quiz_id = ? AND difficulty = ?',
      whereArgs: [quizId, difficulty],
    );
  }

  @override
  Future<List<Map<String, Object?>>> fetchMixedQuestions(int quizId) async {
    final db = await _db;
    final rows =
    await db.query('question', where: 'quiz_id = ?', whereArgs: [quizId]);
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
  Future<List<Map<String, Object?>>> topScores({int limit = 10}) async {
    final db = await _db;
    return db.query('result', orderBy: 'score DESC', limit: limit);
  }

  // =====================================================
  // 🚀 INITIALISATION AUTOMATIQUE DES SEEDS (Protégée)
  // =====================================================
  Future<void> initSeeds() async {
    final db = await _db;

    // ⚠️ Si des questions existent déjà, ne rien faire
    final existingQuestions = await db.query('question');
    if (existingQuestions.isNotEmpty) {
      print('⚠️ Les seeds sont déjà présents dans la base.');
      return;
    }

    print('🚀 Insertion des seeds de quiz...');

    // ✅ Méthode interne sécurisée
    Future<int> _insertQuizSafe(int courseId, String title) async {
      // Vérifie si le quiz pour ce cours existe déjà
      final existingQuiz = await db.query(
        'quiz',
        where: 'course_id = ?',
        whereArgs: [courseId],
        limit: 1,
      );

      if (existingQuiz.isNotEmpty) {
        print('⚠️ Quiz déjà présent pour le cours $courseId → ignoré.');
        return existingQuiz.first['id'] as int;
      }

      try {
        return await db.insert('quiz', {
          'course_id': courseId,
          'title': title,
        });
      } catch (e) {
        print('⛔ Erreur d’insertion du quiz pour le cours $courseId : $e');
        return -1; // signale une erreur pour ce cours
      }
    }

    // 1️⃣ Insertion des quiz théoriques
    for (final entry in quizSeeds.entries) {
      final courseId = entry.key;
      final quizId = await _insertQuizSafe(courseId, entry.value['title'] as String);

      if (quizId == -1) continue; // passe si erreur FK ou doublon

      final List questions = entry.value['questions'] as List;
      for (final q in questions) {
        await db.insert('question', {
          'quiz_id': quizId,
          'text': q['text'],
          'option_a': q['option_a'],
          'option_b': q['option_b'],
          'option_c': q['option_c'],
          'option_d': q['option_d'],
          'correct_index': q['correct_index'],
          'explanation': q['explanation'],
          'difficulty': q['difficulty'],
          'code_snippet': null,
          'expected_output': null,
          'language_id': null,
        });
      }
    }

    // 2️⃣ Insertion des quiz pratiques
    for (final entry in pratiqueQuizSeeds.entries) {
      final courseId = entry.key;
      final quizId = await _insertQuizSafe(courseId, 'Quiz pratique $courseId');

      if (quizId == -1) continue;

      for (final q in entry.value) {
        await db.insert('question', {
          'quiz_id': quizId,
          'text': q['text'],
          'option_a': null,
          'option_b': null,
          'option_c': null,
          'option_d': null,
          'correct_index': 0,
          'explanation': null,
          'difficulty': 'pratique',
          'code_snippet': q['code_snippet'],
          'expected_output': q['expected_output'],
          'language_id': q['language_id'],
        });
      }
    }

    print('✅ Seeds de quiz insérés avec succès.');
  }

  // =====================================================
  // 🔹 SEED PAR COURS (Déjà présent)
  // =====================================================
  @override
  Future<void> seedQuizWithQuestions(int courseId) async {
    final db = await _db;

    final course =
    await db.query('course', where: 'id = ?', whereArgs: [courseId]);
    if (course.isEmpty) {
      print('❌ seedQuizWithQuestions: cours $courseId inexistant.');
      return;
    }

    final existingQuiz =
    await db.query('quiz', where: 'course_id = ?', whereArgs: [courseId]);
    if (existingQuiz.isNotEmpty) {
      print('⚠️ seedQuizWithQuestions: quiz déjà présent pour le cours $courseId.');
      return;
    }

    final seed = quizSeeds[courseId];
    if (seed == null) {
      print('❌ Aucun seed pour le cours $courseId.');
      return;
    }

    final quizId = await db.insert('quiz', {
      'course_id': courseId,
      'title': seed['title'],
    });

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
}
