import '../../../../core/db/app_database.dart';
import '../models/user_dto.dart';

class UserDao {
  Future<int> insertUser(UserDto dto) async {
    final db = await AppDatabase.database;
    return await db.insert('users', dto.data);
  }

  Future<UserDto?> getUserByEmail(String email) async {
    final db = await AppDatabase.database;
    final res = await db.query('users', where: 'email = ?', whereArgs: [email]);
    if (res.isNotEmpty) return UserDto(res.first);
    return null;
  }

  Future<UserDto?> login(String email, String password) async {
    final db = await AppDatabase.database;
    final res = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    if (res.isNotEmpty) return UserDto(res.first);
    return null;
  }

  Future<int> updateUser(UserDto dto) async {
    final db = await AppDatabase.database;
    return await db.update(
      'users',
      dto.data,
      where: 'id = ?',
      whereArgs: [dto.data['id']],
    );
  }

  Future<int> deleteUser(int id) async {
    final db = await AppDatabase.database;
    return await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }
}
