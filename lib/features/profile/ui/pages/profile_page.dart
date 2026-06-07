import 'package:auto_route/auto_route.dart';
import 'package:edtech/core/router/app_router.dart';
import 'package:edtech/core/theme/app_themes.dart';
import 'package:edtech/features/auth/ui/bloc/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/profile_bloc.dart';

@RoutePage()
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final bloc = context.read<ProfileBloc>();

  @override
  void initState() {
    bloc.add(FetchProfile());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SafeArea(
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthLoggedOut) {
              context.router.replaceAll([LoginRoute()]);
            }
          },
          child: BlocConsumer<ProfileBloc, ProfileState>(
            listener: (c, state) {},
            builder: (context, state) {
              if (state is ProfileLoaded) {
                final user = state.user;

                final fullName = [
                  user.firstName,
                  user.lastName,
                ].where((e) => e != null && e.isNotEmpty).join(' ');

                final imageUrl = user.avatarUrl ?? user.avatar;

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage: imageUrl != null
                            ? NetworkImage(imageUrl)
                            : null,
                        child: imageUrl == null
                            ? const Icon(Icons.person, size: 48)
                            : null,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        fullName.isEmpty ? 'No name' : fullName,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 24),
                      _infoTile(
                        icon: Icons.phone,
                        label: 'Phone',
                        value: user.phone ?? 'Not provided',
                      ),
                      const SizedBox(height: 12),
                      _infoTile(
                        icon: Icons.location_city,
                        label: 'City',
                        value: user.city ?? 'Not provided',
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () => context.read<AuthBloc>().add(Logout()),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.error,
                            side: const BorderSide(color: AppColors.error),
                          ),
                          child: const Text('Log out'),
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (state is ProfileLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is ProfileError) {
                return const Center(child: Text("Something went wrong"));
              }

              return const SizedBox();
            },
          ),
        ),
      ),
    );
  }

  Widget _infoTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
