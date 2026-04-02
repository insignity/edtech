import '../entities/register_entity.dart';
import '../entities/token_auth.dart';

abstract class AuthRepository {
  Future<TokenEntity> login(String email, String password);

  Future<RegisterEntity> register({
    required String email,
    required String firstName,
    required String lastName,
    required String password,
    required String phone,
  });
}
