// lib/features/courses/data/models/course_summary_dto.dart
import 'dart:convert';
import '../../domain/entities/course_summary.dart';

class CourseSummaryDto {
  final int courseId;
  final String language;
  final String title;

  final String overview;
  final List<String> keyPoints;
  final List<String> nextSteps;

  final List<String> highlights;
  final List<String> outline;
  final List<String> keyTerms;

  final int readingTimeMin;
  final bool cacheHit;
  final int generatedAt;

  const CourseSummaryDto({
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

  factory CourseSummaryDto.fromDomain(CourseSummary d) => CourseSummaryDto(
    courseId: d.courseId,
    language: d.language,
    title: d.title,
    overview: d.overview,
    keyPoints: d.keyPoints,
    nextSteps: d.nextSteps,
    highlights: d.highlights,
    outline: d.outline,
    keyTerms: d.keyTerms,
    readingTimeMin: d.readingTimeMin,
    cacheHit: d.cacheHit,
    generatedAt: d.generatedAt,
  );

  CourseSummary toDomain() => CourseSummary(
    courseId: courseId,
    language: language,
    title: title,
    overview: overview,
    keyPoints: keyPoints,
    nextSteps: nextSteps,
    highlights: highlights,
    outline: outline,
    keyTerms: keyTerms,
    readingTimeMin: readingTimeMin,
    cacheHit: cacheHit,
    generatedAt: generatedAt,
  );

  Map<String, Object?> toMap() {
    return {
      'course_id': courseId,
      'language': language,
      'title': title,
      'overview': overview,
      'key_points': jsonEncode(keyPoints),
      'next_steps': jsonEncode(nextSteps),
      'highlights': jsonEncode(highlights),
      'outline': jsonEncode(outline),
      'key_terms': jsonEncode(keyTerms),
      'reading_time_min': readingTimeMin,
      'cache_hit': cacheHit ? 1 : 0,
      'generated_at': generatedAt,
    };
  }

  factory CourseSummaryDto.fromMap(Map<String, Object?> m) {
    List<String> _asList(dynamic v) {
      if (v == null) return const [];
      if (v is String) {
        final decoded = jsonDecode(v);
        if (decoded is List) {
          return decoded.map((e) => e.toString()).toList();
        }
      }
      if (v is List) return v.map((e) => e.toString()).toList();
      return const [];
    }

    return CourseSummaryDto(
      courseId: (m['course_id'] as num).toInt(),
      language: (m['language'] as String?) ?? 'fr',
      title: (m['title'] as String?) ?? '',
      overview: (m['overview'] as String?) ?? '',
      keyPoints: _asList(m['key_points']),
      nextSteps: _asList(m['next_steps']),
      highlights: _asList(m['highlights']),
      outline: _asList(m['outline']),
      keyTerms: _asList(m['key_terms']),
      readingTimeMin: (m['reading_time_min'] as num?)?.toInt() ?? 0,
      cacheHit: ((m['cache_hit'] as int?) ?? 0) == 1,
      generatedAt: (m['generated_at'] as num?)?.toInt() ??
          DateTime.now().millisecondsSinceEpoch,
    );
  }

  CourseSummaryDto copyWith({
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
    return CourseSummaryDto(
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
