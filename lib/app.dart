import 'package:flutter/material.dart';

import 'core/routing/app_scaffold.dart';

// Détail & PDF
import 'features/courses/presentation/pages/course_detail_page.dart';
import 'features/courses/presentation/pages/course_pdf_page.dart';

class EduConnectApp extends StatelessWidget {
  const EduConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EduConnect',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2D6CDF)),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(centerTitle: false, elevation: 0),
      ),

      // Onglets (Accueil / Mes cours / Favoris / Profil placeholder)
      home: const AppScaffold(),

      // Routes
      onGenerateRoute: (settings) {
        // ---------- /course/detail ----------
        if (settings.name == '/course/detail') {
          final args = settings.arguments;

          // On accepte deux formats:
          // 1) arguments = int (courseId seul) → userId=1 par défaut
          if (args is int) {
            return MaterialPageRoute(
              builder: (_) => CourseDetailPage(courseId: args, userId: 1),
            );
          }

          // 2) arguments = Map {'courseId': int, 'userId': int?}
          if (args is Map) {
            final int courseId = args['courseId'] as int;
            final int userId =
            (args['userId'] is int) ? args['userId'] as int : 1;
            return MaterialPageRoute(
              builder: (_) => CourseDetailPage(courseId: courseId, userId: userId),
            );
          }

          // Mauvais format d’arguments
          return MaterialPageRoute(
            builder: (_) => const _RouteErrorPage(
              message:
              'Arguments invalides pour /course/detail (attendu: int ou {courseId, userId?}).',
            ),
          );
        }

        // ---------- /course/pdf ----------
        if (settings.name == '/course/pdf') {
          // Attend: {courseId:int, path:String, userId:int}
          final args = settings.arguments as Map?;
          if (args == null ||
              !args.containsKey('courseId') ||
              !args.containsKey('path') ||
              !args.containsKey('userId')) {
            return MaterialPageRoute(
              builder: (_) => const _RouteErrorPage(
                message:
                'Arguments manquants pour /course/pdf (courseId, path, userId).',
              ),
            );
          }
          final int courseId = args['courseId'] as int;
          final String path = args['path'] as String;
          final int userId = args['userId'] as int;
          return MaterialPageRoute(
            builder: (_) =>
                CoursePdfPage(courseId: courseId, path: path, userId: userId),
          );
        }

        return null; // laisser l'erreur par défaut si route inconnue
      },
    );
  }
}

class _RouteErrorPage extends StatelessWidget {
  final String message;
  const _RouteErrorPage({required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Navigation')),
      body: Center(child: Text(message)),
    );
  }
}
