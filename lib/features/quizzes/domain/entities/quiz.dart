class Quiz {
  final int id;
  final int courseId;
  final String title;

  Quiz({required this.id, required this.courseId, required this.title});

  factory Quiz.fromMap(Map<String, Object?> m) => Quiz(
    id: m['id'] as int,
    courseId: m['course_id'] as int,
    title: m['title'] as String,
  );
}
