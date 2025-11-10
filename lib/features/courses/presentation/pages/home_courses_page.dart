import 'package:flutter/material.dart';
import '../controllers/courses_controller.dart';
import '../widgets/course_card.dart';
import '../../../../core/utils/debouncer.dart';
import 'course_detail_page.dart';

class HomeCoursesPage extends StatefulWidget {
  const HomeCoursesPage({super.key});
  @override
  State<HomeCoursesPage> createState() => _HomeCoursesPageState();
}

class _HomeCoursesPageState extends State<HomeCoursesPage> {
  late CoursesController _ctrl;
  bool _ready = false;
  final _search = TextEditingController();
  final _debouncer = Debouncer();

  int? _filterLevel;
  int? _filterLanguage;

  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    _ctrl = await CoursesController.init();
    // charger les infos persos pour les badges
    await _ctrl.fetchMyCoursesOngoing(1);
    await _ctrl.fetchMyCoursesCompleted(1);
    await _ctrl.loadBookmarks(1);
    await _ctrl.loadAll();
    setState(() => _ready = true);

    _search.addListener(() {
      _debouncer.run(() {
        _ctrl.loadAll(
          query: _search.text.trim().isEmpty ? null : _search.text.trim(),
          level: _filterLevel,
          language: _filterLanguage,
        );
      });
    });
  }

  @override
  void dispose() {
    _search.dispose();
    _debouncer.dispose();
    super.dispose();
  }

  void _openFilters() async {
    final result = await showModalBottomSheet<(int?, int?)>(
      context: context,
      builder: (ctx) => _FiltersSheet(
        initLevel: _filterLevel,
        initLang: _filterLanguage,
      ),
    );
    if (result != null) {
      setState(() {
        _filterLevel = result.$1;
        _filterLanguage = result.$2;
      });
      _ctrl.loadAll(
        query: _search.text.trim().isEmpty ? null : _search.text.trim(),
        level: _filterLevel,
        language: _filterLanguage,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(
        title: const Text('EduConnect'),
        actions: [IconButton(onPressed: _openFilters, icon: const Icon(Icons.tune))],
      ),
      body: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) {
          final items = _ctrl.state.all;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: TextField(
                  controller: _search,
                  decoration: InputDecoration(
                    hintText: 'Rechercher un cours…',
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
                  onRefresh: () async => _ctrl.loadAll(
                    query: _search.text.trim().isEmpty ? null : _search.text.trim(),
                    level: _filterLevel,
                    language: _filterLanguage,
                  ),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) {
                      final c = items[i];

                      // VM "en cours" correspondante (pour la progression)
                      CourseWithProgressVM? ongoingVm;
                      for (final vm in _ctrl.state.myOngoing) {
                        if (vm.course.id == c.id) { ongoingVm = vm; break; }
                      }

                      final bool completed =
                      _ctrl.state.myCompleted.any((e) => e.course.id == c.id);
                      final bool isBm =
                      _ctrl.state.bookmarks.any((b) => b.id == c.id);

                      final double progressPct = ongoingVm?.progressPercent ?? 0.0;
                      final bool showProgress = !completed && (progressPct > 0.0);

                      // Libellé du bouton de la page de détail
                      final String callToAction = completed
                          ? 'Revoir le cours'
                          : (progressPct > 0.0 ? 'Reprendre le cours' : 'Commencer');

                      // Bouton sur la carte Home :
                      // - Non commencé -> "Découvrir le cours"
                      // - Sinon pas de bouton (les cas Reprendre/Revoir sont gérés sur la page détail)
                      final String? trailingButton =
                      (!completed && progressPct <= 0.0) ? 'Découvrir le cours' : null;

                      return CourseCard(
                        course: c,
                        // Cache la barre si non commencé ou terminé
                        progressPercent: showProgress ? progressPct : null,
                        completed: completed,
                        isBookmarked: isBm,
                        trailingButtonText: trailingButton,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => CourseDetailPage(
                                courseId: c.id,
                                userId: 1,
                                callToAction: callToAction, // utilisé pour le libellé principal
                              ),
                            ),
                          );
                        },
                        onBookmarkToggle: () => _ctrl.toggleBookmark(1, c.id),
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

class _FiltersSheet extends StatefulWidget {
  final int? initLevel;
  final int? initLang;
  const _FiltersSheet({required this.initLevel, required this.initLang});
  @override
  State<_FiltersSheet> createState() => _FiltersSheetState();
}

class _FiltersSheetState extends State<_FiltersSheet> {
  int? _level;
  int? _lang;

  @override
  void initState() {
    super.initState();
    _level = widget.initLevel;
    _lang = widget.initLang;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Filtres', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            Row(children: [
              const Text('Niveau'),
              const Spacer(),
              DropdownButton<int?>(
                value: _level,
                items: const [
                  DropdownMenuItem(value: null, child: Text('Tous')),
                  DropdownMenuItem(value: 1, child: Text('1')),
                  DropdownMenuItem(value: 2, child: Text('2')),
                  DropdownMenuItem(value: 3, child: Text('3')),
                ],
                onChanged: (v) => setState(() => _level = v),
              ),
            ]),
            Row(children: [
              const Text('Langue'),
              const Spacer(),
              DropdownButton<int?>(
                value: _lang,
                items: const [
                  DropdownMenuItem(value: null, child: Text('Toutes')),
                  DropdownMenuItem(value: 0, child: Text('FR')),
                  DropdownMenuItem(value: 1, child: Text('EN')),
                ],
                onChanged: (v) => setState(() => _lang = v),
              ),
            ]),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () =>
                        Navigator.pop<(int?, int?)>(context, (_level, _lang)),
                    child: const Text('Appliquer'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
