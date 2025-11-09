import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:educonnect_mobile/core/db/app_database.dart';
import 'package:logger/logger.dart';

final logger = Logger();

void main() {
  // Initialize sqflite FFI for desktop testing environment
  setUpAll(() {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
  });

  group('Users Table Tests', () {
    // Before each test, reset the database to ensure a clean state
    setUp(() async {
      await AppDatabase.resetDatabase();
    });

    test('should insert a user and verify the insertion', () async {
      // 1. Get a reference to the database instance.
      final db = await AppDatabase.database;

      // 2. Define a test user model.
      final now = DateTime.now().millisecondsSinceEpoch;
      final Map<String, dynamic> testUser = {
        'name': 'John Doe',
        'email': 'john.doe@example.com',
        'password': 'password123',
        'university': 'Test University',
        'role': 'Étudiant',
        'age': 22,
        'gender': 'Homme',
        'created_at': now,
        'updated_at': now,
      };

      // 3. Insert the user into the database.
      await db.insert(
        'users',
        testUser,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // 4. Retrieve all users from the table.
      final List<Map<String, dynamic>> users = await db.query('users');

      // Log the content of the users table
      logger.i(users);

      // 5. Assert that there is exactly one user in the table.
      expect(users.length, 1);

      // 6. Verify that the retrieved user's email matches the inserted one.
      expect(users.first['email'], 'john.doe@example.com');
      expect(users.first['name'], 'John Doe');
    });
  });
}
