import 'package:flutter_test/flutter_test.dart';
import 'package:educonnect_mobile/core/db/app_database.dart';
import 'package:educonnect_mobile/features/quizzes/data/dao/quiz_dao_impl.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';


void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  TestWidgetsFlutterBinding.ensureInitialized();

  group('🧪 Vérification de l’insertion des seeds', () {
    late QuizDaoImpl quizDao;

    setUpAll(() async {
      // 🧹 Réinitialise la base
      await AppDatabase.resetDatabase();
      final db = await AppDatabase.database;

      quizDao = QuizDaoImpl(Future.value(db));

      // ✅ Ajout d’un cours factice pour satisfaire la contrainte FOREIGN KEY
      await db.insert('course', {
        'mentor_id': 1,
        'title': 'Cours test Algo',
        'description_html': 'Cours de test pour seed Quiz Algo',
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      });

      await db.insert('course', {
        'mentor_id': 1,
        'title': 'Cours test Flutter',
        'description_html': 'Cours de test pour seed Quiz Flutter',
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      });

      await db.insert('course', {
        'mentor_id': 1,
        'title': 'Cours test SQL',
        'description_html': 'Cours de test pour seed Quiz SQL',
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      });

      await db.insert('course', {
        'mentor_id': 1,
        'title': 'Cours test Réseaux',
        'description_html': 'Cours de test pour seed Quiz Réseaux',
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      });

      await db.insert('course', {
        'mentor_id': 1,
        'title': 'Cours test IA',
        'description_html': 'Cours de test pour seed Quiz IA',
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      });

      // 🚀 Insertion des seeds de quiz après les cours
      await quizDao.initSeeds();
    });

    test('Les seeds de quiz ont été insérés', () async {
      final db = await AppDatabase.database;

      final quizCount = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM quiz'))!;
      final questionCount = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM question'))!;

      print('🧩 Nombre de quiz trouvés : $quizCount');
      print('🧠 Nombre de questions trouvées : $questionCount');

      expect(quizCount > 0, true, reason: 'Aucun quiz inséré dans la table quiz.');
      expect(questionCount > 0, true,
          reason: 'Aucune question insérée dans la table question.');
    });
  });
}
