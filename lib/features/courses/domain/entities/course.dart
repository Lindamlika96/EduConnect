/// Entité métier (pas de JSON/sql ici).
class Course {
  final int id;
  final String title;
  final int level;
  final int language;
  final int durationMinutes;
  final double ratingAvg;

  Course({
    required this.id,
    required this.title,
    required this.level,
    required this.language,
    required this.durationMinutes,
    required this.ratingAvg,
  });
}
