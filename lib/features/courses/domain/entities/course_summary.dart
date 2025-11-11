// lib/features/courses/domain/entities/course_summary.dart
class CourseSummary {
  final int courseId;
  final String language; // 'fr' | 'en' ...
  final String title;

  // Bloc "résumé"
  final String overview;
  final List<String> keyPoints;
  final List<String> nextSteps;

  // Autres infos affichables
  final List<String> highlights;
  final List<String> outline;
  final List<String> keyTerms;

  final int readingTimeMin;
  final bool cacheHit;
  final int generatedAt; // epoch ms

  const CourseSummary({
    required this.courseId,
    required this.language,
    required this.title,
    required this.overview,
    required this.keyPoints,
    required this.nextSteps,
    required this.highlights,
    required this.outline,
    required this.keyTerms,
    required this.readingTimeMin,
    required this.cacheHit,
    required this.generatedAt,
  });

  CourseSummary copyWith({
    String? title,
    String? overview,
    List<String>? keyPoints,
    List<String>? nextSteps,
    List<String>? highlights,
    List<String>? outline,
    List<String>? keyTerms,
    int? readingTimeMin,
    bool? cacheHit,
    int? generatedAt,
  }) {
    return CourseSummary(
      courseId: courseId,
      language: language,
      title: title ?? this.title,
      overview: overview ?? this.overview,
      keyPoints: keyPoints ?? this.keyPoints,
      nextSteps: nextSteps ?? this.nextSteps,
      highlights: highlights ?? this.highlights,
      outline: outline ?? this.outline,
      keyTerms: keyTerms ?? this.keyTerms,
      readingTimeMin: readingTimeMin ?? this.readingTimeMin,
      cacheHit: cacheHit ?? this.cacheHit,
      generatedAt: generatedAt ?? this.generatedAt,
    );
  }
}
