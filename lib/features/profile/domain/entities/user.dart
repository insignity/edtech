class UserEntity {
  final int id;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? city;
  final String? avatar;
  final String? avatarUrl;

  UserEntity({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.city,
    required this.avatar,
    required this.avatarUrl,
  });
}
