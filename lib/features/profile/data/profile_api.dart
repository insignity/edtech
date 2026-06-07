import 'package:edtech/core/api/api_client.dart';
import 'package:edtech/core/services/token/token_service.dart';

import '../../../core/utils/types.dart';
import '../models/user_model.dart';

class ProfileApi {
  final ApiClient client;
  final TokenService _tokenService;

  ProfileApi(this.client, this._tokenService);

  Future<UserModel> fetchProfile() async {
    final response = await client.get("/profile/", putToken: true);
    return UserModel.fromJson(response.data as Json);
  }

  Future logout() async {
    await _tokenService.deleteAccess();
  }
}
