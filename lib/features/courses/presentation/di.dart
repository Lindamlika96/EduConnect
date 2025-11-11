// lib/features/courses/presentation/di.dart
import '../data/dao/course_dao.dart';
import '../domain/usecases/get_course_summary_usecase.dart';

class CoursesDI {
  final CourseDao dao;
  final GetCourseSummaryUseCase _summaryUseCase;

  CoursesDI._({
    required this.dao,
    required GetCourseSummaryUseCase summaryUseCase,
  }) : _summaryUseCase = summaryUseCase;

  static Future<CoursesDI> init() async {
    final dao = CourseDao();
    final summaryUseCase = await GetCourseSummaryUseCase.defaultInstance();
    return CoursesDI._(dao: dao, summaryUseCase: summaryUseCase);
  }

  GetCourseSummaryUseCase get getCourseSummaryUseCase => _summaryUseCase;
}
