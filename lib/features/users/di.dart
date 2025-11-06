// lib/features/users/di.dart
import 'data/dao/user_dao.dart';
import 'data/repository/user_repository_impl.dart';
import 'domain/usecases/login_user_usecase.dart';
import 'domain/usecases/register_user_usecase.dart';
import 'domain/usecases/get_user_profile_usecase.dart';
import 'domain/usecases/logout_user_usecase.dart';
import 'presentation/controllers/user_controller.dart';

UserController provideUserController() {
  final dao = UserDao();
  final repository = UserRepositoryImpl(dao);
  final login = LoginUserUseCase(repository);
  final register = RegisterUserUseCase(repository);
  final getProfile = GetUserProfileUseCase(repository);
  final logout = LogoutUserUseCase();
  return UserController(login, register, getProfile, logout);
}
