import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/auth_bloc.dart';

class AuthButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;

  const AuthButton({super.key, this.onPressed, required this.text});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (_, state) {
        final isLoading = state is AuthLoading;
        return ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          child: isLoading ? const CupertinoActivityIndicator() : Text(text),
        );
      },
    );
  }
}
