import 'package:auto_route/annotations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:edtech/core/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/sl/injection.dart';
import '../bloc/auth_bloc.dart';

@RoutePage()
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  late final AuthBloc bloc = sl<AuthBloc>();
  final GlobalKey<FormState> _formKey = GlobalKey();

  // final PasswordValidation _validator = PasswordValidation(
  //   symbolsCaseValidate: true,
  //   upperCaseValidate: true,
  //   digitCaseValidate: true,
  // );

  final TextEditingController emailController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      bloc: bloc,
      listener: (context, state) {
        if (state is AuthSuccess) {
          // context.router.push(const RegistrationRouter());
        } else {
          // WidgetsBinding.instance.addPostFrameCallback((_) {
          //
          // });
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 32),
                        child: Text('Sign Up'),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 12,
                          left: 16,
                          right: 16,
                        ),
                        child: TextFormField(
                          controller: firstNameController,
                          decoration: const InputDecoration().copyWith(
                            label: const Text('First name'),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 12,
                          left: 16,
                          right: 16,
                        ),
                        child: TextFormField(
                          controller: lastNameController,
                          decoration: const InputDecoration().copyWith(
                            label: const Text('Last name'),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 16,
                          top: 12,
                          right: 16,
                        ),
                        child: TextFormField(
                          controller: emailController,
                          decoration: const InputDecoration(
                            label: Text('Email'),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 16,
                          top: 12,
                          right: 16,
                        ),
                        child: TextFormField(
                          controller: phoneController,
                          decoration: const InputDecoration(
                            label: Text('Phone'),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 16,
                          top: 12,
                          right: 16,
                        ),
                        child: TextFormField(
                          controller: passwordController,
                          decoration: const InputDecoration(
                            label: Text('Password'),
                          ),
                          obscureText: true,
                          obscuringCharacter: '*',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Have an account? '),
                    GestureDetector(onTap: () {
                      context.router.replace(LoginRoute());
                    }, child: Text('Sign In')),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 44),
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      bloc.add(
                        Register(
                          email: emailController.text,
                          password: passwordController.text,
                          firstName: firstNameController.text,
                          lastName: lastNameController.text,
                          phone: phoneController.text,
                        ),
                      );
                    }
                  }, //login,
                  child: Builder(
                    builder: (context) {
                      return const Text('SIGN UP');
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
