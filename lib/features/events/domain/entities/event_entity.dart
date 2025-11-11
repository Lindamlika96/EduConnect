/// Entité métier pure (aucune dépendance à sqflite).
/// Reflète la table `events` sans renommer les colonnes côté DB.
class EventEntity {
  /// NULL tant que l'event n’est pas inséré (AUTO-INCREMENT côté DB).
  final int? idEvenement;

  final String titre;
  final String? description;

  /// Valeurs autorisées en DB (CHECK):
  /// 'Tunis','Sfax','Sousse','Kairouan','Bizerte','Gabès','Ariana'
  final String localisation;

  /// Stocké TEXT en DB — recommande un format ISO-8601 (ex: "2025-11-06").
  final String date;

  /// CHECK(duree_jours >= 1)
  final int dureeJours;

  /// CHECK(nombre_places >= 0)
  final int nombrePlaces;

  /// Valeurs autorisées (CHECK):
  /// 'Très peu','Peu','Moyen','Important','Très important','Événement extraordinaire'
  final String niveauImportance;

  /// Valeurs autorisées (CHECK):
  /// 'Très peu','Peu','Moyen','Important','Très important','Extraordinaire'
  final String niveauExigeance;

  /// Valeurs autorisées (CHECK):
  /// 'Élève Université','Étudiant bénévole','Professeur Université','Expert','PDG'
  final String formateur;

  const EventEntity({
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

  EventEntity copyWith({
    int? idEvenement,
    String? titre,
    String? description,
    String? localisation,
    String? date,
    int? dureeJours,
    int? nombrePlaces,
    String? niveauImportance,
    String? niveauExigeance,
    String? formateur,
  }) {
    return EventEntity(
      idEvenement: idEvenement ?? this.idEvenement,
      titre: titre ?? this.titre,
      description: description ?? this.description,
      localisation: localisation ?? this.localisation,
      date: date ?? this.date,
      dureeJours: dureeJours ?? this.dureeJours,
      nombrePlaces: nombrePlaces ?? this.nombrePlaces,
      niveauImportance: niveauImportance ?? this.niveauImportance,
      niveauExigeance: niveauExigeance ?? this.niveauExigeance,
      formateur: formateur ?? this.formateur,
    );
  }
}
