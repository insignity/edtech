part of 'profile_bloc.dart';

abstract class ProfileEvent {}

class FetchProfile extends ProfileEvent {}

class DeleteAccount extends ProfileEvent {}
