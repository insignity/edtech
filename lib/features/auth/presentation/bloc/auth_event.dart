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
    return "Register(email: $email, password: $password, firstName: $firstName, lastName: $lastName, phone: $phone)";
  }
}

class Login extends AuthEvent{
  final String email;
  final String password;

  Login({required this.email, required this.password});

  @override
  String toString(){
    return "Login(email: $email, password: $password)";
  }
}