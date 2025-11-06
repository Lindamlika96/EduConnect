import 'package:sqflite/sqflite.dart';
import '../../../core/db/app_database.dart';
import '../data/dao/course_dao.dart';
import '../data/repository/course_repository_impl.dart';
import '../domain/repositories/course_repository.dart';
import '../domain/usecases/add_review_usecase.dart';
import '../domain/usecases/get_course_detail_usecase.dart';
import '../domain/usecases/get_courses_usecase.dart';
import '../domain/usecases/toggle_bookmark_usecase.dart';
import '../domain/usecases/update_progress_usecase.dart';

/// Gestion centralisée des dépendances de la feature "Courses"
class CoursesDI {
  late final CourseDao dao;
  late final CourseRepository repo;
  late final GetCoursesUsecase getCourses;
  late final GetCourseDetailUsecase getCourseDetail;
  late final ToggleBookmarkUsecase toggleBookmark;
  late final AddReviewUsecase addReview;
  late final UpdateProgressUsecase updateProgress;

  CoursesDI._(); // constructeur privé

  /// Initialise toutes les dépendances nécessaires à la feature Cours
  static Future<CoursesDI> init() async {
    final di = CoursesDI._();

    final Future<Database> dbFuture = AppDatabase.database;

    di.dao = CourseDaoImpl(dbFuture);         // OK: le ctor attend Future<Database>
    di.repo = CourseRepositoryImpl(di.dao);

    di.getCourses = GetCoursesUsecase(di.repo);
    di.getCourseDetail = GetCourseDetailUsecase(di.repo);
    di.toggleBookmark = ToggleBookmarkUsecase(di.repo);
    di.addReview = AddReviewUsecase(di.repo);
    di.updateProgress = UpdateProgressUsecase(di.repo);

    return di;
  }
}
