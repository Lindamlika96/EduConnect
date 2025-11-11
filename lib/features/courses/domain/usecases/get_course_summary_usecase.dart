// lib/features/courses/domain/usecases/get_course_summary_usecase.dart
import '../../domain/entities/course_summary.dart';
import '../../data/dao/course_summary_dao.dart';
import '../../data/repository/course_summary_repository_impl.dart';
import '../../presentation/services/gemini_summary_service.dart';

class GetCourseSummaryUseCase {
  final CourseSummaryRepository _repo;

  GetCourseSummaryUseCase(this._repo);

  static Future<GetCourseSummaryUseCase> defaultInstance() async {
    final dao = CourseSummaryDao();
    final service = await GeminiSummaryService.defaultInstance();
    final repo = CourseSummaryRepository(dao: dao, service: service);
    return GetCourseSummaryUseCase(repo);
  }

  Future<CourseSummary> call({
    required int courseId,
    required String language,
    required String assetPdfPath,
    bool forceRefresh = false,
  }) {
    return _repo.getOrCreateSummary(
      courseId: courseId,
      language: language,
      assetPdfPath: assetPdfPath,
      forceRefresh: forceRefresh,
    );
  }
}
