import '../entities/event_entity.dart';
import '../repositories/event_repository.dart';

class AddEventUseCase {
  final EventRepository repository;
  AddEventUseCase(this.repository);

  Future<int> call(EventEntity event) {
    return repository.add(event);
  }
}
