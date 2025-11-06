// lib/features/courses/presentation/pages/course_list_page.dart
import 'package:flutter/material.dart';

import '../../presentation/di.dart';
import '../../data/dao/course_dao.dart';
import 'course_detail_page.dart';

class CourseListPage extends StatefulWidget {
  const CourseListPage({super.key});

  @override
  State<CourseListPage> createState() => _CourseListPageState();
}

class _CourseListPageState extends State<CourseListPage> {
  late final Future<CoursesDI> _diFuture;

  @override
  void initState() {
    super.initState();
    _diFuture = CoursesDI.init();
  }

  Future<void> _addDummy(CourseDao dao) async {
    await dao.insertDummyCourse();
    setState(() {}); // recharger la liste
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<CoursesDI>(
      future: _diFuture,
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final di = snap.data!;

        return Scaffold(
          appBar: AppBar(title: const Text('Courses')),
          body: FutureBuilder<List<Map<String, Object?>>>(
            future: di.dao.fetchCourses(),
            builder: (context, listSnap) {
              if (listSnap.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              final rows = listSnap.data ?? const <Map<String, Object?>>[];

              if (rows.isEmpty) {
                return const Center(
                  child: Text('Aucun cours. Clique + pour en ajouter un de démo.'),
                );
              }

              return ListView.separated(
                itemCount: rows.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final r = rows[i];
                  final id = r['id'] as int;
                  final title = '${r['title']}';
                  final rating = r['rating_avg'];
                  final students = r['students_count'];

                  void openDetail() {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => CourseDetailPage(courseId: id),
                      ),
                    );
                  }

                  return ListTile(
                    title: Text(title),
                    subtitle: Text('⭐ $rating  👥 $students'),
                    onTap: openDetail,
                    trailing: ElevatedButton(
                      onPressed: openDetail,
                      child: const Text('Accéder'),
                    ),
                  );
                },
              );
            },
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _addDummy(di.dao),
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}
