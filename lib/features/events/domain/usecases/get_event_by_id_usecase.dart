import '../entities/event_entity.dart';
import '../repositories/event_repository.dart';

class GetEventByIdUseCase {
  final EventRepository repository;
  GetEventByIdUseCase(this.repository);

  Future<EventEntity?> call(int idEvenement) {
    return repository.getById(idEvenement);
  }
}
