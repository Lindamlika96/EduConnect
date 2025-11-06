import 'package:flutter/material.dart';
import 'package:educonnect_mobile/core/widgets/dummy_widget.dart';

import 'features/courses/presentation/pages/course_list_page.dart';

class EduConnectApp extends StatelessWidget {
  const EduConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EduConnect',
      debugShowCheckedModeBanner: false,
      home: CourseListPage(), // 👈 pour tester rapidement
    );
  }
}
