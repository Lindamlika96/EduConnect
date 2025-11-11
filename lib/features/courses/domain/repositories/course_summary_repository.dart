// lib/features/courses/domain/repositories/course_summary_repository.dart
import '../entities/course_summary.dart';

abstract class CourseSummaryRepository {
  Future<CourseSummary> getSummary({
    required int courseId,
    required String lang, // ex: 'fr'
    required String pdfAssetPath, // ex: assets/pdfs/flutter_basics.pdf
    bool forceRefresh = false,
  });
}
