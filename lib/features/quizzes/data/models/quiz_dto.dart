/// DTO mappé directement sur la table `quiz`.
class QuizDto {
  final int id;
  final int courseId;
  final String title;

  QuizDto({required this.id, required this.courseId, required this.title});

  factory QuizDto.fromMap(Map<String, Object?> m) => QuizDto(
    id: m['id'] as int,
    courseId: m['course_id'] as int,
    title: m['title'] as String,
  );

  Map<String, Object?> toMap() => {
    'id': id,
    'course_id': courseId,
    'title': title,
  };
}
