import '../entities/user_entity.dart';
import '../repositories/user_repository.dart';

class RegisterUserUseCase {
  final UserRepository repository;
  RegisterUserUseCase(this.repository);

  Future<void> execute(UserEntity user) async {
    await repository.register(user);
  }
}
