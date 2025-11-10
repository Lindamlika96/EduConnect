import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:logger/logger.dart';

/// Instance globale du logger
final logger = Logger();

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
      version: 2, // migration mineure
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
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
        gender TEXT CHECK(gender IN ('Homme', 'Femme')),
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      );
    ''');
    // ✅ Insertion de l'utilisateur admin par défaut
    await db.insert('users', {
      'name': 'Admin',
      'email': 'admin@admin.com',
      'password': '123456', // en local, pas besoin de hash
      'university': 'Administration Centrale',
      'role': 'Admin',
      'age': 30,
      'gender': 'Femme',
      'created_at': DateTime.now().millisecondsSinceEpoch,
      'updated_at': DateTime.now().millisecondsSinceEpoch,
    });

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
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (course_id) REFERENCES course(id) ON DELETE CASCADE
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
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (course_id) REFERENCES course(id) ON DELETE CASCADE
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
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (course_id) REFERENCES course(id) ON DELETE CASCADE
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
        FOREIGN KEY (course_id) REFERENCES course(id) ON DELETE CASCADE,
        UNIQUE(course_id)
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
        FOREIGN KEY (quiz_id) REFERENCES quiz(id) ON DELETE CASCADE
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
        FOREIGN KEY (quiz_id) REFERENCES quiz(id) ON DELETE CASCADE,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
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
        localisation TEXT NOT NULL CHECK(localisation IN (
          'Tunis', 'Sfax', 'Sousse', 'Kairouan', 'Bizerte', 'Gabès', 'Ariana'
        )),
        date TEXT NOT NULL,
        duree_jours INTEGER NOT NULL CHECK(duree_jours >= 1),
        nombre_places INTEGER NOT NULL CHECK(nombre_places >= 0),
        niveau_importance TEXT NOT NULL CHECK(niveau_importance IN (
          'Très peu', 'Peu', 'Moyen', 'Important', 'Très important', 'Événement extraordinaire'
        )),
        niveau_exigeance TEXT NOT NULL CHECK(niveau_exigeance IN (
          'Très peu', 'Peu', 'Moyen', 'Important', 'Très important', 'Extraordinaire'
        )),
        formateur TEXT NOT NULL CHECK(formateur IN (
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
        FOREIGN KEY (evenement_id) REFERENCES events(id_evenement) ON DELETE CASCADE,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      );
    ''');

    // =====================
    // 📌 Index
    // =====================
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_course_title ON course(title);',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_course_level ON course(level);',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_course_language ON course(language);',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_course_rating ON course(rating_avg DESC, rating_count DESC);',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_quiz_course ON quiz(course_id);',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_question_quiz ON question(quiz_id);',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_result_quiz_user ON result(quiz_id, user_id);',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_bookmark_user_date ON course_bookmark(user_id, created_at DESC);',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_review_course_date ON course_review(course_id, created_at DESC);',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_progress_user_date ON course_progress(user_id, updated_at DESC);',
    );

    print('✅ Toutes les tables et index ont été créés avec succès.');
  }

  /// Migration mineure pour anciens clones
  static Future<void> _onUpgrade(
      Database db,
      int oldVersion,
      int newVersion,
      ) async {
    if (oldVersion < 2) {
      await db.execute('PRAGMA foreign_keys = ON;');
      await db.execute(
        'CREATE UNIQUE INDEX IF NOT EXISTS uq_quiz_course_id ON quiz(course_id);',
      );

      await db.execute(
        'CREATE TRIGGER IF NOT EXISTS trg_course_delete_bookmark '
            'AFTER DELETE ON course FOR EACH ROW BEGIN '
            'DELETE FROM course_bookmark WHERE course_id = OLD.id; '
            'DELETE FROM course_review WHERE course_id = OLD.id; '
            'DELETE FROM course_progress WHERE course_id = OLD.id; '
            'DELETE FROM result WHERE quiz_id IN (SELECT id FROM quiz WHERE course_id = OLD.id); '
            'DELETE FROM question WHERE quiz_id IN (SELECT id FROM quiz WHERE course_id = OLD.id); '
            'DELETE FROM quiz WHERE course_id = OLD.id; '
            'END;',
      );

      await db.execute(
        'CREATE TRIGGER IF NOT EXISTS trg_quiz_delete_children '
            'AFTER DELETE ON quiz FOR EACH ROW BEGIN '
            'DELETE FROM question WHERE quiz_id = OLD.id; '
            'DELETE FROM result WHERE quiz_id = OLD.id; '
            'END;',
      );
    }
    print(
      '⚙️ Migration de la base : version $oldVersion → $newVersion terminée.',
    );
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
  /// ✅ Met à jour le mot de passe d’un utilisateur à partir de son email
  static Future<int> updateUserPassword(String email, String newPassword) async {
    final db = await database;
    final count = await db.update(
      'users',
      {
        'password': newPassword,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'email = ?',
      whereArgs: [email],
      conflictAlgorithm: ConflictAlgorithm.abort,
    );

    if (count > 0) {
      logger.i("🔐 Mot de passe mis à jour pour $email");
    } else {
      logger.w("⚠️ Aucun utilisateur trouvé pour $email");
    }
    return count;
  }

}
