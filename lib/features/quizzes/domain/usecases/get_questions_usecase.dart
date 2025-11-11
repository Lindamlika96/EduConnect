import '../entities/question.dart';
import '../repositories/quiz_repository.dart';

class GetQuestionsUseCase {
  final QuizRepository repository;
  GetQuestionsUseCase(this.repository);

  /// Récupère toutes les questions d’un quiz
  Future<List<Question>> call(int quizId) {
    return repository.getQuestions(quizId);
  }

  /// Récupère les questions d’un quiz filtrées par difficulté
  Future<List<Question>> getByDifficulty(int quizId, String currentDifficulty) {
    return repository.getQuestionsByDifficulty(quizId, currentDifficulty);
  }

  /// Récupère un mélange de questions (par ex. toutes difficultés confondues)
  Future<List<Question>> getMixed(int quizId) {
    return repository.getMixedQuestions(quizId);
  }
}
