import '../entities/user_entity.dart';

abstract class UserRepository {
  Future<UserEntity?> login(String email, String password);
  Future<void> register(UserEntity user);
  Future<UserEntity?> getUser(String email);
  Future<void> updateUser(UserEntity user);
  Future<void> deleteUser(int id);
}
