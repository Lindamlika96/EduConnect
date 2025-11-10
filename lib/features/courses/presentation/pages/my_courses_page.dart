import 'package:flutter/material.dart';
import '../controllers/courses_controller.dart';
import '../widgets/course_card.dart';
import '../../../../core/utils/debouncer.dart';
import 'course_detail_page.dart';

class MyCoursesPage extends StatefulWidget {
  const MyCoursesPage({super.key});
  @override
  State<MyCoursesPage> createState() => _MyCoursesPageState();
}

class _MyCoursesPageState extends State<MyCoursesPage> {
  late CoursesController _ctrl;
  bool _ready = false;
  bool _showCompleted = true;

  final _userId = 1; // TODO: user connecté
  final _search = TextEditingController();
  final _debouncer = Debouncer();

  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    _ctrl = await CoursesController.init();
    await _reload();
    setState(() => _ready = true);

    _search.addListener(() {
      _debouncer.run(() => _reload());
    });
  }

  Future<void> _reload() async {
    if (_showCompleted) {
      await _ctrl.fetchMyCoursesCompleted(_userId);
    } else {
      await _ctrl.fetchMyCoursesOngoing(_userId);
    }
  }

  @override
  void dispose() {
    _search.dispose();
    _debouncer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final pillActive = Theme.of(context).colorScheme.primary;
    final pillInactive = Colors.black.withOpacity(0.06);

    return Scaffold(
      appBar: AppBar(title: const Text('Mes cours')),
      body: Column(
        children: [
          const SizedBox(height: 8),
          // recherche
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _search,
              decoration: InputDecoration(
                hintText: 'Rechercher dans mes cours…',
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
          const SizedBox(height: 8),
          // pills
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _pill('Complétés', _showCompleted, pillActive, pillInactive, () async {
                  setState(() => _showCompleted = true);
                  await _ctrl.fetchMyCoursesCompleted(_userId);
                }),
                const SizedBox(width: 8),
                _pill('En cours', !_showCompleted, pillActive, pillInactive, () async {
                  setState(() => _showCompleted = false);
                  await _ctrl.fetchMyCoursesOngoing(_userId);
                }),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // liste
          Expanded(
            child: AnimatedBuilder(
              animation: _ctrl,
              builder: (_, __) {
                final itemsRaw =
                _showCompleted ? _ctrl.state.myCompleted : _ctrl.state.myOngoing;
                final q = _search.text.trim().toLowerCase();
                final items = q.isEmpty
                    ? itemsRaw
                    : itemsRaw
                    .where((e) => e.course.title.toLowerCase().contains(q))
                    .toList();

                if (_ctrl.state.isLoading && items.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (items.isEmpty) {
                  return const Center(child: Text('Aucun cours'));
                }

                return RefreshIndicator(
                  onRefresh: () async => _reload(),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) {
                      final vm = items[i];
                      final completed = vm.progressPercent >= 100.0;

                      final callToAction =
                      completed ? 'Revoir le cours' : (vm.progressPercent > 0 ? 'Reprendre le cours' : 'Commencer');

                      return CourseCard(
                        course: vm.course,
                        progressPercent: completed ? null : vm.progressPercent,
                        completed: completed,
                        isBookmarked:
                        _ctrl.state.bookmarks.any((b) => b.id == vm.course.id),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CourseDetailPage(
                                courseId: vm.course.id,
                                userId: _userId,
                                callToAction: callToAction,
                              ),
                            ),
                          );
                        },
                        onBookmarkToggle: () =>
                            _ctrl.toggleBookmark(_userId, vm.course.id),
                        trailingButtonText:
                        completed ? 'Voir certificat' : null,
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _pill(String text, bool selected, Color active, Color inactive, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? active : inactive,
            borderRadius: BorderRadius.circular(24),
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
              color: selected ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}