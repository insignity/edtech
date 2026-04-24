import 'package:edtech/features/profile/domain/entities/user.dart';

abstract class ProfileRepository {
  Future<UserEntity> fetchProfile();
}