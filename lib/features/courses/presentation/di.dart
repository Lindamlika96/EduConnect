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

  CoursesDI._();

  static Future<CoursesDI> init() async {
    final di = CoursesDI._();

    final dbFuture = AppDatabase.database; // Future<Database>
    di.dao  = CourseDaoImpl(dbFuture);
    di.repo = CourseRepositoryImpl(di.dao);

    di.getCourses       = GetCoursesUsecase(di.repo);
    di.getCourseDetail  = GetCourseDetailUsecase(di.repo);
    di.toggleBookmark   = ToggleBookmarkUsecase(di.repo);
    di.addReview        = AddReviewUsecase(di.repo);
    di.updateProgress   = UpdateProgressUsecase(di.repo);

    // ---- Seed auto : 5 cours si la table est vide ----
    final now = DateTime.now().millisecondsSinceEpoch;
    await di.dao.seedIfEmpty([
      {
        'mentor_id': 1,
        'title': 'Algo – Notions de base',
        'description_html': '<p>Intro algo</p>',
        'level': 1, 'language': 0, 'duration_minutes': 45,
        'pdf_path': 'assets/pdfs/algo.pdf',
        'thumbnail_path': null,
        'rating_avg': 4.3, 'rating_count': 120, 'students_count': 180,
        'summary_text': null, 'created_at': now, 'updated_at': now
      },
      {
        'mentor_id': 2,
        'title': 'Flutter – Démarrage',
        'description_html': '<p>Widgets, State, Routing</p>',
        'level': 1, 'language': 0, 'duration_minutes': 60,
        'pdf_path': 'assets/pdfs/flutter_basics.pdf',
        'thumbnail_path': null,
        'rating_avg': 4.5, 'rating_count': 95, 'students_count': 210,
        'summary_text': null, 'created_at': now-1, 'updated_at': now-1
      },
      {
        'mentor_id': 2,
        'title': 'Bases de données SQL',
        'description_html': '<p>Tables, clés, JOIN</p>',
        'level': 1, 'language': 0, 'duration_minutes': 50,
        'pdf_path': 'assets/pdfs/sql.pdf',
        'thumbnail_path': null,
        'rating_avg': 4.2, 'rating_count': 80, 'students_count': 170,
        'summary_text': null, 'created_at': now-2, 'updated_at': now-2
      },
      {
        'mentor_id': 3,
        'title': 'Réseaux – Concepts',
        'description_html': '<p>OSI, TCP/IP</p>',
        'level': 1, 'language': 0, 'duration_minutes': 40,
        'pdf_path': 'assets/pdfs/networks.pdf',
        'thumbnail_path': null,
        'rating_avg': 4.1, 'rating_count': 60, 'students_count': 130,
        'summary_text': null, 'created_at': now-3, 'updated_at': now-3
      },
      {
        'mentor_id': 4,
        'title': 'IA – Introduction',
        'description_html': '<p>ML vs DL</p>',
        'level': 1, 'language': 0, 'duration_minutes': 55,
        'pdf_path': 'assets/pdfs/ml_intro.pdf',
        'thumbnail_path': null,
        'rating_avg': 4.4, 'rating_count': 110, 'students_count': 190,
        'summary_text': null, 'created_at': now-4, 'updated_at': now-4
      },
    ]);
    // -----------------------------------------------

    return di;
  }
}
