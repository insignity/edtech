import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';



import '../bloc/auth_bloc.dart';

@RoutePage()
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {

          if(state is AuthInitial){
            Text("Initial state");
          }else if(state is AuthLoading){
            CircularProgressIndicator();
          }else if (state is AuthError){
            Text(state.message);
          }else{
            Text("success");
          }

         return SizedBox.shrink();
        },
      ),
    );
  }
}
//
// class Register extends StatefulWidget {
//   final VoidCallback onChange;
//
//   const Register({Key? key, required this.onChange}) : super(key: key);
//
//   @override
//   State<Register> createState() => _RegisterState();
// }
//
// class _RegisterState extends State<Register> {
//   final AuthBloc bloc = sl<AuthBloc>();
//   final GlobalKey<FormState> _formKey = GlobalKey();
//
//   final PasswordValidation _validator = PasswordValidation(
//     symbolsCaseValidate: true,
//     upperCaseValidate: true,
//     digitCaseValidate: true,
//   );
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocConsumer<AuthBloc, AuthState>(
//       bloc: bloc,
//       listener: (context, state) {
//         if (state.status) {
//           context.router.push(const RegistrationRouter());
//         } else {
//           WidgetsBinding.instance.addPostFrameCallback((_) {
//             _formKey.currentState!.validate();
//           });
//         }
//       },
//       builder: (context, state) {
//         return Scaffold(
//           backgroundColor: Colors.white,
//           body: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               Expanded(
//                 child: Form(
//                   key: _formKey,
//                   child: ListView(
//                     padding: EdgeInsets.zero,
//                     children: [
//                       Row(
//                         children: [
//                           const Expanded(flex: 2, child: SizedBox.shrink()),
//                           Expanded(
//                             child: Image.asset(AppImages.astronautOnCorner),
//                           ),
//                         ],
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.only(left: 32),
//                         child: Text(
//                           'Sign Up',
//                           style: AppTextStyle.txt24w700 + AppColors.blue,
//                         ),
//                       ),
//                       Padding(
//                         padding:
//                         const EdgeInsets.only(top: 12, left: 16, right: 16),
//                         child: TextFormField(
//                           validator: (text) => state.usernameValidator,
//                           onChanged: (text) =>
//                               bloc.add(
//                                 AuthEvent.onChangeUsername(text),
//                               ),
//                           decoration: const InputDecoration().copyWith(
//                             label: const Text('User name'),
//                           ),
//                         ),
//                       ),
//                       Padding(
//                         padding:
//                         const EdgeInsets.only(left: 16, top: 12, right: 16),
//                         child: TextFormField(
//                           validator: (text) => state.emailValidator,
//                           onChanged: (text) =>
//                               bloc.add(
//                                 AuthEvent.onChangeEmail(text),
//                               ),
//                           decoration: const InputDecoration(
//                             label: Text('Email'),
//                           ),
//                         ),
//                       ),
//                       Padding(
//                         padding:
//                         const EdgeInsets.only(left: 16, top: 12, right: 16),
//                         child: TextFormField(
//                           obscureText: true,
//                           obscuringCharacter: '*',
//                           validator: (text) => state.passwordValidator,
//                           onChanged: (text) =>
//                               bloc.add(
//                                 AuthEvent.onChangePassword(text),
//                               ),
//                           decoration: const InputDecoration(
//                             label: Text('Password'),
//                           ),
//                         ),
//                       ),
//                       Padding(
//                         padding:
//                         const EdgeInsets.only(left: 16, top: 12, right: 16),
//                         child: TextFormField(
//                           decoration: const InputDecoration(
//                             label: Text('Repeat password'),
//                           ),
//                           validator: (text) => state.passwordRepeatValidator,
//                           onChanged: (text) =>
//                               bloc.add(
//                                 AuthEvent.onChangeRepeatPassword(text),
//                               ),
//                           obscureText: true,
//                           obscuringCharacter: '*',
//                         ),
//                       ),
//                       // const Padding(
//                       //   padding: EdgeInsets.only(top: 16),
//                       //   child: Text(
//                       //     'Or sign in with',
//                       //     textAlign: TextAlign.center,
//                       //   ),
//                       // ),
//                       // Padding(
//                       //   padding: const EdgeInsets.only(top: 12),
//                       //   child: Row(
//                       //     mainAxisAlignment: MainAxisAlignment.center,
//                       //     crossAxisAlignment: CrossAxisAlignment.center,
//                       //     children: [
//                       //       SvgPicture.asset(AppIcons.facebook),
//                       //       const SizedBox(width: 24),
//                       //       SvgPicture.asset(AppIcons.google),
//                       //       const SizedBox(width: 24),
//                       //       SvgPicture.asset(AppIcons.twitter),
//                       //     ],
//                       //   ),
//                       // ),
//                     ],
//                   ),
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.only(bottom: 12),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text(
//                       'Have an account? ',
//                       style: AppTextStyle.txt16w400.copyWith(
//                         color: AppColors.grey1,
//                       ),
//                     ),
//                     GestureDetector(
//                       onTap: widget.onChange,
//                       child: Text(
//                         'Sign In',
//                         style: AppTextStyle.txt16w400.copyWith(
//                           color: AppColors.blue,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Container(
//                 padding: const EdgeInsets.only(left: 16, right: 16, bottom: 44),
//                 child: ElevatedButton(
//                   onPressed: () {
//                     if (_formKey.currentState!.validate()) {
//                       bloc.add(const AuthEvent.register());
//                     }
//                   }, //login,
//                   child: Builder(builder: (context) {
//                     if (state.isLoading) {
//                       return const CupertinoActivityIndicator(
//                         color: AppColors.white,
//                       );
//                     }
//                     return const Text('SIGN UP');
//                   }),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }
