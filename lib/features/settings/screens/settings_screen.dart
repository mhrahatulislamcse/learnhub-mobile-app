import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/custom_button.dart';
import '../../auth/providers/auth_provider.dart';
import '../../favorites/providers/favorites_provider.dart';
import '../providers/settings_provider.dart';

/// Task 24: Settings Screen Source Code (4 points)
/// Screen 9: Settings Screen providing complete preference management,
/// theme switching, notification controls, data management, and session control.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = context.watch<AuthProvider>();
    final settingsProvider = context.watch<SettingsProvider>();
    final favoritesProvider = context.watch<FavoritesProvider>();
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        children: [
          // Section 1: Appearance & Theme
          _buildSectionHeader(context, 'Appearance & Theme', Icons.palette_outlined),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: AppColors.lightBorder),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Select Application Theme',
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Choose how LearnHub appears on your device. Auto adapts dynamically to system mode.',
                    style: TextStyle(fontSize: 12, color: AppColors.lightTextSecondary),
                  ),
                  const SizedBox(height: 16),
                  SegmentedButton<ThemeMode>(
                    segments: const [
                      ButtonSegment(
                        value: ThemeMode.system,
                        icon: Icon(Icons.brightness_auto_rounded),
                        label: Text('System'),
                      ),
                      ButtonSegment(
                        value: ThemeMode.light,
                        icon: Icon(Icons.light_mode_rounded),
                        label: Text('Light'),
                      ),
                      ButtonSegment(
                        value: ThemeMode.dark,
                        icon: Icon(Icons.dark_mode_rounded),
                        label: Text('Dark'),
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
          ),
          const SizedBox(height: 20),

          // Section 2: Notifications
          _buildSectionHeader(context, 'Notifications', Icons.notifications_none_rounded),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: AppColors.lightBorder),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  value: settingsProvider.notificationsEnabled,
                  title: const Text('Push & Local Notifications'),
                  subtitle: const Text('Receive study reminders and discovery alerts'),
                  secondary: const Icon(Icons.notifications_active_rounded, color: AppColors.primary),
                  onChanged: (val) => settingsProvider.setNotificationsEnabled(val),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.tune_rounded, color: AppColors.primary),
                  title: const Text('Configure Notifications & Alerts'),
                  subtitle: const Text('Test immediate alert and schedule daily reminders'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push('/notifications'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Section 3: Account & Profile
          _buildSectionHeader(context, 'Account & Profile', Icons.person_outline_rounded),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: AppColors.lightBorder),
            ),
            child: authProvider.isAuthenticated && user != null
                ? Column(
                    children: [
                      ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primary,
                          child: Text(
                            user.username.isNotEmpty ? user.username[0].toUpperCase() : 'U',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Text(user.username, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${user.email} • ${user.role}'),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () => context.push('/profile'),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.lock_reset_rounded, color: AppColors.primary),
                        title: const Text('Reset Password'),
                        subtitle: const Text('Send password reset link to your email'),
                        onTap: () async {
                          final success = await authProvider.resetPassword(user.email);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  success
                                      ? 'Password reset link sent to ${user.email}'
                                      : 'Failed to send password reset email',
                                ),
                                backgroundColor: success ? AppColors.success : AppColors.error,
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  )
                : ListTile(
                    leading: const Icon(Icons.login_rounded, color: AppColors.primary),
                    title: const Text('Sign In to LearnHub'),
                    subtitle: const Text('Access user profile and sync bookmarks'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => context.push('/login'),
                  ),
          ),
          const SizedBox(height: 20),

          // Section 4: Data & Local Storage
          _buildSectionHeader(context, 'Data & Local Storage', Icons.storage_rounded),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: AppColors.lightBorder),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.bookmark_border_rounded, color: AppColors.primary),
                  title: const Text('Active Saved Favorites'),
                  subtitle: Text('${favoritesProvider.favoritesCount} books stored in local memory'),
                  trailing: TextButton(
                    onPressed: () => context.push('/favorites'),
                    child: const Text('View'),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                  title: const Text('Clear Favorites Cache'),
                  subtitle: const Text('Wipe all locally persisted bookmarks from device'),
                  onTap: () => _confirmClearFavorites(context, settingsProvider, favoritesProvider),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Section 5: Legal & About
          _buildSectionHeader(context, 'About & Information', Icons.info_outline_rounded),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: AppColors.lightBorder),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.auto_stories_rounded, color: AppColors.primary),
                  title: const Text('About LearnHub'),
                  subtitle: const Text('Version 1.0.0 • Production Build'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => _showAboutDialog(context),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.security_rounded, color: AppColors.primary),
                  title: const Text('Privacy Policy'),
                  subtitle: const Text('Data security & encryption details'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => _showPrivacyDialog(context),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.description_outlined, color: AppColors.primary),
                  title: const Text('Terms of Service'),
                  subtitle: const Text('Educational use guidelines'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => _showTermsDialog(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Section 6: Sign Out Button
          if (authProvider.isAuthenticated) ...[
            CustomButton(
              text: 'Sign Out of LearnHub',
              icon: const Icon(Icons.logout_rounded, color: Colors.white),
              backgroundColor: AppColors.error,
              textColor: Colors.white,
              onPressed: () => _confirmSignOut(context, authProvider),
            ),
            const SizedBox(height: 16),
          ],

          // Footer
          Center(
            child: Text(
              '${AppConstants.appName} v1.0.0 (Build 1) • com.rahatul.learnhub',
              style: theme.textTheme.bodySmall?.copyWith(color: AppColors.lightTextSecondary),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
          ),
        ],
      ),
    );
  }

  void _confirmClearFavorites(
    BuildContext context,
    SettingsProvider settingsProvider,
    FavoritesProvider favoritesProvider,
  ) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Clear Favorites Cache?'),
        content: const Text(
          'This will remove all saved books from your device local storage. '
          'Online Firestore bookmarks will remain safe in the cloud.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.of(dialogCtx).pop();
              final ok = await settingsProvider.clearFavoritesCache(favoritesProvider);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(ok ? 'Local favorites cleared' : 'Failed to clear favorites'),
                    backgroundColor: ok ? AppColors.success : AppColors.error,
                  ),
                );
              }
            },
            child: const Text('Clear', style: TextStyle(color: Colors.white)),
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

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.auto_stories_rounded, color: AppColors.primary),
            SizedBox(width: 8),
            Text('About LearnHub'),
          ],
        ),
        content: const Text(
          'LearnHub is a production-grade educational and book discovery application '
          'developed with Flutter, Firebase Authentication, Cloud Firestore, and Open Library REST API. '
          'Built with Clean Architecture and Provider state management.\n\n'
          'Developer: Md. Rahatul Islam\n'
          'Package: com.rahatul.learnhub',
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

  void _showPrivacyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.security_rounded, color: AppColors.primary),
            SizedBox(width: 8),
            Text('Privacy Policy'),
          ],
        ),
        content: const Text(
          'LearnHub strictly respects user privacy:\n\n'
          '1. Authentication passwords are encrypted through Firebase Auth and never stored in plain text.\n'
          '2. User profiles and favorites are protected by granular Firestore security rules.\n'
          '3. Device storage only caches non-confidential preferences (theme, notification switches, and book IDs).\n'
          '4. No telemetry or data is sold or shared with third parties.',
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

  void _showTermsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.description_outlined, color: AppColors.primary),
            SizedBox(width: 8),
            Text('Terms of Service'),
          ],
        ),
        content: const Text(
          'By using LearnHub, you agree to:\n\n'
          '• Utilize Open Library catalog and learning materials for personal, educational exploration.\n'
          '• Refrain from unauthorized access attempts or abusive API requests.\n'
          '• Maintain accurate account credentials.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Agree'),
          ),
        ],
      ),
    );
  }
}
