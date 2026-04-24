import 'package:edtech/core/api/api_client.dart';
import 'package:edtech/features/auth/data/auth_api.dart';

import '../../../core/services/token/token_service.dart';
import '../models/register_model.dart';
import '../models/token_model.dart';

abstract class AuthRepository {
  Future<TokenModel> login({required String email, required String password});

  Future<RegisterModel> register({
    required String email,
    required String firstName,
    required String lastName,
    required String password,
    required String phone,
  });
}

class AuthRepositoryImpl implements AuthRepository {
  final AuthApi api;
  final TokenService tokenService;

  AuthRepositoryImpl(this.api, this.tokenService);

  @override
  Future<TokenModel> login({
    required String email,
    required String password,
  }) async {
    final token = await api.login(email, password);
    await tokenService.setAccess(token.access);
    return token;
  }

  @override
  Future<RegisterModel> register({
    required String email,
    required String firstName,
    required String lastName,
    required String password,
    required String phone,
  }) async {
    return await api.register(
      email: email,
      firstName: firstName,
      lastName: lastName,
      password: password,
      phone: phone,
    );
  }
}
