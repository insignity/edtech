import 'package:edtech/features/profile/data/profile_api.dart';
import 'package:edtech/features/profile/models/user_model.dart';

import '../../../core/utils/error_handler.dart';
import '../../../core/utils/my_logger.dart';

abstract class ProfileRepository {
  Future<UserModel> fetchProfile();

  Future<void> deleteAccount();
}

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileApi api;

  ProfileRepositoryImpl(this.api);

  @override
  Future<UserModel> fetchProfile() {
    return guard<UserModel>(() async {
      final result = await api.fetchProfile();
      logger.i('-> $result');
      return result;
    });
  }

  @override
  Future<void> deleteAccount() {
    return guard<void>(() async {
      await api.deleteAccount();
    });
  }
}
