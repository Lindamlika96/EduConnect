import '../../domain/entities/participation_entity.dart';

class ParticipationTable {
  static const table = 'evenement_participation';
  static const evenementId = 'evenement_id';
  static const userId = 'user_id';
  static const status = 'status';
}

class ParticipationDto {
  final int evenementId;
  final int userId;
  final String status;

  const ParticipationDto({
    required this.evenementId,
    required this.userId,
    required this.status,
  });

  Map<String, Object?> toMap() => {
    ParticipationTable.evenementId: evenementId,
    ParticipationTable.userId: userId,
    ParticipationTable.status: status,
  };

  factory ParticipationDto.fromMap(Map<String, Object?> map) => ParticipationDto(
    evenementId: map[ParticipationTable.evenementId] as int,
    userId: map[ParticipationTable.userId] as int,
    status: map[ParticipationTable.status] as String,
  );

  ParticipationEntity toEntity() => ParticipationEntity(
    evenementId: evenementId,
    userId: userId,
    status: status,
  );

  factory ParticipationDto.fromEntity(ParticipationEntity e) => ParticipationDto(
    evenementId: e.evenementId,
    userId: e.userId,
    status: e.status,
  );
}
