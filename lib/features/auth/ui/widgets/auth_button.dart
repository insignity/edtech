import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/auth_bloc.dart';

class AuthButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;

  const AuthButton({super.key, this.onPressed, required this.text});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (_, state) {
        if (state is AuthLoading) {
          return ElevatedButton(
            onPressed: null,
            child: CupertinoActivityIndicator(),
          );
        } else if (state is AuthError) {
          return ElevatedButton(onPressed: onPressed, child: Text(text));
        } else if (state is AuthInitial) {
          return ElevatedButton(onPressed: onPressed, child: Text(text));
        }
        return SizedBox.shrink();
      },
    );
  }
}
