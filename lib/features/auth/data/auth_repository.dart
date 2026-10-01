import 'package:edtech/core/utils/error_handler.dart';
import 'package:edtech/features/auth/data/auth_api.dart';
import 'package:edtech/features/recording/data/services/speaking_attempt_store.dart';

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
  final SpeakingAttemptStore attemptStore;

  AuthRepositoryImpl(this.api, this.tokenService, this.attemptStore);

  @override
  Future<TokenModel> login({
    required String email,
    required String password,
  }) async {
    return guard<TokenModel>(() async {
      final token = await api.login(email, password);
      await tokenService.setAccess(token.access);
      await tokenService.setRefresh(token.refresh);
      logger.i('-> $token');
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
    return guard<RegisterModel>(() async {
      final result = await api.register(
        email: email,
        firstName: firstName,
        lastName: lastName,
        password: password,
        phone: phone,
      );
      logger.i('-> $result');
      return result;
    });
  }

  @override
  Future<dynamic> logout() async {
    logger.i('AuthRepository.logout');
    await tokenService.deleteAll();
    // Cached attempts carry the previous learner's transcripts.
    attemptStore.clear();
  }

  @override
  Future<PasswordResetModel> forgotPassword(String email) async {
    return guard<PasswordResetModel>(() async {
      final result = await api.forgotPassword(email);
      logger.i('-> $result');
      return result;
    });
  }

  @override
  Future<void> resetPassword({
    required String uid,
    required String token,
    required String newPassword,
  }) async {
    await guard<void>(() async {
      await api.resetPassword(uid: uid, token: token, newPassword: newPassword);
    });
  }
}
