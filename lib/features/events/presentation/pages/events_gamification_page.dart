import 'package:flutter/material.dart';
import '../controllers/event_gamification_controller.dart';

class EventsGamificationPage extends StatefulWidget {
  const EventsGamificationPage({super.key});

  @override
  State<EventsGamificationPage> createState() => _EventsGamificationPageState();
}

class _EventsGamificationPageState extends State<EventsGamificationPage> {
  static const int _currentUserId = 1;

  late final EventGamificationController _controller;

  // Palette cohérente avec tes autres pages
  static const _pageBg  = Color(0xFFEFF4FF);
  static const _headerA = Color(0xFF2D6CDF);
  static const _headerB = Color(0xFF6CA8FF);

  @override
  void initState() {
    super.initState();
    _controller = EventGamificationController();
    _controller.load(userId: _currentUserId);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _refresh() => _controller.load(userId: _currentUserId);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text   = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: _pageBg,
      appBar: AppBar(
        backgroundColor: _headerA,
        foregroundColor: Colors.white,
        title: const Text('Gamification'),
        actions: [
          IconButton(
            tooltip: 'Rafraîchir',
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
          ),
        ],
        flexibleSpace: const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [_headerA, _headerB],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          if (_controller.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (_controller.error != null) {
            return Center(child: Text('Erreur: ${_controller.error}'));
          }

          final p = _controller.profile;

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // ---------- HERO HEADER ----------
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [_headerA, _headerB],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Profil joueur',
                          style: text.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          )),
                      const SizedBox(height: 10),
                      _RankChip(name: p.rankName, color: p.rankColor),
                      const SizedBox(height: 14),
                      _LevelProgress(
                        level: p.level,
                        progress: p.progress,
                        points: p.points,
                      ),
                    ],
                  ),
                ),

                // ---------- KPIs ----------
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _KpiCard(
                        color: scheme.primaryContainer,
                        icon: Icons.stars,
                        title: 'Points',
                        value: '${p.points}',
                        caption: 'Score total',
                      ),
                      _KpiCard(
                        color: scheme.secondaryContainer,
                        icon: Icons.event_available,
                        title: 'Participations',
                        value: '${p.eventsAttended}',
                        caption: 'Événements rejoints',
                      ),
                      _KpiCard(
                        color: scheme.tertiaryContainer,
                        icon: Icons.edit_calendar,
                        title: 'Créations',
                        value: '${p.eventsCreated}',
                        caption: 'Événements créés',
                      ),
                      _KpiCard(
                        color: scheme.primaryContainer,
                        icon: Icons.favorite,
                        title: 'Favoris',
                        value: '${p.favorites}',
                        caption: 'Événements suivis',
                      ),
                    ],
                  ),
                ),

                // ---------- BADGES ----------
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: _SectionCard(
                    title: 'Badges obtenus',
                    child: (p.badges.isEmpty)
                        ? const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Aucun badge pour le moment'),
                    )
                        : GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: p.badges.length,
                      gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 1.35,
                      ),
                      itemBuilder: (context, i) {
                        final b = p.badges[i];
                        return _BadgeTile(b.title, b.description, b.icon);
                      },
                    ),
                  ),
                ),

                // ---------- CONSEILS ----------
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  child: const _SectionCard(
                    title: 'Conseils pour progresser',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _TipRow(
                            icon: Icons.how_to_reg,
                            text: 'Participe régulièrement : +10 points/événement.'),
                        _TipRow(
                            icon: Icons.edit_calendar,
                            text:
                            'Crée des événements de qualité : +20 points/création.'),
                        _TipRow(
                            icon: Icons.favorite,
                            text:
                            'Ajoute en favoris ce qui t’intéresse : +5 points.'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ======== UI bits ========

class _RankChip extends StatelessWidget {
  final String name;
  final Color color;
  const _RankChip({required this.name, required this.color});

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: const Icon(Icons.military_tech, size: 18, color: Colors.white),
      label: Text(
        name,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      backgroundColor: color,
      side: BorderSide(color: Colors.white.withValues(alpha: .25)),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}

class _LevelProgress extends StatelessWidget {
  final int level;
  final double progress;
  final int points;

  const _LevelProgress({
    required this.level,
    required this.progress,
    required this.points,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    final pct = (progress * 100).clamp(0, 100).toStringAsFixed(0);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: .25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Niveau $level',
              style: text.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              )),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 12,
              backgroundColor: Colors.white.withValues(alpha: .25),
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text('$pct% vers le prochain niveau',
                  style: text.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: .95),
                    fontWeight: FontWeight.w600,
                  )),
              const Spacer(),
              Text('$points pts',
                  style: text.labelLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  )),
            ],
          ),
        ],
      ),
    );
  }
}

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
    final text   = Theme.of(context).textTheme;

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
                color: scheme.onSurface,
                fontWeight: FontWeight.w700,
              )),
          const SizedBox(height: 6),
          Text(value, style: text.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          Text(caption, style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
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
    final text   = Theme.of(context).textTheme;

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

class _BadgeTile extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;

  const _BadgeTile(this.title, this.description, this.icon);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text   = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: .35)),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: scheme.secondary,
            child: Icon(icon, color: scheme.onSecondary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: text.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text(description, style: text.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TipRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _TipRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final txt    = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: scheme.primary),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: txt.bodyMedium)),
        ],
      ),
    );
  }
}
