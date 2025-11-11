// lib/features/events/domain/entities/event_stats.dart

class EventStats {
  final int totalEvents;
  final int totalFutureEvents;

  final int avgDurationDays;
  final int avgSeats;

  final int favorisCount;
  final double favorisRate;        // 0..100
  final int participeCount;
  final double participationRate;  // 0..100

  final Map<String, int> byLocation; // "Tunis" -> 5
  final Map<String, int> byWeek;     // "2025-W45" -> 3

  const EventStats({
    required this.totalEvents,
    required this.totalFutureEvents,
    required this.avgDurationDays,
    required this.avgSeats,
    required this.favorisCount,
    required this.favorisRate,
    required this.participeCount,
    required this.participationRate,
    required this.byLocation,
    required this.byWeek,
  });

  /// Objet vide par défaut (pour init controller sans nulls)
  factory EventStats.empty() => const EventStats(
    totalEvents: 0,
    totalFutureEvents: 0,
    avgDurationDays: 0,
    avgSeats: 0,
    favorisCount: 0,
    favorisRate: 0.0,
    participeCount: 0,
    participationRate: 0.0,
    byLocation: {},
    byWeek: {},
  );

  /// CSV d’export (lisible dans Excel / Google Sheets).
  /// - Bloc 1 : KPIs d’ensemble
  /// - Bloc 2 : Répartition par lieu
  /// - Bloc 3 : Répartition par semaine
  String toCsv() {
    final buf = StringBuffer();

    // --- Bloc KPIs
    buf.writeln('KPI, Valeur');
    buf.writeln('Total événements, $totalEvents');
    buf.writeln('Événements à venir, $totalFutureEvents');
    buf.writeln('Durée moyenne (jours), $avgDurationDays');
    buf.writeln('Places moyennes, $avgSeats');
    buf.writeln('Favoris (nb), $favorisCount');
    buf.writeln('Favoris (%), ${favorisRate.toStringAsFixed(1)}');
    buf.writeln('Participation (nb), $participeCount');
    buf.writeln('Participation (%), ${participationRate.toStringAsFixed(1)}');
    buf.writeln('');

    // --- Bloc lieux
    buf.writeln('Lieux, Compte');
    final byLocSorted = byLocation.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    for (final e in byLocSorted) {
      buf.writeln('${_escapeCsv(e.key)}, ${e.value}');
    }
    buf.writeln('');

    // --- Bloc semaines
    buf.writeln('Semaine, Compte');
    final byWeekSorted = byWeek.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    for (final e in byWeekSorted) {
      buf.writeln('${_escapeCsv(e.key)}, ${e.value}');
    }

    return buf.toString();
  }

  static String _escapeCsv(String s) {
    final needsQuote = s.contains(',') || s.contains('\n') || s.contains('"');
    if (!needsQuote) return s;
    return '"${s.replaceAll('"', '""')}"';
  }
}
