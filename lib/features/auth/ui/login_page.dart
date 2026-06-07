import 'package:auto_route/auto_route.dart';
import 'package:edtech/core/router/app_router.dart';
import 'package:edtech/core/theme/app_themes.dart';
import 'package:edtech/core/utils/validators/email_validator.dart';
import 'package:edtech/core/widgets/keyboard_hider.dart';
import 'package:edtech/features/auth/ui/widgets/welcome_video.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../shared/extensions/extensions.dart';
import 'bloc/auth_bloc.dart';
import 'widgets/auth_button.dart';

@RoutePage()
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with EmailValidator {
  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: KeyboardHider(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  WelcomeVideo(),
                  ElevatedButton(
                    onPressed: () {
                      context.read<AuthBloc>().add(
                        Login(email: "aero@mail.ru", password: "aeroaero123"),
                      );
                    },
                    child: Text("Login cheatcode"),
                  ),
                  Text(
                    'Sign In',
                    style: context.text.headlineMedium! + AppColors.primary,
                    textAlign: TextAlign.center,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 16,
                      top: 12,
                      right: 16,
                    ),
                    child: TextFormField(
                      controller: emailController,
                      validator: validateEmail,
                      decoration: InputDecoration(
                        label: Row(
                          children: [
                            Text('Email'),
                            Text('*', style: TextStyle() + AppColors.red),
                          ],
                        ),
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
                      decoration: InputDecoration(
                        label: Row(
                          children: [
                            Text('Password'),
                            Text('*', style: TextStyle() + AppColors.red),
                          ],
                        ),
                      ),
                      obscureText: true,
                      obscuringCharacter: '*',
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 8, left: 16, right: 16),
                    child: RichText(
                      text: TextSpan(
                        style:
                            context.text.bodyMedium! +
                            AppColors.gray.withAlpha(150),
                        children: [
                          TextSpan(text: 'By continuing, you agree to our '),
                          TextSpan(
                            text: 'Terms of Use',
                            style:
                                context.text.bodyMedium! +
                                AppColors.primary.withAlpha(150),
                          ),
                          const TextSpan(text: ' and '),
                          TextSpan(
                            text: 'Privacy Policy.',
                            style:
                                context.text.bodyMedium! +
                                AppColors.primary.withAlpha(150),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12, top: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: context.text.bodyLarge!,
                        ),
                        GestureDetector(
                          onTap: () {
                            context.router.replace(RegisterRoute());
                          },
                          child: Text(
                            'Sign up',
                            style: context.text.bodyLarge! + AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      bottom: 44,
                    ),
                    child: BlocListener<AuthBloc, AuthState>(
                      listener: (_, state) {
                        if (state is AuthSuccess) {
                          context.router.replaceAll([CoursesRoute()]);
                        } else if (state is AuthError) {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text('Error'),
                                content: Text(state.message),
                                actions: [
                                  TextButton(
                                    onPressed: () => context.router.pop(),
                                    child: Text('OK'),
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      },
                      child: AuthButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            context.read<AuthBloc>().add(
                              Login(
                                email: emailController.text,
                                password: passwordController.text,
                              ),
                            );
                          }
                        },
                        text: "SIGN IN",
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
