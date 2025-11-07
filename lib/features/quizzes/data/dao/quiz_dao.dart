// lib/features/quizzes/data/dao/quiz_dao.dart
import 'package:sqflite/sqflite.dart';

abstract class QuizDao {
  Future<List<Map<String, Object?>>> fetchQuizzes({int? courseId});
  Future<Map<String, Object?>?> fetchQuizById(int id);
  Future<List<Map<String, Object?>>> fetchQuestions(int quizId);

  // ✅ Ajouts requis
  Future<List<Map<String, Object?>>> fetchQuestionsByDifficulty(
    int quizId,
    String difficulty,
  );
  Future<List<Map<String, Object?>>> fetchMixedQuestions(int quizId);

  Future<int> insertQuiz(Map<String, Object?> quiz);
  Future<int> insertQuestion(Map<String, Object?> question);

  Future<int> insertResult({
    required int userId,
    required int quizId,
    required int score,
    required int total,
  });

  Future<void> seedQuizWithQuestions(int courseId);

  // ✅ Classement des scores
  Future<List<Map<String, Object?>>> topScores({int limit = 10});
}
