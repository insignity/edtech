import 'dart:convert';

import 'package:edtech/core/api/api_client.dart';

import '../models/user_model.dart';

abstract class ProfileRemoteDataSource {
  Future<UserModel> fetchProfile();
}

class ProfileRemoteDatasource implements ProfileRemoteDataSource{
  final ApiClient client;

  ProfileRemoteDatasource({required this.client});


  @override
  Future<UserModel> fetchProfile() async {
    try {
      final response = await client.get("/profile/");
      return UserModel.fromJson(jsonDecode(response as String));
    }catch(e){
      throw Exception('bad response');
    }
  }

}