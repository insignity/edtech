part of 'profile_bloc.dart';

abstract class ProfileEvent {}

class FetchProfile extends ProfileEvent {}

class LogoutProfile extends ProfileEvent {}
