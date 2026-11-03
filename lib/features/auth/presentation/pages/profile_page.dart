import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  void _showEditProfileDialog(BuildContext context, String currentName, String currentRole) {
    final nameController = TextEditingController(text: currentName);
    String selectedRole = currentRole;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit Profile'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextField(
                    label: 'Display Name',
                    controller: nameController,
                  ),
                  const SizedBox(height: 16),
                  const Text('Role', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: selectedRole,
                    items: const [
                      DropdownMenuItem(value: 'student', child: Text('Student / Learner')),
                      DropdownMenuItem(value: 'instructor', child: Text('Instructor')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => selectedRole = val);
                    },
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final newName = nameController.text.trim();
                    if (newName.isNotEmpty) {
                      dialogContext.read<AuthBloc>().add(
                            UpdateProfileEvent(
                              displayName: newName,
                              role: selectedRole,
                            ),
                          );
                      Navigator.of(dialogContext).pop();
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.error),
            tooltip: 'Sign Out',
            onPressed: () {
              context.read<AuthBloc>().add(SignOutRequestedEvent());
            },
          ),
        ],
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Unauthenticated) {
            context.goNamed(AppRoutes.loginName);
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
            );
          }
        },
        builder: (context, state) {
          if (state is! Authenticated) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.person_off_outlined, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text('You are currently not signed in', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 24),
                    CustomButton(
                      text: 'Sign In',
                      onPressed: () => context.goNamed(AppRoutes.loginName),
                    ),
                  ],
                ),
              ),
            );
          }

          final user = state.user;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // Avatar with Role Ring
                Center(
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 54,
                        backgroundColor: AppColors.primaryLight,
                        child: Text(
                          user.displayName.isNotEmpty ? user.displayName[0].toUpperCase() : 'U',
                          style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.verified_rounded,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Name & Role Badge
                Text(
                  user.displayName,
                  style: theme.textTheme.headlineMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: user.role == 'instructor'
                        ? AppColors.secondary.withValues(alpha: 0.15)
                        : AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    user.role.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: user.role == 'instructor' ? AppColors.secondary : AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Profile Details Card
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.person_outline, color: AppColors.primary),
                        title: const Text('Display Name'),
                        subtitle: Text(user.displayName),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 20),
                          onPressed: () => _showEditProfileDialog(context, user.displayName, user.role),
                        ),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.email_outlined, color: AppColors.primary),
                        title: const Text('Email Address'),
                        subtitle: Text(user.email),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.badge_outlined, color: AppColors.primary),
                        title: const Text('Account Role'),
                        subtitle: Text(user.role == 'instructor' ? 'Course Creator / Instructor' : 'Learner / Student'),
                      ),
                      if (user.createdAt != null) ...[
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.calendar_today_outlined, color: AppColors.primary),
                          title: const Text('Member Since'),
                          subtitle: Text(
                            '${user.createdAt!.year}-${user.createdAt!.month.toString().padLeft(2, '0')}-${user.createdAt!.day.toString().padLeft(2, '0')}',
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Sign Out Button
                CustomButton(
                  text: 'Sign Out',
                  isOutlined: true,
                  icon: const Icon(Icons.logout_rounded, color: AppColors.primary),
                  onPressed: () {
                    context.read<AuthBloc>().add(SignOutRequestedEvent());
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

