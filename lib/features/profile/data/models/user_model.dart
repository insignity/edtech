import 'package:edtech/features/profile/domain/entities/user.dart';

import '../../../../core/utils/types.dart';

class UserModel extends UserEntity {
  UserModel({
    required super.id,
    required super.email,
    required super.firstName,
    required super.lastName,
    required super.phone,
    required super.city,
    required super.avatar,
    required super.avatarUrl,
  });

  factory UserModel.fromJson(Json json) {
    return UserModel(
      id: json['id'] as int,
      email: json['email'] as String,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      phone: json['phone'] as String?,
      city: json['city'] as String?,
      avatar: json['avatar'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
    );
  }
}
