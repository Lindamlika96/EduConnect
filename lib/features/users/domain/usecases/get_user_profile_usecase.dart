import '../entities/user_entity.dart';
import '../repositories/user_repository.dart';

class GetUserProfileUseCase {
  final UserRepository repository;
  GetUserProfileUseCase(this.repository);

  Future<UserEntity?> execute(String email) async {
    return await repository.getUser(email);
  }
}
