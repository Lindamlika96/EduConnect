// lib/features/courses/data/repository/course_summary_repository_impl.dart
import '../../domain/entities/course_summary.dart';
import '../dao/course_summary_dao.dart';
import '../models/course_summary_dto.dart';
import '../../presentation/services/gemini_summary_service.dart';

class CourseSummaryRepository {
  final CourseSummaryDao _dao;
  final GeminiSummaryService _service;

  CourseSummaryRepository({
    required CourseSummaryDao dao,
    required GeminiSummaryService service,
  })  : _dao = dao,
        _service = service;

  /// Retourne un CourseSummary (Domain).
  /// Si `forceRefresh` = false, tente le cache SQLite d’abord.
  Future<CourseSummary> getOrCreateSummary({
    required int courseId,
    required String language,
    required String assetPdfPath,
    bool forceRefresh = false,
  }) async {
    await _dao.ensureTable();

    if (!forceRefresh) {
      final cached = await _dao.getByCourseIdLanguage(
        courseId: courseId,
        language: language,
      );
      if (cached != null) {
        return cached.toDomain().copyWith(cacheHit: true);
      }
    }

    final generated = await _service.summarizeAsset(
      courseId: courseId,
      language: language,
      assetPath: assetPdfPath,
    );

    final dto = CourseSummaryDto.fromDomain(generated.copyWith(cacheHit: false));
    await _dao.upsert(dto);

    return dto.toDomain();
  }
}
