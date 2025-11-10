import '../entities/course.dart';

abstract class CourseRepository {
  Future<List<Course>> getCourses({String? query, int? level, int? language});
  Future<Course?> getCourseDetail(int id);

  Future<void> toggleBookmark({
    required int userId,
    required int courseId,
  });

  Future<void> addReview({
    required int userId,
    required int courseId,
    required int rating,
    String? comment,
  });

  Future<void> upsertProgress({
    required int userId,
    required int courseId,
    required double percent,
  });
}
