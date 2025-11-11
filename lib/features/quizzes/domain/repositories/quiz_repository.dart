import '../entities/quiz.dart';
import '../entities/question.dart';
import '../entities/result.dart';

abstract class QuizRepository {
  /// Récupère tous les quiz d’un cours
  Future<List<Quiz>> getQuizzes(int courseId);

  /// Récupère toutes les questions d’un quiz
  Future<List<Question>> getQuestions(int quizId);

  /// Récupère les questions filtrées par difficulté
  Future<List<Question>> getQuestionsByDifficulty(
    int quizId,
    String difficulty,
  );

  /// Récupère un mélange de questions (toutes difficultés confondues)
  Future<List<Question>> getMixedQuestions(int quizId);

  /// Enregistre un résultat
  Future<void> submitResult(Result result);

  /// Récupère le classement des meilleurs scores
  Future<List<Result>> topScores({int limit = 10});
}
