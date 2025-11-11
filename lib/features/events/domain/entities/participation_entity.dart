/// Représente une ligne de la table `evenement_participation`.
/// Clé primaire composite: (evenement_id, user_id)
class ParticipationEntity {
  final int evenementId;
  final int userId;

  /// Valeurs admises par la DB:
  /// 'participe', 'favori', 'ne participe pas'
  final String status;

  const ParticipationEntity({
    required this.evenementId,
    required this.userId,
    required this.status,
  });

  ParticipationEntity copyWith({
    int? evenementId,
    int? userId,
    String? status,
  }) {
    return ParticipationEntity(
      evenementId: evenementId ?? this.evenementId,
      userId: userId ?? this.userId,
      status: status ?? this.status,
    );
  }
}

/// Constantes pour éviter les fautes de frappe.
class ParticipationStatus {
  static const participe = 'participe';
  static const favori = 'favori';
  static const neParticipePas = 'ne participe pas';

  static const values = [participe, favori, neParticipePas];
}
