import 'package:flutter/widgets.dart'; // ⚠️ À ajouter tout en haut
import 'package:sqflite/sqflite.dart';
import 'app_database.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // ✅ Correction obligatoire ici

  print('🚀 Initialisation de la base de données EduConnect...');
  await AppDatabase.resetDatabase(); // ✅ Supprime et recrée la base proprement
  final db = await AppDatabase.database;


  final tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' ORDER BY name;"
  );

  print('📋 Liste des tables présentes :');
  for (var table in tables) {
    print('   ➜ ${table['name']}');
  }

  print('\n🧪 Test d’insertion dans la table users...');
  await db.insert('users', {
    'name': 'Linda',
    'email': 'linda@example.com',
    'password': '1234',
    'university': 'ESPRIT',
    'role': 'Étudiant',
    'age': 23,
    'gender': 'Femme',
    'created_at': DateTime.now().millisecondsSinceEpoch,
    'updated_at': DateTime.now().millisecondsSinceEpoch,
  });

  final users = await db.query('users');
  print('👤 Utilisateurs dans la base :');
  for (var user in users) {
    print('   ➜ ${user['name']} (${user['email']})');
  }

  print('\n✅ Test terminé avec succès.');
}
