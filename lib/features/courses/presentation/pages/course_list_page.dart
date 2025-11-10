import 'package:flutter/material.dart';
import '../controllers/courses_controller.dart';
import 'course_detail_page.dart';

class CourseListPage extends StatefulWidget {
  final int userId;
  const CourseListPage({super.key, this.userId = 1});

  @override
  State<CourseListPage> createState() => _CourseListPageState();
}

class _CourseListPageState extends State<CourseListPage>
    with SingleTickerProviderStateMixin {
  late final Future<CoursesController> _ctrl;
  late final TabController _tab;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _ctrl = CoursesController.init();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<CoursesController>(
      future: _ctrl,
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final ctrl = snap.data!;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Cours'),
            bottom: TabBar(
              controller: _tab,
              tabs: const [Tab(text: 'Tous'), Tab(text: 'Mes cours')],
            ),
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Rechercher un cours…',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (v) => setState(() => _query = v.trim()),
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tab,
                  children: [
                    // ======= Onglet "Tous"
                    RefreshIndicator(
                      onRefresh: () async => setState(() {}),
                      child: FutureBuilder<List<Map<String, Object?>>>(
                        future: ctrl.listAll(q: _query),
                        builder: (context, snap) {
                          if (snap.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          final rows = snap.data ?? const [];
                          if (rows.isEmpty) {
                            return const Center(child: Text('Aucun cours'));
                          }
                          return ListView.separated(
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: rows.length,
                            separatorBuilder: (_, __) => const Divider(height: 1),
                            itemBuilder: (context, i) {
                              final c = rows[i];
                              final id = (c['id'] as num).toInt();
                              final title = (c['title'] as String?) ?? 'Sans titre';
                              final rating =
                                  (c['rating_avg'] as num?)?.toDouble() ?? 0.0;
                              final isBookmarked =
                                  ((c['is_bookmarked'] as int?) ?? 0) == 1;

                              return ListTile(
                                title: Text(title),
                                subtitle: Text('⭐ ${rating.toStringAsFixed(1)}'),
                                trailing: IconButton(
                                  tooltip: isBookmarked
                                      ? 'Retirer des favoris'
                                      : 'Ajouter aux favoris',
                                  icon: Icon(
                                    isBookmarked
                                        ? Icons.bookmark
                                        : Icons.bookmark_border,
                                  ),
                                  onPressed: () async {
                                    await ctrl.toggleBookmark(widget.userId, id);
                                    if (mounted) setState(() {});
                                  },
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => CourseDetailPage(
                                        courseId: id,
                                        userId: widget.userId,
                                        callToAction: 'Commencer',
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),
                    ),

                    // ======= Onglet "Mes cours"
                    RefreshIndicator(
                      onRefresh: () async => setState(() {}),
                      child: FutureBuilder<List<Map<String, Object?>>>(
                        future: ctrl.listMine(widget.userId),
                        builder: (context, snap) {
                          if (snap.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          final rows = snap.data ?? const [];
                          if (rows.isEmpty) {
                            return const Center(child: Text('Aucun cours en cours'));
                          }
                          return ListView.separated(
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: rows.length,
                            separatorBuilder: (_, __) => const Divider(height: 1),
                            itemBuilder: (context, i) {
                              final c = rows[i];
                              final id = (c['id'] as num).toInt();
                              final title = (c['title'] as String?) ?? 'Sans titre';
                              final p =
                                  (c['progress_percent'] as num?)?.toDouble() ?? 0.0;
                              final isBookmarked =
                                  ((c['is_bookmarked'] as int?) ?? 0) == 1;

                              final completed = p >= 100.0;
                              final callToAction =
                              completed ? 'Revoir le cours' : (p > 0 ? 'Reprendre le cours' : 'Commencer');

                              return ListTile(
                                title: Text(title),
                                subtitle:
                                Text('Progression : ${p.toStringAsFixed(0)}%'),
                                trailing: IconButton(
                                  tooltip: isBookmarked
                                      ? 'Retirer des favoris'
                                      : 'Ajouter aux favoris',
                                  icon: Icon(
                                    isBookmarked
                                        ? Icons.bookmark
                                        : Icons.bookmark_border,
                                  ),
                                  onPressed: () async {
                                    await ctrl.toggleBookmark(widget.userId, id);
                                    if (mounted) setState(() {});
                                  },
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => CourseDetailPage(
                                        courseId: id,
                                        userId: widget.userId,
                                        callToAction: callToAction,
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
