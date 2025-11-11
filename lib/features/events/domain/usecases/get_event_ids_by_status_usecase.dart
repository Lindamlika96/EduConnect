import '../repositories/participation_repository.dart';

class GetEventIdsByStatusUseCase {
  final ParticipationRepository repository;
  GetEventIdsByStatusUseCase(this.repository);

  Future<List<int>> call({
    required int userId,
    required String status,
  }) =>
      repository.getEventIdsByStatus(userId: userId, status: status);
}
