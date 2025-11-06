import '../entities/user_entity.dart';
import '../repositories/user_repository.dart';

class LoginUserUseCase {
  final UserRepository repository;
  LoginUserUseCase(this.repository);

  Future<UserEntity?> execute(String email, String password) async {
    return await repository.login(email, password);
  }
}
