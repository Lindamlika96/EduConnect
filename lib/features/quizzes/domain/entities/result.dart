class Result {
  final int id;
  final int quizId;
  final int userId;
  final int score;
  final int total;
  final String date;

  Result({
    required this.id,
    required this.quizId,
    required this.userId,
    required this.score,
    required this.total,
    required this.date,
  });

  factory Result.fromMap(Map<String, Object?> m) => Result(
    id: m['id'] as int,
    quizId: m['quiz_id'] as int,
    userId: m['user_id'] as int,
    score: m['score'] as int,
    total: m['total'] as int,
    date: m['date'] as String,
  );
}
