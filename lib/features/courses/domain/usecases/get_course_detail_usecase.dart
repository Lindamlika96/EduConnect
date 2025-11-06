import '../entities/course.dart';
import '../repositories/course_repository.dart';

class GetCourseDetailUsecase {
  final CourseRepository repo;
  GetCourseDetailUsecase(this.repo);

  Future<Course?> call(int id) => repo.getCourseDetail(id);
}
