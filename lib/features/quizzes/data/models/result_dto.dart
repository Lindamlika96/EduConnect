/// DTO mappé directement sur la table `result`.
class ResultDto {
  final int id;
  final int quizId;
  final int userId;
  final int score;
  final int total;
  final String date;

  ResultDto({
    required this.id,
    required this.quizId,
    required this.userId,
    required this.score,
    required this.total,
    required this.date,
  });

  factory ResultDto.fromMap(Map<String, Object?> m) => ResultDto(
    id: m['id'] as int,
    quizId: m['quiz_id'] as int,
    userId: m['user_id'] as int,
    score: m['score'] as int,
    total: m['total'] as int,
    date: m['date'] as String,
  );

  Map<String, Object?> toMap() => {
    'id': id,
    'quiz_id': quizId,
    'user_id': userId,
    'score': score,
    'total': total,
    'date': date,
  };
}
