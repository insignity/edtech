import 'package:edtech/core/api/api_client.dart';

import '../../../core/utils/types.dart';
import '../models/user_model.dart';

class ProfileApi {
  final ApiClient client;

  ProfileApi(this.client);

  Future<UserModel> fetchProfile() async {
    final response = await client.get("/profile/", putToken: true);
    return UserModel.fromJson(response.data as Json);
  }
}
