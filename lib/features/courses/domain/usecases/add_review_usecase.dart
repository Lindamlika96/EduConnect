import '../repositories/course_repository.dart';

class AddReviewUsecase {
  final CourseRepository repo;
  AddReviewUsecase(this.repo);

  /// Enregistre un avis (note obligatoire, commentaire optionnel)
  Future<void> call({
    required int userId,
    required int courseId,
    required int rating,
    String? comment,
  }) {
    return repo.addReview(
      userId: userId,
      courseId: courseId,
      rating: rating,
      comment: comment,
    );
  }
}
