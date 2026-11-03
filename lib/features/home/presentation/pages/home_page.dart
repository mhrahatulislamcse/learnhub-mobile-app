import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_stories_rounded, color: AppColors.primary, size: 24),
            SizedBox(width: 8),
            Text(AppConstants.appName),
          ],
        ),
        actions: [
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is Authenticated) {
                return IconButton(
                  icon: CircleAvatar(
                    radius: 14,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      state.user.displayName.isNotEmpty ? state.user.displayName[0].toUpperCase() : 'U',
                      style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  tooltip: 'View Profile',
                  onPressed: () => context.pushNamed(AppRoutes.profileName),
                );
              }
              return IconButton(
                icon: const Icon(Icons.account_circle_outlined),
                tooltip: 'Sign In',
                onPressed: () => context.pushNamed(AppRoutes.loginName),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notifications will arrive in Phase 3')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Phase 2 • Authentication & User Management Active',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      final name = state is Authenticated ? state.user.displayName : 'Learner';
                      return Text(
                        'Welcome, $name!',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Full Authentication with email/password, roles, and profile management enabled.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Authentication Status Card
            Text(
              'Authentication & Profile Status',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                if (state is Authenticated) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: state.user.role == 'instructor'
                                    ? AppColors.secondary
                                    : AppColors.primary,
                                child: Text(
                                  state.user.displayName.isNotEmpty
                                      ? state.user.displayName[0].toUpperCase()
                                      : 'U',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      state.user.displayName,
                                      style: theme.textTheme.titleMedium,
                                    ),
                                    Text(
                                      state.user.email,
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: state.user.role == 'instructor'
                                      ? AppColors.secondary.withValues(alpha: 0.15)
                                      : AppColors.primary.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  state.user.role.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: state.user.role == 'instructor'
                                        ? AppColors.secondary
                                        : AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          CustomButton(
                            text: 'Manage Profile',
                            isOutlined: true,
                            height: 40,
                            icon: const Icon(Icons.manage_accounts_outlined, size: 18),
                            onPressed: () => context.pushNamed(AppRoutes.profileName),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.info.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.person_outline, color: AppColors.info),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Not Signed In', style: theme.textTheme.titleMedium),
                                  Text(
                                    'Sign in or register to unlock courses and progress tracking',
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: CustomButton(
                                text: 'Sign In',
                                height: 42,
                                onPressed: () => context.pushNamed(AppRoutes.loginName),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: CustomButton(
                                text: 'Sign Up',
                                isOutlined: true,
                                height: 42,
                                onPressed: () => context.pushNamed(AppRoutes.registerName),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // Features Checklist
            Text(
              'Phase 2 Authentication Features',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            _buildCheckItem(
              context,
              title: 'Email & Password Auth',
              subtitle: 'Firebase Authentication integration with form validation',
              icon: Icons.password_rounded,
              isCompleted: true,
            ),
            _buildCheckItem(
              context,
              title: 'Role-Based Profiles',
              subtitle: 'Student and Instructor roles stored in Cloud Firestore',
              icon: Icons.assignment_ind_outlined,
              isCompleted: true,
            ),
            _buildCheckItem(
              context,
              title: 'Password Recovery',
              subtitle: 'Send password reset emails via Firebase Auth',
              icon: Icons.lock_reset_rounded,
              isCompleted: true,
            ),
            _buildCheckItem(
              context,
              title: 'Profile Management',
              subtitle: 'View user credentials, update display name and role',
              icon: Icons.badge_outlined,
              isCompleted: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckItem(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isCompleted,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                  Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            Icon(
              isCompleted ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
              color: isCompleted ? AppColors.success : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
