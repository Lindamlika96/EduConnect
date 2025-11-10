import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/login_user_usecase.dart';
import '../../domain/usecases/register_user_usecase.dart';
import '../../domain/usecases/get_user_profile_usecase.dart';
import '../../domain/usecases/logout_user_usecase.dart';
import '../../../../core/utils/session_manager.dart';
import 'package:sqflite/sqflite.dart'; // ✅ pour ConflictAlgorithm
import '../../../../core/db/app_database.dart'; // ✅ pour AppDatabase

class UserController {
  final LoginUserUseCase loginUser;
  final RegisterUserUseCase registerUser;
  final GetUserProfileUseCase getProfile;
  final LogoutUserUseCase logoutUser;

  UserController(
      this.loginUser,
      this.registerUser,
      this.getProfile,
      this.logoutUser,
      );

  /// 🔐 Connexion utilisateur
  Future<bool> login(String email, String password) async {
    final user = await loginUser.execute(email, password);
    if (user != null) {
      await SessionManager.saveSession(user.email);

      // ✅ Synchronisation locale
      final db = await AppDatabase.database;
      await db.insert(
        'users',
        {
          'name': user.name,
          'email': user.email,
          'password': user.password,
          'university': user.university,
          'role': user.role,
          'age': user.age,
          'gender': user.gender,
          'created_at': user.createdAt,
          'updated_at': user.updatedAt,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      return true;
    }
    return false;
  }


  /// 🧾 Inscription utilisateur complète
  Future<void> register({
    required String name,
    required String email,
    required String password,
    String? university,
    int? age,
    String? gender,
    String role = 'Étudiant', // ✅ valeur par défaut
  }) async {
    // Création d'une instance de UserEntity
    final user = UserEntity(
      name: name,
      email: email,
      password: password,
      university: university,
      role: role,
      age: age,
      gender: gender,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );

    // Envoi vers le use case d’enregistrement
    await registerUser.execute(user);
  }

  /// 🚪 Déconnexion utilisateur
  Future<void> logout() async {
    await logoutUser.execute();
  }
}
