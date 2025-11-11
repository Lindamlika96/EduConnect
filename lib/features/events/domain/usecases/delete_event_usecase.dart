import '../repositories/event_repository.dart';

class DeleteEventUseCase {
  final EventRepository repository;
  DeleteEventUseCase(this.repository);

  Future<int> call(int idEvenement) {
    return repository.delete(idEvenement);
  }
}
