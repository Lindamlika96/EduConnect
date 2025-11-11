// lib/features/events/presentation/controllers/event_stats_controller.dart
import 'package:flutter/foundation.dart';
import '../../di.dart';
import '../../domain/entities/event_stats.dart';
import '../../domain/entities/participation_entity.dart'; // ParticipationStatus

class EventStatsController extends ChangeNotifier {
  bool loading = false;
  String? error;
  EventStats stats = EventStats.empty();

  /// Charge et calcule les stats.
  /// - [userId] est requis (statuts favoris/participe par utilisateur).
  /// - [monthFilter] au format "YYYY-MM" (ex: "2025-11"). Null = toutes.
  Future<void> load({required int userId, String? monthFilter}) async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      // 1) Tous les évènements
      final events = await EventsDI.getEvents();

      // 2) Filtre mensuel (si défini) : match préfixe "YYYY-MM"
      final filtered = (monthFilter == null)
          ? events
          : events.where((e) => e.date.startsWith(monthFilter)).toList();

      // 3) IDs par statut (utilisateur courant)
      final favIds = await EventsDI.getEventIdsByStatus(
        userId: userId,
        status: ParticipationStatus.favori,
      );
      final partIds = await EventsDI.getEventIdsByStatus(
        userId: userId,
        status: ParticipationStatus.participe,
      );
      final favSet = favIds.toSet();
      final partSet = partIds.toSet();

      // 4) Agrégations
      final total = filtered.length;
      final now = DateTime.now();

      int futureCount = 0;
      int sumDays = 0;
      int sumSeats = 0;
      int favCount = 0;
      int partCount = 0;

      final byLocation = <String, int>{};
      final byWeek = <String, int>{};

      String weekKey(DateTime d) {
        // clé style "YYYY-Wxx"
        final monday = d.subtract(Duration(days: (d.weekday + 6) % 7));
        final firstJan = DateTime(d.year, 1, 1);
        final firstMonday = firstJan.subtract(Duration(days: (firstJan.weekday + 6) % 7));
        final week = ((monday.difference(firstMonday).inDays) / 7).floor() + 1;
        return '${d.year}-W${week.toString().padLeft(2, '0')}';
      }

      DateTime? parseDate(String raw) {
        try {
          return DateTime.parse(raw);
        } catch (_) {
          return null;
        }
      }

      for (final e in filtered) {
        sumDays += e.dureeJours;
        sumSeats += e.nombrePlaces;

        if (e.idEvenement != null) {
          final id = e.idEvenement!;
          if (favSet.contains(id)) favCount++;
          if (partSet.contains(id)) partCount++;
        }

        // Lieux
        byLocation.update(e.localisation, (v) => v + 1, ifAbsent: () => 1);

        // Semaine + futur
        final dt = parseDate(e.date);
        if (dt != null) {
          // "à venir" = date >= aujourd’hui (jour courant inclus)
          final today = DateTime(now.year, now.month, now.day);
          if (!dt.isBefore(today)) {
            futureCount++;
          }
          byWeek.update(weekKey(dt), (v) => v + 1, ifAbsent: () => 1);
        }
      }

      // Moyennes (arrondies)
      final avgDays = (total == 0) ? 0 : (sumDays / total).round();
      final avgSeats = (total == 0) ? 0 : (sumSeats / total).round();

      final favRate = (total == 0) ? 0.0 : (favCount * 100.0 / total);
      final partRate = (total == 0) ? 0.0 : (partCount * 100.0 / total);

      stats = EventStats(
        totalEvents: total,
        totalFutureEvents: futureCount,
        avgDurationDays: avgDays,
        avgSeats: avgSeats,
        favorisCount: favCount,
        participeCount: partCount,
        favorisRate: favRate,
        participationRate: partRate,
        byLocation: byLocation,
        byWeek: byWeek,
      );

      loading = false;
      notifyListeners();
    } catch (e) {
      loading = false;
      error = e.toString();
      notifyListeners();
    }
  }
}
