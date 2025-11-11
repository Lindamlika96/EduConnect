import '../../domain/entities/participation_entity.dart';
import '../../domain/repositories/participation_repository.dart';
import '../dao/participation_dao.dart';

class ParticipationRepositoryImpl implements ParticipationRepository {
  final ParticipationDao dao;
  ParticipationRepositoryImpl(this.dao);

  @override
  Future<void> setStatus({
    required int evenementId,
    required int userId,
    required String status,
  }) =>
      dao.setStatus(evenementId: evenementId, userId: userId, status: status);

  @override
  Future<ParticipationEntity?> getStatus({
    required int evenementId,
    required int userId,
  }) async {
    final dto = await dao.getStatus(evenementId: evenementId, userId: userId);
    return dto?.toEntity();
  }

  @override
  Future<List<int>> getEventIdsByStatus({
    required int userId,
    required String status,
  }) =>
      dao.getEventIdsByStatus(userId: userId, status: status);

  @override
  Future<int> remove({
    required int evenementId,
    required int userId,
  }) =>
      dao.remove(evenementId: evenementId, userId: userId);

  @override
  Future<int> countByStatus({
    required int evenementId,
    required String status,
  }) =>
      dao.countByStatus(evenementId: evenementId, status: status);
}
