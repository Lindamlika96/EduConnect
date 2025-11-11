import '../entities/event_entity.dart';

/// Contrat côté domaine pour manipuler les événements.
abstract class EventRepository {
  Future<List<EventEntity>> getAll({String? search});
  Future<EventEntity?> getById(int idEvenement);
  Future<int> add(EventEntity event);       // retourne l'id inséré
  Future<int> update(EventEntity event);    // nb de lignes affectées
  Future<int> delete(int idEvenement);      // nb de lignes affectées
}
