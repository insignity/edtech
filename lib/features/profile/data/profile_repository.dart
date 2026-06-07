import 'package:edtech/features/profile/data/profile_api.dart';
import 'package:edtech/features/profile/models/user_model.dart';

import '../../../core/utils/error_handler.dart';
import '../../../core/utils/my_logger.dart';

abstract class ProfileRepository {
  Future<UserModel> fetchProfile();
}

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileApi api;

  ProfileRepositoryImpl(this.api);

  @override
  Future<UserModel> fetchProfile() {
    logger.i("$this.fetchProfile() started");

    return guard<UserModel>(() async {
      final response = await api.fetchProfile();

      logger.i("$this.fetchProfile() ended");

      return response;
    });
  }
}
