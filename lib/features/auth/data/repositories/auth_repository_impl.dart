import 'package:edtech/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:edtech/features/auth/domain/repositories/auth_repository.dart';

import '../models/register_model.dart';
import '../models/token_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource remoteDatasource;

  AuthRepositoryImpl(this.remoteDatasource);

  @override
  Future<TokenModel> login(String email, String password) async {
    return await remoteDatasource.login(email, password);
  }

  @override
  Future<RegisterModel> register({
    required String email,
    required String firstName,
    required String lastName,
    required String password,
    required String phone,
  }) async {
    return await remoteDatasource.register(
      email: email,
      firstName: firstName,
      lastName: lastName,
      password: password,
      phone: phone,
    );
  }
}
