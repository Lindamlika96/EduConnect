import 'package:flutter/widgets.dart';
import 'app.dart';
import 'core/db/app_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final db = await AppDatabase.database;
  print('✅ Database initialisée à : ${db.path}');
  runApp(const EduConnectApp());
}
