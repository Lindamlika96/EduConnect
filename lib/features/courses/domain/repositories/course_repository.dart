import '../entities/course.dart';
import '../entities/review.dart';

abstract class CourseRepository {
  Future<List<Course>> getCourses({String? query, int? level, int? language});
  Future<Course?> getCourseDetail(int id);
  Future<void> toggleBookmark({required int userId, required int courseId});
  Future<void> addReview(Review review);
  Future<void> updateProgress({required int userId, required int courseId, required double percent});
}
