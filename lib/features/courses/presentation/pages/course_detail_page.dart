import 'package:flutter/material.dart';
import '../../presentation/di.dart';
import 'course_pdf_page.dart';

class CourseDetailPage extends StatefulWidget {
  final int courseId;
  const CourseDetailPage({super.key, required this.courseId});

  @override
  State<CourseDetailPage> createState() => _CourseDetailPageState();
}

class _CourseDetailPageState extends State<CourseDetailPage> {
  late final Future<CoursesDI> _di;

  @override
  void initState() {
    super.initState();
    _di = CoursesDI.init();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<CoursesDI>(
      future: _di,
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final di = snap.data!;
        return FutureBuilder<Map<String, Object?>?>(
          future: di.dao.fetchCourseById(widget.courseId),
          builder: (context, courseSnap) {
            if (courseSnap.connectionState != ConnectionState.done) {
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }
            final course = courseSnap.data;
            if (course == null) {
              return Scaffold(
                appBar: AppBar(title: const Text('Cours')),
                body: const Center(child: Text('Cours introuvable')),
              );
            }

            final title = '${course['title']}';
            final desc = '${course['description_html'] ?? ''}';
            final rating = course['rating_avg'];
            final students = course['students_count'];
            final pdfPath = course['pdf_path'] as String?;

            return Scaffold(
              appBar: AppBar(title: Text(title)),
              body: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('⭐ $rating  👥 $students'),
                    const SizedBox(height: 12),
                    Text(desc),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Commencer le cours'),
                        onPressed: pdfPath == null
                            ? null
                            : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CoursePdfPage(path: pdfPath, courseId: widget.courseId),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
