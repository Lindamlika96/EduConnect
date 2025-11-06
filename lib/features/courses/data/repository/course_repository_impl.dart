import '../../domain/entities/course.dart';
import '../../domain/entities/review.dart';
import '../../domain/repositories/course_repository.dart';
import '../dao/course_dao.dart';
import '../models/course_dto.dart';

class CourseRepositoryImpl implements CourseRepository {
  final CourseDao dao;
  CourseRepositoryImpl(this.dao);

  @override
  Future<List<Course>> getCourses({String? query, int? level, int? language}) async {
    final rows = await dao.fetchCourses(q: query, level: level, language: language);
    return rows.map((m) {
      final dto = CourseDto.fromMap(m);
      return Course(
        id: dto.id,
        title: dto.title,
        level: dto.level,
        language: dto.language,
        durationMinutes: dto.durationMinutes,
        ratingAvg: dto.ratingAvg,
      );
    }).toList();
  }

  @override
  Future<Course?> getCourseDetail(int id) async {
    final m = await dao.fetchCourseById(id);
    if (m == null) return null;
    final dto = CourseDto.fromMap(m);
    return Course(
      id: dto.id,
      title: dto.title,
      level: dto.level,
      language: dto.language,
      durationMinutes: dto.durationMinutes,
      ratingAvg: dto.ratingAvg,
    );
  }

  @override
  Future<void> toggleBookmark({required int userId, required int courseId}) async {
    await dao.toggleBookmark(userId: userId, courseId: courseId);
  }

  @override
  Future<void> addReview(Review review) async {
    await dao.addReview(
      userId: review.userId,
      courseId: review.courseId,
      rating: review.rating,
      comment: review.comment,
    );
  }

  @override
  Future<void> updateProgress({required int userId, required int courseId, required double percent}) async {
    await dao.upsertProgress(userId: userId, courseId: courseId, percent: percent);
  }
}
