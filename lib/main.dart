import 'package:educonnect_mobile/features/courses/presentation/di.dart';
import 'package:flutter/material.dart';
import 'app.dart';
import 'core/db/app_database.dart';

import 'features/quizzes/data/dao/quiz_dao_impl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final db = await AppDatabase.database;
  print('✅ Database initialisée à : ${db.path}');

  // 👉 Initialisation des dépendances Courses (seed auto de 5 cours via di.dart)
  final coursesDI = await CoursesDI.init();

  // 👉 Initialisation QuizDao
  final quizDao = QuizDaoImpl(AppDatabase.database);

  // 👉 Récupérer tous les cours existants
  final courses = await coursesDI.dao.fetchCourses();

  // 👉 Debug : afficher les IDs et titres des cours
  for (final c in courses) {
    print('📚 DEBUG: course id=${c['id']} title=${c['title']}');
  }

  if (courses.isNotEmpty) {
    for (final course in courses) {
      final courseId = course['id'] as int;
      print('📚 Cours trouvé avec id = $courseId');

      // 👉 Insérer un quiz lié à ce cours
      await quizDao.seedQuizWithQuestions(courseId);
      print('📝 Quiz inséré pour le cours $courseId');
    }
  } else {
    print('❌ Aucun cours trouvé, impossible d’insérer des quiz.');
  }

  // 👉 Lancer ton app EduConnect
  runApp(const EduConnectApp());
}
