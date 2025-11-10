// lib/features/courses/data/repository/course_repository_impl.dart
import 'package:collection/collection.dart';

import '../../domain/entities/course.dart';
import '../../domain/repositories/course_repository.dart';
import '../dao/course_dao.dart';

class CourseRepositoryImpl implements CourseRepository {
  final CourseDao _dao;
  CourseRepositoryImpl(this._dao);

  Course _courseFromMap(Map<String, Object?> m) => Course(
    id: (m['id'] as num).toInt(),
    title: (m['title'] as String?) ?? '',
    level: (m['level'] as num?)?.toInt() ?? 1,
    language: (m['language'] as num?)?.toInt() ?? 0,
    durationMinutes: (m['duration_minutes'] as num?)?.toInt() ?? 0,
    ratingAvg: (m['rating_avg'] as num?)?.toDouble() ?? 0.0,
  );

  @override
  Future<List<Course>> getCourses({String? query, int? level, int? language}) async {
    final rows = await _dao.fetchCourses(q: query, level: level, language: language);
    return rows.map(_courseFromMap).toList();
  }

  @override
  Future<Course?> getCourseDetail(int id) async {
    final m = await _dao.fetchCourseById(id);
    if (m == null) return null;
    return _courseFromMap(m);
  }

  @override
  Future<void> toggleBookmark({required int userId, required int courseId}) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return _dao.toggleBookmark(userId: userId, courseId: courseId, nowMs: now);
  }

  @override
  Future<void> addReview({
    required int userId,
    required int courseId,
    required int rating,
    String? comment,
  }) {
    return _dao.addReview(
      userId: userId,
      courseId: courseId,
      rating: rating,
      comment: comment,
    );
  }

  @override
  Future<void> upsertProgress({
    required int userId,
    required int courseId,
    required double percent,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await _dao.upsertProgressMax(
      userId: userId,
      courseId: courseId,
      percent: percent,
      nowMs: now,
    );
  }
}