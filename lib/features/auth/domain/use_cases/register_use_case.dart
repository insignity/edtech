import 'package:edtech/features/auth/domain/entities/register_entity.dart';
import 'package:edtech/features/auth/domain/repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<RegisterEntity> execute({
    required String email,
    required String firstName,
    required String lastName,
    required String password,
    required String phone,
  }) {
    return repository.register(
      email: email,
      firstName: firstName,
      lastName: lastName,
      password: password,
      phone: phone,
    );
  }
}
