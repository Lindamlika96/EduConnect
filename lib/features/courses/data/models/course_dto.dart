/// DTO mappé directement sur la table `course`.
class CourseDto {
  final int id;
  final int mentorId;
  final String title;
  final String descriptionHtml;
  final int level;
  final int language;
  final int durationMinutes;
  final double ratingAvg;
  final int ratingCount;

  CourseDto({
    required this.id,
    required this.mentorId,
    required this.title,
    required this.descriptionHtml,
    required this.level,
    required this.language,
    required this.durationMinutes,
    required this.ratingAvg,
    required this.ratingCount,
  });

  factory CourseDto.fromMap(Map<String, Object?> m) => CourseDto(
    id: (m['id'] as int),
    mentorId: (m['mentor_id'] as int),
    title: (m['title'] as String),
    descriptionHtml: (m['description_html'] as String? ?? ''),
    level: (m['level'] as int? ?? 1),
    language: (m['language'] as int? ?? 0),
    durationMinutes: (m['duration_minutes'] as int? ?? 0),
    ratingAvg: (m['rating_avg'] as num? ?? 0.0).toDouble(),
    ratingCount: (m['rating_count'] as int? ?? 0),
  );

  Map<String, Object?> toMap() => {
    'id': id,
    'mentor_id': mentorId,
    'title': title,
    'description_html': descriptionHtml,
    'level': level,
    'language': language,
    'duration_minutes': durationMinutes,
    'rating_avg': ratingAvg,
    'rating_count': ratingCount,
  };
}
