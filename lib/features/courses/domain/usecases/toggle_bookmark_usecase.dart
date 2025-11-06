import '../repositories/course_repository.dart';

class ToggleBookmarkUsecase {
  final CourseRepository repo;
  ToggleBookmarkUsecase(this.repo);

  Future<void> call({required int userId, required int courseId}) {
    return repo.toggleBookmark(userId: userId, courseId: courseId);
  }
}
