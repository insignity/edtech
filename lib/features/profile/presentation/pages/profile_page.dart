import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';

@RoutePage()
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: Center(child: Text("Profile page"))),
    );
  }
}
