// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'app.dart';
import 'core/db/app_database.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1) Charger le .env (ne doit plus crasher si le fichier manque)
  try {
    await dotenv.load(fileName: ".env");
    print('🔑 .env chargé (GEMINI_API_KEY présent: ${dotenv.env['GEMINI_API_KEY'] != null})');
  } catch (e) {
    print('⚠️ Impossible de charger .env : $e');
  }

  // 2) Ouvrir/initialiser la DB avant runApp pour voir le log
  try {
    final db = await AppDatabase.database;
    print('✅ Database initialisée à : ${db.path}');
  } catch (e) {
    print('❌ Échec ouverture DB : $e');
  }

  runApp(const EduConnectApp());
}
