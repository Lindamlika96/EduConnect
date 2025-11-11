// lib/main.dart
import 'package:flutter/material.dart';
import 'app.dart';
import 'core/db/app_database.dart';
import 'features/courses/presentation/di.dart';
import 'features/quizzes/data/dao/quiz_dao_impl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ 1️⃣ Initialiser la base de données
  final db = await AppDatabase.database;
  print('✅ Database initialisée à : ${db.path}');

  // ✅ 2️⃣ Initialiser les dépendances du module "Courses"
  // (Cela crée les 5 cours de base automatiquement via CoursesDI.init())
  final coursesDI = await CoursesDI.init();

  // ✅ 3️⃣ Initialiser le module Quiz
  final quizDao = QuizDaoImpl(AppDatabase.database);

  // ✅ 4️⃣ Récupérer les cours existants pour y associer des quiz
  final courses = await coursesDI.dao.fetchCourses();
  if (courses.isEmpty) {
    print('⚠️ Aucun cours trouvé dans la base. Les quiz ne seront pas insérés.');
  } else {
    print('📚 ${courses.length} cours trouvés — insertion des quiz associées...');
    for (final course in courses) {
      final courseId = course['id'] as int;
      print('➡️ Traitement du cours id=$courseId (${course['title']})');
      try {
        await quizDao.seedQuizWithQuestions(courseId);
      } catch (e) {
        print('❌ Erreur lors du seed du quiz pour le cours $courseId : $e');
      }
    }
  }

  print('✅ Initialisation terminée — lancement de l’application.');
  runApp(const EduConnectApp());
}
