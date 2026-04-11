part of 'profile_bloc.dart';

abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileError extends ProfileState {}

class ProfileSuccess extends ProfileState {}
