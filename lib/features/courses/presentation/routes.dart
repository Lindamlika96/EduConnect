import 'package:educonnect_mobile/features/courses/presentation/pages/course_detail_page.dart';
import 'package:educonnect_mobile/features/courses/presentation/pages/course_list_page.dart';
import 'package:flutter/material.dart';

Route<dynamic>? coursesOnGenerateRoute(RouteSettings settings) {
  if (settings.name == '/courses') {
    return MaterialPageRoute(builder: (_) => const CourseListPage());
  }
  if (settings.name?.startsWith('/courses/') == true) {
    final idStr = settings.name!.split('/').last;
    final id = int.tryParse(idStr) ?? 0;
    return MaterialPageRoute(builder: (_) => CourseDetailPage(courseId: id));
  }
  return null;
}
