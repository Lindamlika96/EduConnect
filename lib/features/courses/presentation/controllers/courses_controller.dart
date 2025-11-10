// lib/features/courses/presentation/controllers/courses_controller.dart
import 'package:flutter/foundation.dart';

import '../../data/dao/course_dao.dart';
import '../../domain/entities/course.dart';
import '../di.dart';

class CourseWithProgressVM {
  final Course course;
  final double progressPercent;
  final int updatedAt;
  final bool isBookmarked;

  CourseWithProgressVM({
    required this.course,
    required this.progressPercent,
    required this.updatedAt,
    required this.isBookmarked,
  });
}

class CoursesState {
  bool isLoading = false;
  List<Course> all = [];
  List<CourseWithProgressVM> myCompleted = [];
  List<CourseWithProgressVM> myOngoing = [];
  List<Course> bookmarks = [];
}

class CoursesController extends ChangeNotifier {
  final CoursesDI _di;
  CoursesController._(this._di);
  static Future<CoursesController> init() async {
    final di = await CoursesDI.init();
    // sème des données si besoin
    await di.dao.ensureSeed();
    return CoursesController._(di);
  }

  final state = CoursesState();
  CourseDao get _dao => _di.dao;

  Course _courseFromMap(Map<String, Object?> m) => Course(
    id: (m['id'] as num).toInt(),
    title: (m['title'] as String?) ?? '',
    level: (m['level'] as num?)?.toInt() ?? 1,
    language: (m['language'] as num?)?.toInt() ?? 0,
    durationMinutes: (m['duration_minutes'] as num?)?.toInt() ?? 0,
    ratingAvg: (m['rating_avg'] as num?)?.toDouble() ?? 0.0,
  );

  bool _isBookmarked(Map<String, Object?> m) =>
      ((m['is_bookmarked'] as int?) ?? 0) == 1;

  int _courseIdOf(Map<String, Object?> m) {
    final v = m['course_id'] ?? m['id'];
    return (v as num).toInt();
  }

  // LISTES
  Future<void> loadAll({String? query, int? level, int? language}) async {
    state.isLoading = true;
    notifyListeners();
    try {
      final rows = await _dao.fetchCourses(q: query, level: level, language: language);
      state.all = rows.map(_courseFromMap).toList();
    } finally {
      state.isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMyCoursesCompleted(int userId) async {
    state.isLoading = true;
    notifyListeners();
    try {
      final rows = await _dao.getMyCoursesCompleted(userId);
      state.myCompleted = rows
          .map((m) => CourseWithProgressVM(
        course: _courseFromMap(m),
        progressPercent: (m['progress_percent'] as num?)?.toDouble() ?? 0.0,
        updatedAt: (m['updated_at'] as num?)?.toInt() ?? 0,
        isBookmarked: _isBookmarked(m),
      ))
          .toList();
    } finally {
      state.isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMyCoursesOngoing(int userId) async {
    state.isLoading = true;
    notifyListeners();
    try {
      final rows = await _dao.getMyCoursesOngoing(userId);
      state.myOngoing = rows
          .map((m) => CourseWithProgressVM(
        course: _courseFromMap(m),
        progressPercent: (m['progress_percent'] as num?)?.toDouble() ?? 0.0,
        updatedAt: (m['updated_at'] as num?)?.toInt() ?? 0,
        isBookmarked: _isBookmarked(m),
      ))
          .toList();
    } finally {
      state.isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadBookmarks(int userId) async {
    state.isLoading = true;
    notifyListeners();
    try {
      state.bookmarks = await _dao.getBookmarks(userId);
    } finally {
      state.isLoading = false;
      notifyListeners();
    }
  }

  // DETAIL (Map pour ta detail page)
  Future<Map<String, Object?>?> fetchCourseById(int id) => _dao.fetchCourseById(id);

  // FAVORIS
  Future<void> toggleBookmark(int userId, int courseId) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await _dao.toggleBookmark(userId: userId, courseId: courseId, nowMs: now);

    await loadBookmarks(userId);
    final bookmarkedIds = state.bookmarks.map((c) => c.id).toSet();

    state.myCompleted = state.myCompleted
        .map((vm) => CourseWithProgressVM(
      course: vm.course,
      progressPercent: vm.progressPercent,
      updatedAt: vm.updatedAt,
      isBookmarked: bookmarkedIds.contains(vm.course.id),
    ))
        .toList();

    state.myOngoing = state.myOngoing
        .map((vm) => CourseWithProgressVM(
      course: vm.course,
      progressPercent: vm.progressPercent,
      updatedAt: vm.updatedAt,
      isBookmarked: bookmarkedIds.contains(vm.course.id),
    ))
        .toList();

    notifyListeners();
  }

  // REVIEWS rapides
  Future<void> addQuickRating({
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

  // PROGRESSION
  Future<void> startCourseIfNeeded(int userId, int courseId) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await _dao.enrollIfNeeded(userId: userId, courseId: courseId, nowMs: now);
  }

  Future<void> updateProgressMax(int userId, int courseId, double percent) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await _dao.upsertProgressMax(
      userId: userId,
      courseId: courseId,
      percent: percent,
      nowMs: now,
    );
  }

  Future<double> getUserProgress(int userId, int courseId) async {
    final completed = await _dao.getMyCoursesCompleted(userId);
    for (final m in completed) {
      if (_courseIdOf(m) == courseId) return 100.0;
    }
    final ongoing = await _dao.getMyCoursesOngoing(userId);
    for (final m in ongoing) {
      if (_courseIdOf(m) == courseId) {
        return (m['progress_percent'] as num?)?.toDouble() ?? 0.0;
      }
    }
    return 0.0;
  }

  // Compat
  Future<List<Map<String, Object?>>> listAll({String? q}) => _dao.fetchCourses(q: q);
  Future<List<Map<String, Object?>>> listMine(int userId) async {
    final ongoing = await _dao.getMyCoursesOngoing(userId);
    final completed = await _dao.getMyCoursesCompleted(userId);
    return [...ongoing, ...completed];
  }

  Future<double> readProgress({required int userId, required int courseId}) =>
      getUserProgress(userId, courseId);
}