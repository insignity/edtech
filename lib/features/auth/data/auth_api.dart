import 'package:edtech/core/api/api_client.dart';

import '../../../core/utils/types.dart';
import '../models/password_reset_model.dart';
import '../models/register_model.dart';
import '../models/token_model.dart';

class AuthApi {
  final ApiClient api;

  AuthApi(this.api);

  Future<TokenModel> login(String email, String password) async {
    try {
      final response = await api.post(
        '/token/',
        data: {'email': email, 'password': password},
      );
      return TokenModel.fromJson(response.data as Json);
    } catch (e) {
      throw Exception(e);
    }
  }

  //{
  //   "refresh": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3NTcxMTg0MiwiaWF0IjoxNzc1MTA3MDQyLCJqdGkiOiJjZGFkN2I4MGRmMzA0ZjI1YmJmODFiNmVkNDJjZDllNSIsInVzZXJfaWQiOiI3In0.880m1cjfR3ma38_hRDZru1x-XPsvENFBZ9SLYUNKHww",
  //   "access": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzc1MTEwNjQyLCJpYXQiOjE3NzUxMDcwNDIsImp0aSI6ImE4YWVkZGU3MDMxNDRmYmM4MDBmMGNiYzIyMTNiODc1IiwidXNlcl9pZCI6IjcifQ.eQEQFTTy5L2VsJgN-GROlE0shRzTVQ75tN02EDJ6_ck"
  // }

  Future<PasswordResetModel> forgotPassword(String email) async {
    final response = await api.post(
      '/password-reset/',
      data: {'email': email},
      putToken: false,
    );
    return PasswordResetModel.fromJson(response.data as Json);
  }

  Future<void> resetPassword({
    required String uid,
    required String token,
    required String newPassword,
  }) async {
    await api.post(
      '/password-reset-confirm/',
      data: {'uid': uid, 'token': token, 'new_password': newPassword},
      putToken: false,
    );
  }

  Future<RegisterModel> register({
    required String email,
    required String firstName,
    required String lastName,
    required String password,
    required String phone,
  }) async {
    final response = await api.post(
      '/register/',
      data: {
        'email': email,
        'password': password,
        'first_name': firstName,
        'last_name': lastName,
        'phone': phone,
      },
    );
    return RegisterModel.fromJson(response.data as Json);
  }
}
