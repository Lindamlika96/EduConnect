import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../controllers/event_controller.dart';
import '../widgets/event_filter.dart';
import '../widgets/event_card.dart';
import '../../routes.dart';
import '../../domain/entities/event_entity.dart';
import '../../domain/entities/participation_entity.dart'; // ParticipationStatus

class EventsListPage extends StatefulWidget {
  const EventsListPage({super.key});

  @override
  State<EventsListPage> createState() => _EventsListPageState();
}

class _EventsListPageState extends State<EventsListPage> {
  late final EventController _controller;
  final _searchKey = GlobalKey<_SearchHolderState>();

  // Pagination
  static const int _pageSize = 3;
  int _page = 0;

  // Filtres UI
  String _lieu = 'Tous';
  String _week = 'Toutes';

  @override
  void initState() {
    super.initState();
    _controller = EventController();
    _controller.load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _openDetail(EventEntity e) async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    final result = await navigator.pushNamed(
      EventsRoutes.detail,
      arguments: e.idEvenement,
    );

    if (!mounted) return;

    if (result == 'deleted' || result == 'updated') {
      _controller.load(search: _searchKey.currentState?.query);
      _resetPage();
      messenger.showSnackBar(
        SnackBar(content: Text(result == 'deleted' ? 'Événement supprimé' : 'Événement mis à jour')),
      );
    }
  }

  // Styles badge selon statut
  ({String emoji, Color bg, Color fg, Color border}) _statusStyle(String s, ColorScheme scheme) {
    switch (s) {
      case ParticipationStatus.participe:
        return (emoji: '✅', bg: scheme.primary, fg: scheme.onPrimary, border: scheme.primary);
      case ParticipationStatus.neParticipePas:
        return (emoji: '🚫', bg: scheme.error, fg: scheme.onError, border: scheme.error);
      case ParticipationStatus.favori:
        return (emoji: '❤️', bg: scheme.secondary, fg: scheme.onSecondary, border: scheme.secondary);
      default:
        return (emoji: 'ℹ️', bg: scheme.surface, fg: scheme.onSurface, border: scheme.outline);
    }
  }

  // === Helpers filtres & pagination ===

  String _weekKey(DateTime d) {
    final monday = d.subtract(Duration(days: (d.weekday + 6) % 7));
    final firstJan = DateTime(d.year, 1, 1);
    final firstMonday = firstJan.subtract(Duration(days: (firstJan.weekday + 6) % 7));
    final week = ((monday.difference(firstMonday).inDays) / 7).floor() + 1;
    return '${d.year}-W${week.toString().padLeft(2, '0')}';
  }

  DateTime? _parseDate(String raw) {
    try {
      return DateTime.parse(raw);
    } catch (_) {
      return null;
    }
  }

  List<String> _availableLieux() {
    final set = <String>{for (final e in _controller.items) e.localisation};
    final list = set.toList()..sort();
    return ['Tous', ...list];
  }

  List<String> _availableWeeks() {
    final set = <String>{};
    for (final e in _controller.items) {
      final dt = _parseDate(e.date);
      if (dt != null) set.add(_weekKey(dt));
    }
    final list = set.toList()..sort();
    return ['Toutes', ...list];
  }

  void _resetPage() {
    if (_page != 0) setState(() => _page = 0);
  }

  // === Filtrage et pagination sans underscore ===
  List<EventEntity> filteredEvents() {
    Iterable<EventEntity> items = _controller.items;

    if (_lieu != 'Tous') items = items.where((e) => e.localisation == _lieu);
    if (_week != 'Toutes') {
      items = items.where((e) {
        final dt = _parseDate(e.date);
        if (dt == null) return false;
        return _weekKey(dt) == _week;
      });
    }

    final list = items.toList()..sort((a, b) => a.date.compareTo(b.date));
    return list;
  }

  List<EventEntity> pageSlice(List<EventEntity> src) {
    final start = _page * _pageSize;
    final end = math.min(start + _pageSize, src.length);
    if (start >= src.length) return const [];
    return src.sublist(start, end);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F2FF),
        appBar: AppBar(
          backgroundColor: const Color(0xFF2D6CDF),
          foregroundColor: Colors.white,
          title: const Text('Événements'),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48),
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                final fav = _controller.favorisCount;
                final part = _controller.participeCount;
                final ne = _controller.neParticipePasCount;

                return Theme(
                  data: Theme.of(context).copyWith(
                    tabBarTheme: const TabBarThemeData(
                      indicatorColor: Colors.white,
                      labelColor: Colors.white,
                      unselectedLabelColor: Color(0xB3FFFFFF),
                    ),
                  ),
                  child: TabBar(
                    isScrollable: true,
                    onTap: (i) {
                      final tab = switch (i) {
                        0 => EventsTab.tous,
                        1 => EventsTab.favori,
                        2 => EventsTab.participe,
                        3 => EventsTab.neParticipePas,
                        _ => EventsTab.tous,
                      };
                      _controller.setTab(tab, search: _searchKey.currentState?.query);
                      _resetPage();
                    },
                    tabs: [
                      const Tab(text: 'Tous'),
                      Tab(text: 'Favoris ($fav)'),
                      Tab(text: 'Participe ($part)'),
                      Tab(text: 'Ne participe pas ($ne)'),
                    ],
                  ),
                );
              },
            ),
          ),
        ),

        // === Corps principal ===
        body: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final filtered = filteredEvents();
            final total = filtered.length;
            final totalPages = (total == 0) ? 1 : ((total - 1) ~/ _pageSize + 1);
            if (_page >= totalPages) _page = 0;
            final pageData = pageSlice(filtered);

            return Column(
              children: [
                // Recherche
                _SearchHolder(
                  key: _searchKey,
                  onSearch: (q) {
                    _controller.load(search: q.isEmpty ? null : q);
                    _resetPage();
                  },
                ),

                // Filtres
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      _FilterDropdown(
                        label: 'Lieu',
                        value: _lieu,
                        items: _availableLieux(),
                        onChanged: (v) => setState(() {
                          _lieu = v!;
                          _page = 0;
                        }),
                      ),
                      _FilterDropdown(
                        label: 'Semaine',
                        value: _week,
                        items: _availableWeeks(),
                        onChanged: (v) => setState(() {
                          _week = v!;
                          _page = 0;
                        }),
                      ),
                      Chip(
                        label: Text('$total résultat${total > 1 ? 's' : ''}'),
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                ),

                // Liste paginée
                Expanded(
                  child: Builder(
                    builder: (context) {
                      if (_controller.loading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (_controller.error != null) {
                        return Center(child: Text('Erreur: ${_controller.error}'));
                      }
                      if (total == 0) {
                        return const Center(child: Text('Aucun événement'));
                      }

                      return ListView.separated(
                        padding: const EdgeInsets.only(bottom: 12),
                        separatorBuilder: (context, index) => const SizedBox(height: 4),
                        itemCount: pageData.length,
                        itemBuilder: (context, index) {
                          final e = pageData[index];
                          final status = (e.idEvenement != null)
                              ? _controller.getStatusFor(e.idEvenement!)
                              : null;

                          return EventCard(
                            event: e,
                            onTap: () => _openDetail(e),
                          ).prettyWithBadge(
                            context: context,
                            status: status,
                            styleOf: (s) => _statusStyle(s, scheme),
                          );
                        },
                      );
                    },
                  ),
                ),

                // === Bas de page ===
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: FloatingActionButton(
                          heroTag: 'events-add-fab-inline',
                          backgroundColor: const Color(0xFFFFE17D),
                          foregroundColor: Colors.black87,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          onPressed: () async {
                            final navigator = Navigator.of(context);
                            final messenger = ScaffoldMessenger.of(context);
                            final insertedId = await navigator.pushNamed(EventsRoutes.add);
                            if (!mounted) return;
                            if (insertedId is int) {
                              _controller.load(search: _searchKey.currentState?.query);
                              _resetPage();
                              messenger.showSnackBar(
                                const SnackBar(content: Text('Événement créé avec succès')),
                              );
                            }
                          },
                          child: const Icon(Icons.add, size: 28),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Pagination
                      Row(
                        children: [
                          FilledButton.tonalIcon(
                            onPressed: (_page > 0)
                                ? () => setState(() => _page = _page - 1)
                                : null,
                            icon: const Icon(Icons.chevron_left),
                            label: const Text('Précédent'),
                          ),
                          Expanded(
                            child: Center(
                              child: Text('Page ${_page + 1} / $totalPages'),
                            ),
                          ),
                          FilledButton.tonalIcon(
                            onPressed: (_page < totalPages - 1)
                                ? () => setState(() => _page = _page + 1)
                                : null,
                            icon: const Icon(Icons.chevron_right),
                            label: const Text('Suivant'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SearchHolder extends StatefulWidget {
  final ValueChanged<String> onSearch;
  const _SearchHolder({super.key, required this.onSearch});

  @override
  State<_SearchHolder> createState() => _SearchHolderState();
}

class _SearchHolderState extends State<_SearchHolder> {
  String? query;

  @override
  Widget build(BuildContext context) {
    return EventFilter(
      onSearch: (q) {
        query = q;
        widget.onSearch(q);
      },
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _FilterDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: .6)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          borderRadius: BorderRadius.circular(12),
          items: items
              .map((e) => DropdownMenuItem<String>(
            value: e,
            child: Text(e),
          ))
              .toList(),
          onChanged: onChanged,
          icon: const Icon(Icons.expand_more),
          hint: Text(label),
        ),
      ),
    );
  }
}

extension EventCardPretty on EventCard {
  Widget prettyWithBadge({
  required BuildContext context,
  required String? status,
  required ({String emoji, Color bg, Color fg, Color border}) Function(String s) styleOf,
}) {
final s = status?.trim();
final scheme = Theme.of(context).colorScheme;

final badge = (s == null || s.isEmpty)
? const SizedBox.shrink()
    : Align(
alignment: Alignment.centerLeft,
child: Builder(
builder: (context) {
final st = styleOf(s);
return Container(
margin: const EdgeInsets.only(left: 20, bottom: 6, right: 20, top: 6),
child: Chip(
avatar: Text(st.emoji, style: const TextStyle(fontSize: 14)),
label: Text(
s,
style: TextStyle(color: st.fg, fontWeight: FontWeight.w700),
),
backgroundColor: st.bg,
side: BorderSide(color: st.border.withValues(alpha: .35)),
visualDensity: VisualDensity.compact,
materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
padding: const EdgeInsets.symmetric(horizontal: 10),
),
);
},
),
);

final decoratedCard = DecoratedBox(
decoration: BoxDecoration(
borderRadius: BorderRadius.circular(14),
boxShadow: [
BoxShadow(
color: scheme.primary.withValues(alpha: .06),
blurRadius: 10,
offset: const Offset(0, 6),
),
],
),
child: this,
);

return Column(
crossAxisAlignment: CrossAxisAlignment.stretch,
children: [
badge,
Padding(
padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
child: decoratedCard,
),
],
);
}
}
