import '../entities/event_entity.dart';
import '../repositories/event_repository.dart';

class UpdateEventUseCase {
  final EventRepository repository;
  UpdateEventUseCase(this.repository);

  Future<int> call(EventEntity event) {
    return repository.update(event);
  }
}
