import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// Gestionnaire central de la base de données locale SQLite.
/// Responsable de la création, de l’ouverture et des migrations.
class AppDatabase {
  static Database? _db;

  /// Accès unique à l’instance (singleton)
  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDatabase();
    return _db!;
  }

  /// Initialisation : ouverture ou création du fichier .db
  static Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'educonnect.db');

    // Ouvre la base et applique la structure initiale
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Création initiale des tables
  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        email TEXT,
        university TEXT
      );
    ''');

    await db.execute('''
      CREATE TABLE courses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        description TEXT,
        mentor TEXT,
        price REAL
      );
    ''');

    await db.execute('''
      CREATE TABLE quizzes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        course_id INTEGER,
        question TEXT,
        answer TEXT,
        FOREIGN KEY(course_id) REFERENCES courses(id)
      );
    ''');

    await db.execute('''
      CREATE TABLE events (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        category TEXT,
        date TEXT,
        location TEXT
      );
    ''');

    print('✅ Tables créées avec succès.');
  }

  /// Gestion des mises à jour (futures migrations)
  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    print('⚙️ Migration de la DB : $oldVersion → $newVersion');
    // Exemple : await db.execute('ALTER TABLE users ADD COLUMN avatar TEXT;');
  }

  /// Réinitialisation complète (utile pour tests)
  static Future<void> resetDatabase() async {
    final db = await database;
    await db.close();
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'educonnect.db');
    await deleteDatabase(path);
    _db = null;
    print('🗑️ Base de données supprimée puis recréée.');
  }
}
