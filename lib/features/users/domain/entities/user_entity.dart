class UserEntity {
  final int? id;
  final String name;
  final String email;
  final String password;
  final String? university;
  final String role;
  final int? age;
  final String? gender;
  final int createdAt;
  final int updatedAt;

  const UserEntity({
    this.id,
    required this.name,
    required this.email,
    required this.password,
    this.university,
    this.role = 'Étudiant',
    this.age,
    this.gender,
    required this.createdAt,
    required this.updatedAt,
  });
}
