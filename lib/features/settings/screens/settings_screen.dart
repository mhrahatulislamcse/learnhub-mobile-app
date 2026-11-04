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
/// Replicates Figma Screen 08 (Settings) with theme, notification, and account preferences
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final settingsProvider = context.watch<SettingsProvider>();
    final favoritesProvider = context.watch<FavoritesProvider>();
    final user = authProvider.currentUser;

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: AppColors.lightBackground,
        elevation: 0,
        title: const Text(
          'Settings',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.primary),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        children: [
          // Figma 08 Section: Preferences
          const Text(
            'Preferences',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),

          // 1. Appearance / Theme Preference Card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: AppColors.lightBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Appearance & Theme',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Choose your preferred theme',
                          style: TextStyle(fontSize: 10, color: AppColors.lightTextSecondary),
                        ),
                      ],
                    ),
                    Text(
                      settingsProvider.themeMode == ThemeMode.light
                          ? 'Light mode'
                          : settingsProvider.themeMode == ThemeMode.dark
                              ? 'Dark mode'
                              : 'System mode',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.secondary),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SegmentedButton<ThemeMode>(
                  segments: const [
                    ButtonSegment(
                      value: ThemeMode.system,
                      label: Text('System', style: TextStyle(fontSize: 11)),
                    ),
                    ButtonSegment(
                      value: ThemeMode.light,
                      label: Text('Light', style: TextStyle(fontSize: 11)),
                    ),
                    ButtonSegment(
                      value: ThemeMode.dark,
                      label: Text('Dark', style: TextStyle(fontSize: 11)),
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
          const SizedBox(height: 12),

          // 2. Language Preference Card (Figma 08)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: AppColors.lightBorder),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Language',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'App display language',
                      style: TextStyle(fontSize: 10, color: AppColors.lightTextSecondary),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      'English',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.secondary),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.chevron_right_rounded, color: AppColors.lightTextSecondary, size: 18),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Section 2: Notifications
          const Text(
            'Notifications',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),

          // 3. Reading Reminders Switch Card (Figma 08)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: AppColors.lightBorder),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Push & Local Notifications',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Get a gentle daily reminder and updates',
                        style: TextStyle(fontSize: 10, color: AppColors.lightTextSecondary),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: settingsProvider.notificationsEnabled,
                  activeColor: AppColors.secondary,
                  onChanged: (val) => settingsProvider.setNotificationsEnabled(val),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 4. Configure Notifications Action Card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: AppColors.lightBorder),
            ),
            child: InkWell(
              onTap: () => context.push('/notifications'),
              child: const Row(
                children: [
                  Icon(Icons.tune_rounded, color: AppColors.secondary, size: 20),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Configure Notifications & Alerts',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Test immediate alert and schedule daily reminders',
                          style: TextStyle(fontSize: 10, color: AppColors.lightTextSecondary),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: AppColors.lightTextSecondary),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Figma 08 Section: Account & Profile
          const Text(
            'Account & Profile',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),

          // Account summary or Sign in
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.lightBorder),
            ),
            child: InkWell(
              onTap: () {
                if (authProvider.isAuthenticated) {
                  context.push('/profile');
                } else {
                  context.push('/login');
                }
              },
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: AppColors.pillBlue,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        user?.username.isNotEmpty ?? false ? user!.username[0].toUpperCase() : 'U',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.secondary),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.username ?? 'Sign In to LearnHub',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          user != null ? '${user.email} • ${user.role}' : 'Access profile and sync bookmarks',
                          style: const TextStyle(fontSize: 10, color: AppColors.lightTextSecondary),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: AppColors.lightTextSecondary),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Change password (Figma 08)
          _buildActionCard(
            title: 'Change password',
            subtitle: 'Update your account password',
            onTap: () async {
              if (user != null) {
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
              } else {
                context.push('/login');
              }
            },
          ),
          const SizedBox(height: 10),

          // Privacy (Figma 08)
          _buildActionCard(
            title: 'Privacy Policy',
            subtitle: 'Manage your data and privacy',
            onTap: () => _showPrivacyDialog(context),
          ),
          const SizedBox(height: 24),

          // Section 4: Data & Local Storage
          const Text(
            'Data & Local Storage',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.lightBorder),
            ),
            child: Row(
              children: [
                const Icon(Icons.bookmark_border_rounded, color: AppColors.secondary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Active Saved Favorites',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${favoritesProvider.favoritesCount} books stored in local memory',
                        style: const TextStyle(fontSize: 10, color: AppColors.lightTextSecondary),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => context.push('/favorites'),
                  child: const Text('View', style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          _buildActionCard(
            title: 'Clear Favorites Cache',
            subtitle: 'Wipe all locally persisted bookmarks from device',
            isDestructive: true,
            onTap: () => _confirmClearFavorites(context, settingsProvider, favoritesProvider),
          ),
          const SizedBox(height: 24),

          // Section 5: Legal & About
          const Text(
            'About & Information',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),

          _buildActionCard(
            title: 'About LearnHub',
            subtitle: 'Version 1.0.0 • Production Build',
            onTap: () => _showAboutDialog(context),
          ),
          const SizedBox(height: 10),

          _buildActionCard(
            title: 'Terms of Service',
            subtitle: 'Educational use guidelines',
            onTap: () => _showTermsDialog(context),
          ),
          const SizedBox(height: 24),

          // Sign Out Action Button
          if (authProvider.isAuthenticated) ...[
            CustomButton(
              text: 'Sign Out of LearnHub',
              backgroundColor: AppColors.error,
              textColor: Colors.white,
              icon: const Icon(Icons.logout_rounded, color: Colors.white, size: 18),
              onPressed: () async {
                await authProvider.logout();
                if (context.mounted) {
                  context.go('/login');
                }
              },
            ),
            const SizedBox(height: 20),
          ],

          // Footer Build Information
          const Center(
            child: Text(
              'Package: com.rahatul.learnhub\nVersion: 1.0.0+1',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                color: AppColors.lightTextSecondary,
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.lightBorder),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isDestructive ? AppColors.error : AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.lightTextSecondary, size: 18),
            ],
          ),
        ),
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
      builder: (ctx) => AlertDialog(
        title: const Text('Clear Favorites Cache?'),
        content: const Text(
          'This action will remove all saved bookmarks from local storage. '
          'Cloud bookmarks can be re-synchronized after signing in.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.pop(ctx);
              await settingsProvider.clearCache();
              await favoritesProvider.loadFavorites();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Favorites cache cleared successfully'),
                    backgroundColor: AppColors.success,
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

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.auto_stories_rounded, color: AppColors.secondary),
            SizedBox(width: 10),
            Text('About LearnHub'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('LearnHub v1.0.0', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 8),
            Text(
              'A modern educational learning and book discovery mobile app built with Flutter and Firebase. '
              'Developed for students and academic researchers worldwide.',
              style: TextStyle(fontSize: 13),
            ),
            SizedBox(height: 12),
            Text(
              'Author: Md. Rahatul Islam\nPackage: com.rahatul.learnhub',
              style: TextStyle(fontSize: 11, color: AppColors.lightTextSecondary),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
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
            Icon(Icons.security_rounded, color: AppColors.secondary),
            SizedBox(width: 10),
            Text('Privacy Policy'),
          ],
        ),
        content: const SingleChildScrollView(
          child: Text(
            'We value your privacy:\n\n'
            '• Credentials are encrypted via Firebase Authentication.\n'
            '• Local storage uses SharedPreferences strictly on-device.\n'
            '• No sensitive metrics or third-party ads are tracked.\n'
            '• Firestore rules restrict profile access to authenticated account holders.',
            style: TextStyle(fontSize: 13),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Understood')),
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
            Icon(Icons.description_outlined, color: AppColors.secondary),
            SizedBox(width: 10),
            Text('Terms of Service'),
          ],
        ),
        content: const SingleChildScrollView(
          child: Text(
            'By using LearnHub, you agree to the following terms:\n\n'
            '• Open Library content is provided under open-source and open-library API licenses.\n'
            '• For personal educational and learning research purposes only.\n'
            '• Respect copyright and intellectual property rights of respective book authors.',
            style: TextStyle(fontSize: 13),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Agree')),
        ],
      ),
    );
  }
}
