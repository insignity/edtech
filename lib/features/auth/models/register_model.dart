
import '../../../../core/utils/types.dart';

class RegisterModel  {
  final String firstName;
  final String lastName;
  final String email;
  final String phone;


  RegisterModel({
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phone,
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
