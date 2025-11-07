import '../entities/quiz.dart';
import '../repositories/quiz_repository.dart';

class GetQuizUseCase {
  final QuizRepository repository;
  GetQuizUseCase(this.repository);

  Future<List<Quiz>> call(int courseId) {
    return repository.getQuizzes(courseId);
  }
}
