import '../repositories/course_repository.dart';

class UpdateProgressUsecase {
  final CourseRepository repo;
  UpdateProgressUsecase(this.repo);

  Future<void> call({required int userId, required int courseId, required double percent}) {
    return repo.updateProgress(userId: userId, courseId: courseId, percent: percent);
  }
}
