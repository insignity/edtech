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
      builder: (context, state) {
        if (state is AuthLoading) {
          return ElevatedButton(
            onPressed: null,
            child: CircularProgressIndicator(),
          );
        }else if(state is AuthError){
          return ElevatedButton(onPressed: onPressed, child: Text(state.message));
        }else if(state is AuthInitial){
          return ElevatedButton(onPressed: onPressed, child: Text(text));
        }
        return Placeholder();
      },
    );
  }
}
