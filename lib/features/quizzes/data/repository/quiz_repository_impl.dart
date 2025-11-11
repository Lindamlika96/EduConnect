import '../../domain/entities/quiz.dart';
import '../../domain/entities/question.dart';
import '../../domain/entities/result.dart';
import '../../domain/repositories/quiz_repository.dart';
import '../dao/quiz_dao.dart';

class QuizRepositoryImpl implements QuizRepository {
  final QuizDao dao;
  QuizRepositoryImpl(this.dao);

  @override
  Future<List<Quiz>> getQuizzes(int courseId) async {
    final rows = await dao.fetchQuizzes(courseId: courseId);
    return rows.map((m) => Quiz.fromMap(m)).toList();
  }

  @override
  Future<List<Question>> getQuestions(int quizId) async {
    final rows = await dao.fetchQuestions(quizId);
    return rows.map((m) => Question.fromMap(m)).toList();
  }

  @override
  Future<List<Question>> getQuestionsByDifficulty(
    int quizId,
    String difficulty,
  ) async {
    final rows = await dao.fetchQuestionsByDifficulty(quizId, difficulty);
    return rows.map((m) => Question.fromMap(m)).toList();
  }

  @override
  Future<List<Question>> getMixedQuestions(int quizId) async {
    final rows = await dao.fetchMixedQuestions(quizId);
    return rows.map((m) => Question.fromMap(m)).toList();
  }

  @override
  Future<void> submitResult(Result result) async {
    await dao.insertResult(
      userId: result.userId,
      quizId: result.quizId,
      score: result.score,
      total: result.total,
    );
  }

  @override
  Future<List<Result>> topScores({int limit = 10}) async {
    final rows = await dao.topScores(limit: limit);
    return rows.map((m) => Result.fromMap(m)).toList();
  }
}
