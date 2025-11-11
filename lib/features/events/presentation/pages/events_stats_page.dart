// lib/features/events/presentation/pages/events_stats_page.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // pour copier le CSV
import '../../routes.dart';
import '../controllers/event_stats_controller.dart';

class EventsStatsPage extends StatefulWidget {
  const EventsStatsPage({super.key});

  @override
  State<EventsStatsPage> createState() => _EventsStatsPageState();
}

class _EventsStatsPageState extends State<EventsStatsPage> {
  static const int _currentUserId = 1;

  late final EventStatsController controller;
  late final List<String> monthOptions;
  String selectedMonth = 'Toutes';

  @override
  void initState() {
    super.initState();
    controller = EventStatsController();
    monthOptions = _buildMonthOptions();
    controller.load(userId: _currentUserId);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  List<String> _buildMonthOptions() {
    final now = DateTime.now();
    final list = <String>['Toutes'];
    for (var i = 0; i < 12; i++) {
      final d = DateTime(now.year, now.month - i, 1);
      final label = '${d.year}-${d.month.toString().padLeft(2, '0')}';
      list.add(label);
    }
    return list;
  }

  void _openListFiltered({String? lieu, String? week}) {
    Navigator.of(context).pushNamed(
      EventsRoutes.list,
      arguments: {
        if (lieu != null) 'initialLieu': lieu,
        if (week != null) 'initialWeek': week,
      },
    );
  }

  // ---------- helpers ----------
  MapEntry<String, int>? _maxEntry(Map<String, int> m) {
    if (m.isEmpty) return null;
    return m.entries.reduce((a, b) => a.value >= b.value ? a : b);
  }

  @override
  Widget build(BuildContext context) {
    const pageBg = Color(0xFFF4F2FF);
    const headerA = Color(0xFF2D6CDF);
    const headerB = Color(0xFF6CA8FF);

    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final text = theme.textTheme;

    return Scaffold(
      backgroundColor: pageBg,
      appBar: AppBar(
        backgroundColor: headerA,
        foregroundColor: Colors.white,
        title: const Text('Statistiques'),
        actions: [
          IconButton(
            tooltip: 'Exporter CSV (copier)',
            icon: const Icon(Icons.download),
            onPressed: () async {
              final csv = controller.stats.toCsv(); // méthode définie dans EventStats
              final messenger = ScaffoldMessenger.of(context); // capture avant l'await
              await Clipboard.setData(ClipboardData(text: csv));
              messenger.showSnackBar(
                const SnackBar(content: Text('CSV copié dans le presse-papier')),
              );
            },
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          if (controller.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (controller.error != null) {
            return Center(child: Text('Erreur: ${controller.error}'));
          }

          final stats = controller.stats;
          final maxWeek = stats.byWeek.values.isEmpty
              ? 1
              : stats.byWeek.values.reduce(math.max);

          return ListView(
            padding: EdgeInsets.zero,
            children: [
              // HEADER
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [headerA, headerB],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Vue d’ensemble',
                        style: text.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        )),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: .18),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white.withValues(alpha: .35)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selectedMonth,
                              dropdownColor: Colors.white,
                              iconEnabledColor: Colors.white,
                              items: monthOptions
                                  .map((m) => DropdownMenuItem<String>(
                                value: m,
                                child: Text(m),
                              ))
                                  .toList(),
                              onChanged: (v) {
                                if (v == null) return;
                                setState(() => selectedMonth = v);
                                controller.load(
                                  userId: _currentUserId,
                                  monthFilter: (v == 'Toutes') ? null : v.trim(),
                                );
                              },
                              style: text.bodyMedium?.copyWith(
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Chip(
                          label: Text(
                            'Total: ${stats.totalEvents}',
                            style: const TextStyle(color: Colors.black),
                          ),
                          backgroundColor: Colors.white.withValues(alpha: .18),
                          side: BorderSide(color: Colors.white.withValues(alpha: .35)),
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // KPI
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _KpiCard(
                      color: scheme.primaryContainer,
                      icon: Icons.event_available,
                      title: 'À venir',
                      value: '${stats.totalFutureEvents}',
                      caption: 'Événements futurs',
                    ),
                    _KpiCard(
                      color: scheme.secondaryContainer,
                      icon: Icons.timelapse,
                      title: 'Durée moy.',
                      value: '${stats.avgDurationDays}',
                      caption: 'Jours / évènement',
                    ),
                    _KpiCard(
                      color: scheme.tertiaryContainer,
                      icon: Icons.people_alt,
                      title: 'Places moy.',
                      value: '${stats.avgSeats}',
                      caption: 'Par évènement',
                    ),
                    _KpiCard(
                      color: scheme.primaryContainer,
                      icon: Icons.favorite,
                      title: 'Favoris',
                      value: '${stats.favorisCount}',
                      caption: '${stats.favorisRate.toStringAsFixed(1)}% des évènements',
                    ),
                    _KpiCard(
                      color: scheme.secondaryContainer,
                      icon: Icons.how_to_reg,
                      title: 'Participation',
                      value: '${stats.participeCount}',
                      caption: '${stats.participationRate.toStringAsFixed(1)}% du marqué',
                    ),
                  ],
                ),
              ),

              // INSIGHTS
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: _SectionCard(
                  title: 'Insights',
                  child: Builder(
                    builder: (context) {
                      final bestLieu = _maxEntry(stats.byLocation);
                      final bestWeek = _maxEntry(stats.byWeek);
                      final avgDuration = stats.avgDurationDays;

                      return Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _InsightTile(
                            icon: Icons.place,
                            title: 'Lieu le plus actif',
                            value: (bestLieu == null) ? '—' : bestLieu.key,
                            caption: (bestLieu == null)
                                ? 'Aucune donnée'
                                : '${bestLieu.value} évènement${bestLieu.value > 1 ? 's' : ''}',
                            onTap: (bestLieu == null)
                                ? null
                                : () => _openListFiltered(lieu: bestLieu.key),
                          ),
                          _InsightTile(
                            icon: Icons.date_range,
                            title: 'Semaine la plus chargée',
                            value: (bestWeek == null) ? '—' : bestWeek.key,
                            caption: (bestWeek == null)
                                ? 'Aucune donnée'
                                : '${bestWeek.value} évènement${bestWeek.value > 1 ? 's' : ''}',
                            onTap: (bestWeek == null)
                                ? null
                                : () => _openListFiltered(week: bestWeek.key),
                          ),
                          _InsightTile(
                            icon: Icons.timelapse,
                            title: 'Durée moyenne (global)',
                            value: '$avgDuration j',
                            caption: 'Sur l’ensemble des évènements',
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),

              // TOP LIEUX
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: _SectionCard(
                  title: 'Top lieux',
                  child: _TopLocations(
                    byLocation: stats.byLocation,
                    onLieuTap: (lieu) => _openListFiltered(lieu: lieu),
                  ),
                ),
              ),

              // RÉPARTITION HEBDOMADAIRE
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: _SectionCard(
                  title: 'Répartition hebdomadaire',
                  child: (stats.byWeek.isEmpty)
                      ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: Text('Aucune donnée'),
                  )
                      : Column(
                    children: stats.byWeek.entries.map((e) {
                      final ratio = e.value / maxWeek;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () => _openListFiltered(week: e.key),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 78,
                                child: Text(
                                  e.key,
                                  style: text.bodySmall?.copyWith(
                                    color: scheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: LinearProgressIndicator(
                                    value: ratio.clamp(0.0, 1.0),
                                    minHeight: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${e.value}',
                                style: text.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              // HISTOGRAMME COMPACT — Lieux
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: _SectionCard(
                  title: 'Histogramme compact — Lieux (top 8)',
                  child: _MiniBarChart(
                    data: stats.byLocation,
                    maxBars: 8,
                    onTap: (lieu) => _openListFiltered(lieu: lieu),
                  ),
                ),
              ),

              // HISTOGRAMME COMPACT — Semaines
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: _SectionCard(
                  title: 'Histogramme compact — Semaines (top 8)',
                  child: _MiniBarChart(
                    data: stats.byWeek,
                    maxBars: 8,
                    onTap: (week) => _openListFiltered(week: week),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ---------- UI HELPERS ----------
class _KpiCard extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String title;
  final String value;
  final String caption;

  const _KpiCard({
    required this.color,
    required this.icon,
    required this.title,
    required this.value,
    required this.caption,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Container(
      width: 170,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: .4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: scheme.onSecondaryContainer),
          const SizedBox(height: 8),
          Text(title,
              style: text.labelLarge?.copyWith(
                  color: scheme.onSurface, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(
            value,
            style: text.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          Text(caption,
              style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: .35)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: text.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _TopLocations extends StatelessWidget {
  final Map<String, int> byLocation;
  final void Function(String lieu) onLieuTap;
  const _TopLocations({required this.byLocation, required this.onLieuTap});

  @override
  Widget build(BuildContext context) {
    final entries = byLocation.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top = entries.take(6).toList();
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    if (top.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(12),
        child: Text('Aucune donnée'),
      );
    }

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: top.map((e) {
        return InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: () => onLieuTap(e.key),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: scheme.secondaryContainer,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.place, size: 16),
                const SizedBox(width: 6),
                Text(e.key,
                    style: text.labelLarge
                        ?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(width: 8),
                Text('${e.value}',
                    style: text.labelMedium
                        ?.copyWith(fontWeight: FontWeight.w800)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// Mini histogramme compact (sans package externe)
class _MiniBarChart extends StatelessWidget {
  final Map<String, int> data;
  final int maxBars; // pour ne pas surcharger l’écran
  final void Function(String key)? onTap;

  const _MiniBarChart({
    required this.data,
    this.maxBars = 8,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(12),
        child: Text('Aucune donnée'),
      );
    }

    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    // Trie décroissant et coupe au maxBars
    final entries = data.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final shown = entries.take(maxBars).toList();

    final maxVal = shown
        .map((e) => e.value)
        .fold<int>(0, (p, v) => v > p ? v : p)
        .clamp(1, 1 << 31);

    return Column(
      children: shown.map((e) {
        final ratio = (e.value / maxVal).clamp(0.0, 1.0);
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: onTap == null ? null : () => onTap!(e.key),
            child: Row(
              children: [
                // Libellé (clé)
                SizedBox(
                  width: 90,
                  child: Text(
                    e.key,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                ),
                const SizedBox(width: 8),
                // Barre
                Expanded(
                  child: Container(
                    height: 14,
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: scheme.outlineVariant.withValues(alpha: .35)),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: ratio == 0 ? 0.02 : ratio, // minimum visible
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [scheme.primary, scheme.secondary],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Valeur
                SizedBox(
                  width: 36,
                  child: Text(
                    '${e.value}',
                    textAlign: TextAlign.right,
                    style: text.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _InsightTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String caption;
  final VoidCallback? onTap;

  const _InsightTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.caption,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    final tile = Container(
      width: 220,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: .35)),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withValues(alpha: .05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: scheme.primary),
          const SizedBox(height: 6),
          Text(title, style: text.labelLarge?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(value, style: text.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 2),
          Text(caption, style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
        ],
      ),
    );

    if (onTap == null) return tile;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: tile,
      ),
    );
  }
}
