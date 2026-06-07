import 'package:edtech/core/utils/error_handler.dart';
import 'package:edtech/features/auth/data/auth_api.dart';

import '../../../core/services/token/token_service.dart';
import '../../../core/utils/my_logger.dart';
import '../models/password_reset_model.dart';
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

  Future<PasswordResetModel> forgotPassword(String email);

  Future<void> resetPassword({
    required String uid,
    required String token,
    required String newPassword,
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
      await tokenService.setRefresh(token.refresh);

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
    await tokenService.deleteAll();
  }

  @override
  Future<PasswordResetModel> forgotPassword(String email) async {
    logger.i("$this.forgotPassword() started");
    return guard<PasswordResetModel>(() async {
      final result = await api.forgotPassword(email);
      logger.i("$this.forgotPassword() ended");
      return result;
    });
  }

  @override
  Future<void> resetPassword({
    required String uid,
    required String token,
    required String newPassword,
  }) async {
    logger.i("$this.resetPassword() started");
    await guard<void>(() async {
      await api.resetPassword(uid: uid, token: token, newPassword: newPassword);
      logger.i("$this.resetPassword() ended");
    });
  }
}
