import 'package:edtech/features/profile/domain/entities/user.dart';
import 'package:edtech/features/profile/domain/repositories/profile_repository.dart';

import '../datasources/profile_remote_data_source.dart';
class ProfileRepositoryImpl  implements ProfileRepository{
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl(this.remoteDataSource);
  @override
  Future<UserEntity> fetchProfile() {
    // TODO: implement fetchProfile
    throw UnimplementedError();
  }
}


//TODO: ADD API INTERCEPTORS TO SEND TOKEN
//TODO: ADD API LOGGER INTERCEPTOR