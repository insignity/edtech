part of 'auth_bloc.dart';

@immutable
sealed class AuthEvent {}

class Register extends AuthEvent {
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final String phone;

  Register({required this.email, required this.password, required this.firstName, required this.lastName, required this.phone});

  @override
  String toString(){
    return "Register(email: $email, firstName: $firstName, lastName: $lastName, phone: $phone)";
  }
}

class Login extends AuthEvent{
  final String email;
  final String password;

  Login({required this.email, required this.password});

  @override
  String toString(){
    return "Login(email: $email)";
  }
}

class Logout extends AuthEvent {}

class ForgotPassword extends AuthEvent {
  final String email;
  ForgotPassword({required this.email});

  @override
  String toString() => 'ForgotPassword(email: $email)';
}

class ResetPassword extends AuthEvent {
  final String uid;
  final String token;
  final String newPassword;

  ResetPassword({required this.uid, required this.token, required this.newPassword});

  @override
  String toString() => 'ResetPassword(uid: $uid)';
}