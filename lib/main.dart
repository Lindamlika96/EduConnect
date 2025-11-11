import 'package:flutter/material.dart';
import 'app.dart';
import 'core/db/app_database.dart';

/// =============================================================
/// POINT D’ENTRÉE GLOBAL — EduConnect
/// Initialise la base SQLite puis lance l’application principale.
/// =============================================================
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ⚙️ Initialisation de la base de données locale
  final db = await AppDatabase.database;
  debugPrint('✅ Base SQLite initialisée à : ${db.path}');

  // 🚀 Lancement de l’application complète
  runApp(const EduConnectApp());
}
