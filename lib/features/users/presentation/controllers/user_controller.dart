import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/login_user_usecase.dart';
import '../../domain/usecases/register_user_usecase.dart';
import '../../domain/usecases/get_user_profile_usecase.dart';
import '../../domain/usecases/logout_user_usecase.dart';
import '../../../../core/utils/session_manager.dart';

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

  /// Connexion utilisateur
  Future<bool> login(String email, String password) async {
    final user = await loginUser.execute(email, password);
    if (user != null) {
      await SessionManager.saveSession(user.email);
      return true;
    }
    return false;
  }

  /// Inscription utilisateur (corrigée)
  Future<void> register({
    required String name,
    required String email,
    required String password,
    String? university,
    int? age,
    String? gender,
  }) async {
    final user = UserEntity(
      name: name,
      email: email,
      password: password,
      university: university,
      age: age,
      gender: gender,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );

    await registerUser.execute(user);
  }

  /// Déconnexion
  Future<void> logout() async => await logoutUser.execute();
}
