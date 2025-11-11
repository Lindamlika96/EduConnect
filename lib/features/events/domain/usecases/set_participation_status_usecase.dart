import '../repositories/participation_repository.dart';

class SetParticipationStatusUseCase {
  final ParticipationRepository repository;
  SetParticipationStatusUseCase(this.repository);

  Future<void> call({
    required int evenementId,
    required int userId,
    required String status,
  }) =>
      repository.setStatus(evenementId: evenementId, userId: userId, status: status);
}
