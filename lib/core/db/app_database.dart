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
    // =====================
    // 🧍 Table USERS
    // =====================
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        university TEXT,
        role TEXT CHECK(role IN ('Étudiant', 'Professeur', 'Admin')) DEFAULT 'Étudiant',
        age INTEGER,
        gender TEXT CHECK(gender IN ('Homme', 'Femme', 'Autre')),
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      );
    ''');

    // =====================
    // 📚 Table COURSE
    // =====================
    await db.execute('''
      CREATE TABLE course (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        mentor_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        description_html TEXT NOT NULL DEFAULT '',
        level INTEGER NOT NULL DEFAULT 1,
        language INTEGER NOT NULL DEFAULT 0,
        duration_minutes INTEGER NOT NULL DEFAULT 0,
        pdf_url TEXT,
        pdf_path TEXT,
        thumbnail_url TEXT,
        thumbnail_path TEXT,
        rating_avg REAL NOT NULL DEFAULT 0.0,
        rating_count INTEGER NOT NULL DEFAULT 0,
        students_count INTEGER NOT NULL DEFAULT 0,
        summary_text TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      );
    ''');

    // =====================
    // 🔖 Table COURSE_BOOKMARK
    // =====================
    await db.execute('''
      CREATE TABLE course_bookmark (
        user_id INTEGER NOT NULL,
        course_id INTEGER NOT NULL,
        created_at INTEGER NOT NULL,
        PRIMARY KEY (user_id, course_id),
        FOREIGN KEY (user_id) REFERENCES users(id),
        FOREIGN KEY (course_id) REFERENCES course(id)
      );
    ''');

    // =====================
    // ⭐ Table COURSE_REVIEW
    // =====================
    await db.execute('''
      CREATE TABLE course_review (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        course_id INTEGER NOT NULL,
        rating INTEGER NOT NULL CHECK(rating BETWEEN 1 AND 5),
        comment TEXT,
        created_at INTEGER NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(id),
        FOREIGN KEY (course_id) REFERENCES course(id)
      );
    ''');

    // =====================
    // 📈 Table COURSE_PROGRESS
    // =====================
    await db.execute('''
      CREATE TABLE course_progress (
        user_id INTEGER NOT NULL,
        course_id INTEGER NOT NULL,
        progress_percent REAL NOT NULL DEFAULT 0.0,
        updated_at INTEGER NOT NULL,
        PRIMARY KEY (user_id, course_id),
        FOREIGN KEY (user_id) REFERENCES users(id),
        FOREIGN KEY (course_id) REFERENCES course(id)
      );
    ''');

    // =====================
    // 🧠 Table QUIZ
    // =====================
    await db.execute('''
      CREATE TABLE quiz (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        course_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        FOREIGN KEY (course_id) REFERENCES course(id)
      );
    ''');

    // =====================
    // ❓ Table QUESTION
    // =====================
    await db.execute('''
      CREATE TABLE question (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        quiz_id INTEGER NOT NULL,
        text TEXT NOT NULL,
        option_a TEXT NOT NULL,
        option_b TEXT NOT NULL,
        option_c TEXT NOT NULL,
        option_d TEXT NOT NULL,
        correct_index INTEGER NOT NULL CHECK(correct_index BETWEEN 0 AND 3),
        theme TEXT,
        explanation TEXT,
        difficulty TEXT NOT NULL DEFAULT 'facile',
        FOREIGN KEY (quiz_id) REFERENCES quiz(id)
      );
    ''');

    // =====================
    // 🏆 Table RESULT
    // =====================
    await db.execute('''
      CREATE TABLE result (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        quiz_id INTEGER NOT NULL,
        user_id INTEGER NOT NULL,
        score INTEGER NOT NULL,
        total INTEGER NOT NULL,
        date TEXT NOT NULL,
        FOREIGN KEY (quiz_id) REFERENCES quiz(id),
        FOREIGN KEY (user_id) REFERENCES users(id)
      );
    ''');

    // =====================
    // 🎟️ Table EVENTS
    // =====================
    await db.execute('''
      CREATE TABLE events (
        id_evenement INTEGER PRIMARY KEY AUTOINCREMENT,
        titre TEXT NOT NULL,
        description TEXT,
        localisation TEXT CHECK(localisation IN (
          'Tunis', 'Sfax', 'Sousse', 'Kairouan', 'Bizerte', 'Gabès', 'Ariana'
        )),
        date TEXT,
        duree_jours INTEGER,
        nombre_places INTEGER,
        niveau_importance TEXT CHECK(niveau_importance IN (
          'Très peu', 'Peu', 'Moyen', 'Important', 'Très important', 'Événement extraordinaire'
        )),
        niveau_exigeance TEXT CHECK(niveau_exigeance IN (
          'Très peu', 'Peu', 'Moyen', 'Important', 'Très important', 'Extraordinaire'
        )),
        formateur TEXT CHECK(formateur IN (
          'Élève Université', 'Étudiant bénévole', 'Professeur Université', 'Expert', 'PDG'
        ))
      );
    ''');

    // =====================
    // 🧾 Table EVENEMENT_PARTICIPATION
    // =====================
    await db.execute('''
      CREATE TABLE evenement_participation (
        evenement_id INTEGER NOT NULL,
        user_id INTEGER NOT NULL,
        status TEXT CHECK(status IN ('participe', 'favori', 'ne participe pas')) NOT NULL,
        PRIMARY KEY (evenement_id, user_id),
        FOREIGN KEY (evenement_id) REFERENCES events(id_evenement),
        FOREIGN KEY (user_id) REFERENCES users(id)
      );
    ''');

    print('✅ Toutes les tables ont été créées avec succès.');
  }

  /// Gestion des mises à jour (futures migrations)
  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    print('⚙️ Migration de la base : version $oldVersion → $newVersion');
  }

  /// Réinitialisation complète de la base (utile pour tests)
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
