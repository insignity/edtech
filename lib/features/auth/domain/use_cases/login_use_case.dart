import 'package:edtech/features/auth/domain/entities/token_auth.dart';
import 'package:edtech/features/auth/domain/repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<TokenEntity> execute({required String email, required String password}){
    return repository.login(email, password);
  }
}