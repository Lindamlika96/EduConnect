import '../repositories/participation_repository.dart';

class RemoveParticipationUseCase {
  final ParticipationRepository repository;
  RemoveParticipationUseCase(this.repository);

  Future<int> call({
    required int evenementId,
    required int userId,
  }) =>
      repository.remove(evenementId: evenementId, userId: userId);
}
