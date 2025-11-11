import '../../domain/entities/event_entity.dart';

/// Constantes de colonnes EXACTEMENT comme dans la table SQLite `events`.
class EventTable {
  static const table = 'events';
  static const id = 'id_evenement';
  static const titre = 'titre';
  static const description = 'description';
  static const localisation = 'localisation';
  static const date = 'date';
  static const dureeJours = 'duree_jours';
  static const nombrePlaces = 'nombre_places';
  static const niveauImportance = 'niveau_importance';
  static const niveauExigeance = 'niveau_exigeance';
  static const formateur = 'formateur';
}

/// DTO = représentation "persistence" 1:1 avec la table `events`.
class EventDto {
  final int? idEvenement; // correspond à id_evenement (PK AUTOINCREMENT)
  final String titre;
  final String? description;
  final String localisation;
  final String date; // stocké TEXT en DB
  final int dureeJours;
  final int nombrePlaces;
  final String niveauImportance;
  final String niveauExigeance;
  final String formateur;

  const EventDto({
    this.idEvenement,
    required this.titre,
    this.description,
    required this.localisation,
    required this.date,
    required this.dureeJours,
    required this.nombrePlaces,
    required this.niveauImportance,
    required this.niveauExigeance,
    required this.formateur,
  });

  /// Map -> DTO (depuis SQLite)
  factory EventDto.fromMap(Map<String, Object?> map) => EventDto(
    idEvenement: map[EventTable.id] as int?,
    titre: map[EventTable.titre] as String,
    description: map[EventTable.description] as String?,
    localisation: map[EventTable.localisation] as String,
    date: map[EventTable.date] as String,
    dureeJours: map[EventTable.dureeJours] as int,
    nombrePlaces: map[EventTable.nombrePlaces] as int,
    niveauImportance: map[EventTable.niveauImportance] as String,
    niveauExigeance: map[EventTable.niveauExigeance] as String,
    formateur: map[EventTable.formateur] as String,
  );

  /// DTO -> Map (vers SQLite)
  Map<String, Object?> toMap() => {
    EventTable.id: idEvenement,
    EventTable.titre: titre,
    EventTable.description: description,
    EventTable.localisation: localisation,
    EventTable.date: date,
    EventTable.dureeJours: dureeJours,
    EventTable.nombrePlaces: nombrePlaces,
    EventTable.niveauImportance: niveauImportance,
    EventTable.niveauExigeance: niveauExigeance,
    EventTable.formateur: formateur,
  };

  /// Mapping DTO <-> Entity (domaine)
  EventEntity toEntity() => EventEntity(
    idEvenement: idEvenement,
    titre: titre,
    description: description,
    localisation: localisation,
    date: date,
    dureeJours: dureeJours,
    nombrePlaces: nombrePlaces,
    niveauImportance: niveauImportance,
    niveauExigeance: niveauExigeance,
    formateur: formateur,
  );

  factory EventDto.fromEntity(EventEntity e) => EventDto(
    idEvenement: e.idEvenement,
    titre: e.titre,
    description: e.description,
    localisation: e.localisation,
    date: e.date,
    dureeJours: e.dureeJours,
    nombrePlaces: e.nombrePlaces,
    niveauImportance: e.niveauImportance,
    niveauExigeance: e.niveauExigeance,
    formateur: e.formateur,
  );
}
