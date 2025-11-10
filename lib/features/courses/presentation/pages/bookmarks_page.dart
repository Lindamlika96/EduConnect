import 'package:flutter/material.dart';
import '../controllers/courses_controller.dart';
import '../widgets/course_card.dart';
import '../../../../core/utils/debouncer.dart';

class BookmarksPage extends StatefulWidget {
  const BookmarksPage({super.key});
  @override
  State<BookmarksPage> createState() => _BookmarksPageState();
}

class _BookmarksPageState extends State<BookmarksPage> {
  late CoursesController _ctrl;
  bool _ready = false;
  final _search = TextEditingController();
  final _debouncer = Debouncer();
  final _userId = 1;

  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    _ctrl = await CoursesController.init();
    await _ctrl.loadBookmarks(_userId);
    setState(() => _ready = true);
    _search.addListener(() {
      _debouncer.run(() => setState(() {}));
    });
  }

  @override
  void dispose() {
    _search.dispose();
    _debouncer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(title: const Text('Mes favoris')),
      body: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) {
          final q = _search.text.trim().toLowerCase();
          final itemsRaw = _ctrl.state.bookmarks;
          final items = q.isEmpty
              ? itemsRaw
              : itemsRaw.where((c) => c.title.toLowerCase().contains(q)).toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: TextField(
                  controller: _search,
                  decoration: InputDecoration(
                    hintText: 'Rechercher un favori…',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.black.withOpacity(0.04),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              if (_ctrl.state.isLoading) const LinearProgressIndicator(minHeight: 2),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async => _ctrl.loadBookmarks(_userId),
                  child: items.isEmpty
                      ? const Center(child: Text('Aucun favori'))
                      : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) {
                      final c = items[i];
                      return Dismissible(
                        key: ValueKey('bm_${c.id}'),
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 16),
                          decoration: BoxDecoration(
                            color: Colors.red.shade400,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        direction: DismissDirection.endToStart,
                        onDismissed: (_) => _ctrl.toggleBookmark(_userId, c.id),
                        child: CourseCard(
                          course: c,
                          isBookmarked: true,
                          onTap: () => Navigator.of(context).pushNamed('/course/detail', arguments: c.id),
                          onBookmarkToggle: () => _ctrl.toggleBookmark(_userId, c.id),
                        ),
                      );
                    },
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