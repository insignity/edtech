import 'package:edtech/core/utils/error_handler.dart';
import 'package:edtech/features/auth/data/auth_api.dart';

import '../../../core/services/token/token_service.dart';
import '../../../core/utils/my_logger.dart';
import '../models/register_model.dart';
import '../models/token_model.dart';

abstract class AuthRepository {
  Future<TokenModel> login({required String email, required String password});

  Future logout();

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
    logger.i("$this.login started");

    return guard<TokenModel>(() async {
      final token = await api.login(email, password);
      await tokenService.setAccess(token.access);

      logger.i("$this.login ended");

      return token;
    });
  }

  @override
  Future<RegisterModel> register({
    required String email,
    required String firstName,
    required String lastName,
    required String password,
    required String phone,
  }) async {
    logger.i("$this.register() started");

    return guard<RegisterModel>(() async {
      final response = await api.register(
        email: email,
        firstName: firstName,
        lastName: lastName,
        password: password,
        phone: phone,
      );

      logger.i("$this.register() ended");

      return response;
    });
  }

  @override
  Future<dynamic> logout() async {
    logger.i("$this .logout() ");
    await tokenService.deleteAccess();
  }
}
