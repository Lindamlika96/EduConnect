import '../entities/review.dart';
import '../repositories/course_repository.dart';

class AddReviewUsecase {
  final CourseRepository repo;
  AddReviewUsecase(this.repo);

  Future<void> call(Review review) => repo.addReview(review);
}
