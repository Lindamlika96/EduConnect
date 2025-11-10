// lib/features/courses/presentation/pages/course_detail_page.dart
import 'package:flutter/material.dart';
import '../controllers/courses_controller.dart';
import 'course_pdf_page.dart';

class CourseDetailPage extends StatefulWidget {
  final int courseId;
  final int userId;
  /// Texte du bouton d’action principal :
  /// - "Revoir le cours" si complété
  /// - "Reprendre le cours" si en cours
  /// - "Commencer" par défaut
  final String? callToAction;

  const CourseDetailPage({
    super.key,
    required this.courseId,
    required this.userId,
    this.callToAction,
  });

  @override
  State<CourseDetailPage> createState() => _CourseDetailPageState();
}

class _CourseDetailPageState extends State<CourseDetailPage> {
  late final Future<CoursesController> _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = CoursesController.init();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<CoursesController>(
      future: _ctrl,
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final ctrl = snap.data!;
        return FutureBuilder<Map<String, Object?>?>(
          future: ctrl.fetchCourseById(widget.courseId),
          builder: (context, snap) {
            if (!snap.hasData) {
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }
            final c = snap.data;
            if (c == null) {
              return const Scaffold(body: Center(child: Text('Cours introuvable')));
            }

            final title    = (c['title'] ?? '') as String;
            final rating   = (c['rating_avg'] as num?)?.toDouble() ?? 0.0;
            final students = (c['students_count'] as num?)?.toInt() ?? 0;
            final pdfPath  = (c['pdf_path'] ?? c['pdf_url'] ?? '') as String;

            final buttonLabel = widget.callToAction ?? 'Commencer';

            return Scaffold(
              appBar: AppBar(title: Text(title)),
              body: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('⭐ ${rating.toStringAsFixed(1)}   👥 $students'),
                    const SizedBox(height: 12),
                    const LinearProgressIndicator(value: 0),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.play_arrow),
                        label: Text(buttonLabel),
                        onPressed: pdfPath.isEmpty
                            ? null
                            : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CoursePdfPage(
                                courseId: widget.courseId,
                                userId: widget.userId,
                                path: pdfPath,
                              ),
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
