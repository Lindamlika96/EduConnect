class Review {
  final int userId;
  final int courseId;
  final int rating; // 1..5
  final String? comment;

  Review({
    required this.userId,
    required this.courseId,
    required this.rating,
    this.comment,
  });
}
