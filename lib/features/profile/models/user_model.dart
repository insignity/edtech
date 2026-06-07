import '../../../../core/utils/types.dart';

class UserModel {
  final int id;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? city;
  final String? avatar;
  final String? avatarUrl;

  UserModel({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName,
    this.phone,
    this.city,
    this.avatar,
    this.avatarUrl,
  });

  factory UserModel.fromJson(Json json) {
    return UserModel(
      id: json['id'] as int,
      email: json['email'] as String,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      phone: json['phone'] as String?,
      city: json['city'] as String?,
      avatar: json['avatar'] as String?,
      avatarUrl: json['avatar_url'] as String?,
    );
  }
}
