import 'package:edtech/features/auth/domain/entities/register_entity.dart';

import '../../../../core/utils/types.dart';

class RegisterModel extends RegisterEntity {

  RegisterModel({
    required super.email,
    required super.firstName,
    required super.lastName,
    required super.phone,
  });

  factory RegisterModel.fromJson(Json json) {
    return RegisterModel(
      email: json['email'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      phone: json['phone'] as String,
    );
  }
}

//{
//   "email": "user@example12.com",
//   "first_name": "string",
//   "last_name": "string",
//   "phone": "string"
// }
