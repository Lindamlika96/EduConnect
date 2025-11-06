import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/user_repository.dart';
import '../dao/user_dao.dart';
import '../models/user_dto.dart';

class UserRepositoryImpl implements UserRepository {
  final UserDao dao;

  UserRepositoryImpl(this.dao);

  @override
  Future<UserEntity?> login(String email, String password) async {
    final dto = await dao.login(email, password);
    return dto?.toEntity();
  }

  @override
  Future<void> register(UserEntity user) async {
    await dao.insertUser(UserDto.fromEntity(user));
  }

  @override
  Future<UserEntity?> getUser(String email) async {
    final dto = await dao.getUserByEmail(email);
    return dto?.toEntity();
  }

  @override
  Future<void> updateUser(UserEntity user) async {
    await dao.updateUser(UserDto.fromEntity(user));
  }

  @override
  Future<void> deleteUser(int id) async {
    await dao.deleteUser(id);
  }
}
