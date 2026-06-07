import 'package:auto_route/auto_route.dart';
import 'package:edtech/core/router/app_router.dart';
import 'package:edtech/core/theme/app_themes.dart';
import 'package:edtech/core/utils/validators/email_validator.dart';
import 'package:edtech/core/widgets/keyboard_hider.dart';
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
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: KeyboardHider(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 48),
                  // Logo
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.school_rounded, color: AppColors.white, size: 40),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Welcome back!',
                    style: context.text.headlineMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Sign in to continue learning',
                    style: context.text.bodyMedium,
                  ),
                  const SizedBox(height: 36),
                  TextFormField(
                    controller: emailController,
                    validator: validateEmail,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () => context.router.push(const ForgotPasswordRoute()),
                      child: Text(
                        'Forgot password?',
                        style: context.text.bodyMedium! + AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: RichText(
                      text: TextSpan(
                        style: context.text.bodyMedium,
                        children: [
                          const TextSpan(text: 'By continuing, you agree to our '),
                          TextSpan(
                            text: 'Terms of Use',
                            style: context.text.bodyMedium! + AppColors.primary,
                          ),
                          const TextSpan(text: ' and '),
                          TextSpan(
                            text: 'Privacy Policy.',
                            style: context.text.bodyMedium! + AppColors.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  BlocListener<AuthBloc, AuthState>(
                    listener: (_, state) {
                      if (state is AuthSuccess) {
                        context.router.replaceAll([NavBarRoute()]);
                      } else if (state is AuthError) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(state.message),
                            backgroundColor: AppColors.error,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        );
                      }
                    },
                    child: BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        return AuthButton(
                          onPressed: state is AuthLoading ? null : () {
                            if (_formKey.currentState!.validate()) {
                              context.read<AuthBloc>().add(
                                Login(
                                  email: emailController.text.trim(),
                                  password: passwordController.text,
                                ),
                              );
                            }
                          },
                          text: state is AuthLoading ? "Signing in..." : "SIGN IN",
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Don't have an account? ", style: context.text.bodyMedium),
                      GestureDetector(
                        onTap: () => context.router.replace(RegisterRoute()),
                        child: Text(
                          'Sign up',
                          style: context.text.bodyMedium! +
                              AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
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
