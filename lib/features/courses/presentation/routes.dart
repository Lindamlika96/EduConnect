import 'package:flutter/material.dart';

import 'pages/course_list_page.dart';
import 'pages/course_detail_page.dart';

Route<dynamic>? coursesOnGenerateRoute(RouteSettings settings) {
  // Optional arguments: expect a Map like {'userId': 1}
  final args = settings.arguments;
  final int userId =
  (args is Map && args['userId'] is int) ? args['userId'] as int : 1;

  if (settings.name == '/courses') {
    return MaterialPageRoute(builder: (_) => CourseListPage(userId: userId));
  }

  if (settings.name?.startsWith('/courses/') == true) {
    final idStr = settings.name!.split('/').last;
    final id = int.tryParse(idStr) ?? 0;
    return MaterialPageRoute(
      builder: (_) => CourseDetailPage(
        courseId: id,
        userId: userId, // ✅ required now
      ),
    );
  }

  return null;
}
