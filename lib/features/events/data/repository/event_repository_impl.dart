import '../../domain/entities/event_entity.dart';
import '../../domain/repositories/event_repository.dart';
import '../dao/event_dao.dart';
import '../models/event_dto.dart';

class EventRepositoryImpl implements EventRepository {
  final EventDao dao;
  EventRepositoryImpl(this.dao);

  @override
  Future<List<EventEntity>> getAll({String? search}) async {
    final dtos = await dao.getAll(search: search);
    return dtos.map((d) => d.toEntity()).toList();
  }

  @override
  Future<EventEntity?> getById(int idEvenement) async {
    final dto = await dao.getById(idEvenement);
    return dto?.toEntity();
  }

  @override
  Future<int> add(EventEntity event) async {
    final id = await dao.insert(EventDto.fromEntity(event));
    return id;
  }

  @override
  Future<int> update(EventEntity event) async {
    return await dao.update(EventDto.fromEntity(event));
  }

  @override
  Future<int> delete(int idEvenement) async {
    return await dao.delete(idEvenement);
  }
}
