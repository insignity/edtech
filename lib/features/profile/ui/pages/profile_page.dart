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
            listener: (context, state) {
              if (state is ProfileDeleted) {
                // account is gone on the server — clear tokens and leave
                context.read<AuthBloc>().add(Logout());
              }
              if (state is ProfileDeleteError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to delete account: ${state.message}'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
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
                      const SizedBox(height: 12),
                      _NavTile(
                        icon: Icons.history_rounded,
                        label: 'Speaking History',
                        onTap: () =>
                            context.router.push(const SpeakingHistoryRoute()),
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
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () => _showDeleteAccountDialog(context),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.error,
                        ),
                        child: const Text('Delete Account'),
                      ),
                    ],
                  ),
                );
              }

              if (state is ProfileLoading || state is ProfileDeleting) {
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

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => _DeleteAccountDialog(
        onConfirm: () {
          Navigator.of(dialogContext).pop();
          bloc.add(DeleteAccount());
        },
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

/// An `_infoTile` that leads somewhere.
class _NavTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _NavTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

class _DeleteAccountDialog extends StatefulWidget {
  final VoidCallback onConfirm;

  const _DeleteAccountDialog({required this.onConfirm});

  @override
  State<_DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<_DeleteAccountDialog> {
  final _controller = TextEditingController();
  bool _confirmed = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final matches = _controller.text.trim().toLowerCase() == 'delete';
      if (matches != _confirmed) {
        setState(() => _confirmed = matches);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: AppColors.error),
          SizedBox(width: 8),
          Expanded(child: Text('Delete Account?')),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'This will permanently delete your account, subscriptions, '
            'and learning progress. This action cannot be undone.',
          ),
          const SizedBox(height: 16),
          const Text(
            'Type "delete" to confirm:',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _controller,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'delete'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _confirmed ? widget.onConfirm : null,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.error,
            disabledBackgroundColor: AppColors.error.withValues(alpha: 0.3),
          ),
          child: const Text('Delete Forever'),
        ),
      ],
    );
  }
}
