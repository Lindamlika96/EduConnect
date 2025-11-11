import '../entities/participation_entity.dart';

abstract class ParticipationRepository {
  /// Upsert: crée ou met à jour le statut d’un user pour un événement.
  Future<void> setStatus({
    required int evenementId,
    required int userId,
    required String status, // doit être dans ParticipationStatus.values
  });

  /// Récupère le statut d’un user pour un événement (ou null).
  Future<ParticipationEntity?> getStatus({
    required int evenementId,
    required int userId,
  });

  /// Liste des événements d’un user selon un statut (ids d’événements).
  Future<List<int>> getEventIdsByStatus({
    required int userId,
    required String status,
  });

  /// Supprime l’entrée (quel que soit le statut). Retourne nb lignes supprimées.
  Future<int> remove({
    required int evenementId,
    required int userId,
  });

  /// Compter par statut pour un événement (utile pour les badges).
  Future<int> countByStatus({
    required int evenementId,
    required String status,
  });
}
