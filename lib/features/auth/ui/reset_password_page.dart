import 'package:auto_route/auto_route.dart';
import 'package:edtech/core/router/app_router.dart';
import 'package:edtech/core/theme/app_themes.dart';
import 'package:edtech/core/widgets/keyboard_hider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../shared/extensions/extensions.dart';
import 'bloc/auth_bloc.dart';

@RoutePage()
class ResetPasswordPage extends StatefulWidget {
  final String uid;
  final String token;

  const ResetPasswordPage({
    super.key,
    @QueryParam('uid') this.uid = '',
    @QueryParam('token') this.token = '',
  });

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final TextEditingController newPasswordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey();
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Set New Password'),
        leading: BackButton(onPressed: () => context.router.pop()),
      ),
      body: SafeArea(
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthPasswordResetSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Password reset successfully!'),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
              context.router.replaceAll([LoginRoute()]);
            } else if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            }
          },
          child: KeyboardHider(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 24),
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.lock_open_rounded,
                        color: AppColors.primary,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text('Set new password', style: context.text.headlineMedium),
                    const SizedBox(height: 8),
                    Text(
                      'Choose a strong new password for your account.',
                      style: context.text.bodyMedium,
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: newPasswordController,
                      obscureText: _obscurePassword,
                      validator: (v) =>
                          v == null || v.length < 8 ? 'Min 8 characters' : null,
                      decoration: InputDecoration(
                        labelText: 'New Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        return ElevatedButton(
                          onPressed: state is AuthLoading
                              ? null
                              : () {
                                  if (_formKey.currentState!.validate()) {
                                    context.read<AuthBloc>().add(
                                      ResetPassword(
                                        uid: widget.uid,
                                        token: widget.token,
                                        newPassword: newPasswordController.text,
                                      ),
                                    );
                                  }
                                },
                          child: state is AuthLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.white,
                                  ),
                                )
                              : const Text('RESET PASSWORD'),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    newPasswordController.dispose();
    super.dispose();
  }
}
