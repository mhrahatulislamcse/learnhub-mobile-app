import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../auth/providers/auth_provider.dart';
import '../../favorites/providers/favorites_provider.dart';
import '../providers/settings_provider.dart';

/// Task 21: Settings Menu Source Code (4 points)
/// Interactive navigation drawer providing navigation, theme preferences, legal info, and authentication control
class SettingsDrawer extends StatelessWidget {
  const SettingsDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = context.watch<AuthProvider>();
    final favoritesProvider = context.watch<FavoritesProvider>();
    final settingsProvider = context.watch<SettingsProvider>();
    final user = authProvider.currentUser;

    return Drawer(
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            // Drawer Header with Profile
            _buildDrawerHeader(context, user, authProvider.isAuthenticated),

            // Navigation List Items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.home_rounded,
                    title: 'Home Dashboard',
                    onTap: () {
                      Navigator.of(context).pop();
                      context.go('/home');
                    },
                  ),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.api_rounded,
                    title: 'Open Library REST API',
                    subtitle: 'Endpoint explorer & telemetry',
                    onTap: () {
                      Navigator.of(context).pop();
                      context.push('/api-integration');
                    },
                  ),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.bookmark_rounded,
                    title: 'My Favorites',
                    badgeCount: favoritesProvider.favoritesCount,
                    onTap: () {
                      Navigator.of(context).pop();
                      context.push('/favorites');
                    },
                  ),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.person_rounded,
                    title: 'User Profile',
                    onTap: () {
                      Navigator.of(context).pop();
                      context.push('/profile');
                    },
                  ),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.notifications_active_rounded,
                    title: 'Notifications & Alerts',
                    onTap: () {
                      Navigator.of(context).pop();
                      context.push('/notifications');
                    },
                  ),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.settings_rounded,
                    title: 'Settings Screen',
                    onTap: () {
                      Navigator.of(context).pop();
                      context.push('/settings');
                    },
                  ),
                  const Divider(indent: 16, endIndent: 16),

                  // Quick Theme Switcher
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Theme Mode',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: AppColors.lightTextSecondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SegmentedButton<ThemeMode>(
                          segments: const [
                            ButtonSegment(
                              value: ThemeMode.light,
                              icon: Icon(Icons.light_mode_rounded, size: 16),
                              label: Text('Light', style: TextStyle(fontSize: 11)),
                            ),
                            ButtonSegment(
                              value: ThemeMode.dark,
                              icon: Icon(Icons.dark_mode_rounded, size: 16),
                              label: Text('Dark', style: TextStyle(fontSize: 11)),
                            ),
                            ButtonSegment(
                              value: ThemeMode.system,
                              icon: Icon(Icons.brightness_auto_rounded, size: 16),
                              label: Text('Auto', style: TextStyle(fontSize: 11)),
                            ),
                          ],
                          selected: {settingsProvider.themeMode},
                          onSelectionChanged: (selected) {
                            settingsProvider.setThemeMode(selected.first);
                          },
                        ),
                      ],
                    ),
                  ),

                  const Divider(indent: 16, endIndent: 16),

                  // Legal & Application Info
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.info_outline_rounded,
                    title: 'About LearnHub',
                    onTap: () {
                      Navigator.of(context).pop();
                      _showAboutLearnHubDialog(context);
                    },
                  ),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.privacy_tip_outlined,
                    title: 'Privacy Policy',
                    onTap: () {
                      Navigator.of(context).pop();
                      _showPrivacyPolicyDialog(context);
                    },
                  ),
                ],
              ),
            ),

            // Footer Account Action (Logout / Login)
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: authProvider.isAuthenticated
                  ? ListTile(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      tileColor: AppColors.error.withValues(alpha: 0.08),
                      leading: const Icon(Icons.logout_rounded, color: AppColors.error),
                      title: const Text(
                        'Sign Out',
                        style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold),
                      ),
                      onTap: () {
                        Navigator.of(context).pop();
                        _confirmSignOut(context, authProvider);
                      },
                    )
                  : ListTile(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      tileColor: AppColors.primary.withValues(alpha: 0.1),
                      leading: const Icon(Icons.login_rounded, color: AppColors.primary),
                      title: const Text(
                        'Sign In',
                        style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                      ),
                      onTap: () {
                        Navigator.of(context).pop();
                        context.push('/login');
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context, dynamic user, bool isAuthenticated) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(bottomRight: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.white,
                child: Text(
                  isAuthenticated && (user?.username.isNotEmpty ?? false)
                      ? user.username[0].toUpperCase()
                      : 'L',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isAuthenticated ? (user?.role.toUpperCase() ?? 'LEARNER') : 'GUEST',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            isAuthenticated ? (user?.username ?? 'Learner') : 'Welcome to LearnHub',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            isAuthenticated ? (user?.email ?? '') : 'Discover and learn anything',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    String? subtitle,
    int? badgeCount,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
      subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(fontSize: 11)) : null,
      trailing: badgeCount != null && badgeCount > 0
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$badgeCount',
                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            )
          : const Icon(Icons.chevron_right_rounded, size: 20),
      onTap: onTap,
    );
  }

  void _showAboutLearnHubDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.auto_stories_rounded, color: AppColors.primary),
            SizedBox(width: 10),
            Text('About LearnHub'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${AppConstants.appName} v1.0.0',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              'An educational mobile application built with Flutter & Firebase. '
              'Features real-time Open Library discovery, Cloud Firestore sync, '
              'local SQLite/SharedPreferences persistence, and clean architecture.',
              style: TextStyle(fontSize: 13),
            ),
            SizedBox(height: 12),
            Text(
              'Developer: Md. Rahatul Islam\nPackage: com.rahatul.learnhub',
              style: TextStyle(fontSize: 12, color: AppColors.lightTextSecondary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.security_rounded, color: AppColors.primary),
            SizedBox(width: 10),
            Text('Privacy Policy'),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Data Protection Commitment',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 6),
              Text(
                'LearnHub complies with industry data privacy standards: \n\n'
                '• Passwords are never stored in plain text and are secured by Firebase Authentication.\n'
                '• Firestore security rules restrict user profile and favorites access strictly to their authenticated owner.\n'
                '• SharedPreferences stores only non-sensitive book identifiers and theme preferences.\n'
                '• No third-party data tracking or ads are included.',
                style: TextStyle(fontSize: 13),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Understood'),
          ),
        ],
      ),
    );
  }

  void _confirmSignOut(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out of LearnHub?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.of(dialogCtx).pop();
              await authProvider.logout();
              if (context.mounted) {
                context.go('/login');
              }
            },
            child: const Text('Sign Out', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

