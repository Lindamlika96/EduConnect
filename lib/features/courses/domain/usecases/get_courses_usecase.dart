import '../entities/course.dart';
import '../repositories/course_repository.dart';

class GetCoursesUsecase {
  final CourseRepository repo;
  GetCoursesUsecase(this.repo);

  Future<List<Course>> call({String? query, int? level, int? language}) {
    return repo.getCourses(query: query, level: level, language: language);
  }
}
