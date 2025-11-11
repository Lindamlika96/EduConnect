import '../entities/result.dart';
import '../repositories/quiz_repository.dart';

class SubmitResultUseCase {
  final QuizRepository repository;
  SubmitResultUseCase(this.repository);

  Future<void> call(Result result) {
    return repository.submitResult(result);
  }
}
