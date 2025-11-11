import '../entities/participation_entity.dart';
import '../repositories/participation_repository.dart';

class GetParticipationStatusUseCase {
  final ParticipationRepository repository;
  GetParticipationStatusUseCase(this.repository);

  Future<ParticipationEntity?> call({
    required int evenementId,
    required int userId,
  }) =>
      repository.getStatus(evenementId: evenementId, userId: userId);
}
