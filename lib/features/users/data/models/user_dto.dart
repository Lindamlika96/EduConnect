import '../../domain/entities/user_entity.dart';

class UserDto {
  final Map<String, dynamic> data;

  UserDto(this.data);

  factory UserDto.fromEntity(UserEntity user) {
    return UserDto({
      'id': user.id,
      'name': user.name,
      'email': user.email,
      'password': user.password,
      'university': user.university,
      'role': user.role,
      'age': user.age,
      'gender': user.gender,
      'created_at': user.createdAt,
      'updated_at': user.updatedAt,
    });
  }

  UserEntity toEntity() {
    return UserEntity(
      id: data['id'],
      name: data['name'],
      email: data['email'],
      password: data['password'],
      university: data['university'],
      role: data['role'],
      age: data['age'],
      gender: data['gender'],
      createdAt: data['created_at'],
      updatedAt: data['updated_at'],
    );
  }
}
