// lib/features/events/presentation/controllers/event_gamification_controller.dart
import 'package:flutter/material.dart';

/// Contrôleur de la logique de gamification.
/// Calcule les points, badges et progression d’un utilisateur.
class EventGamificationController extends ChangeNotifier {
  bool loading = false;
  String? error;

  late GamificationProfile profile;

  /// Charge ou met à jour les données du joueur
  Future<void> load({required int userId}) async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      // ⚙️ Simule une latence réseau / base de données
      await Future.delayed(const Duration(milliseconds: 600));

      // 🔢 Simulation d’activités (à remplacer par vrai calcul DB plus tard)
      final randomSeed = (userId * 137) % 1000;
      final eventsAttended = 8 + (randomSeed % 6);
      final eventsCreated = 2 + (randomSeed % 4);
      final favorites = 3 + (randomSeed % 5);
      final totalPoints = eventsAttended * 10 + eventsCreated * 20 + favorites * 5;

      // 🧩 Déduction du niveau et progression
      final level = (totalPoints ~/ 100) + 1;
      final nextLevelThreshold = level * 100;
      final currentProgress = totalPoints / nextLevelThreshold;

      // 🎖️ Badges obtenus
      final badges = <Badge>[
        if (eventsCreated >= 1) Badge('Créateur', 'A créé un événement', Icons.edit_calendar),
        if (eventsAttended >= 5) Badge('Participant régulier', 'A participé à 5+ événements', Icons.emoji_events),
        if (favorites >= 3) Badge('Curieux', 'A mis 3+ événements en favoris', Icons.favorite),
        if (totalPoints >= 250) Badge('Proactif', 'A dépassé 250 points', Icons.star_rate),
      ];

      profile = GamificationProfile(
        userId: userId,
        points: totalPoints,
        level: level,
        progress: currentProgress.clamp(0.0, 1.0),
        eventsCreated: eventsCreated,
        eventsAttended: eventsAttended,
        favorites: favorites,
        badges: badges,
      );
    } catch (e) {
      error = 'Erreur de chargement: $e';
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}

/// Modèle de profil de gamification
class GamificationProfile {
  final int userId;
  final int points;
  final int level;
  final double progress;
  final int eventsCreated;
  final int eventsAttended;
  final int favorites;
  final List<Badge> badges;

  GamificationProfile({
    required this.userId,
    required this.points,
    required this.level,
    required this.progress,
    required this.eventsCreated,
    required this.eventsAttended,
    required this.favorites,
    required this.badges,
  });

  /// Calcule le nom de rang selon le niveau
  String get rankName {
    if (level < 3) return 'Débutant';
    if (level < 5) return 'Intermédiaire';
    if (level < 7) return 'Avancé';
    if (level < 9) return 'Expert';
    return 'Légende';
  }

  /// Couleur associée au rang
  Color get rankColor {
    switch (rankName) {
      case 'Débutant':
        return Colors.grey;
      case 'Intermédiaire':
        return Colors.blue;
      case 'Avancé':
        return Colors.purple;
      case 'Expert':
        return Colors.orange;
      default:
        return Colors.red;
    }
  }
}

/// Représente un badge de gamification
class Badge {
  final String title;
  final String description;
  final IconData icon;

  Badge(this.title, this.description, this.icon);
}
