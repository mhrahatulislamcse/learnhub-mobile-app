import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../providers/notification_provider.dart';
import '../services/notification_service.dart';

/// Task 26: Notification Implementation Source Code (4 points)
/// Screen 10: Notification Configuration & Alert Screen
/// Demonstrates notification channel configuration, permission handling,
/// instant test notifications, and scheduled daily study reminders.
class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final _titleController = TextEditingController(text: 'Time to Learn!');
  final _bodyController = TextEditingController(
    text: 'Explore new books and continue your learning streak on LearnHub.',
  );

  TimeOfDay _selectedTime = const TimeOfDay(hour: 20, minute: 0);
  bool _isTriggering = false;

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _pickTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat('hh:mm a').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final notifProvider = context.watch<NotificationProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Center'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // 1. Permission Status Banner
          _buildPermissionBanner(context, notifProvider),
          const SizedBox(height: 18),

          // 2. Channel Configuration Card (Task 27)
          _buildSectionHeader(context, 'Notification Channel Settings', Icons.tune_rounded),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: AppColors.lightBorder),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'ANDROID CHANNEL',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle_rounded, size: 14, color: AppColors.success),
                            SizedBox(width: 4),
                            Text(
                              'Active',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.success),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  _buildConfigRow('Channel ID', NotificationService.channelIdReminders),
                  const SizedBox(height: 8),
                  _buildConfigRow('Channel Name', NotificationService.channelNameReminders),
                  const SizedBox(height: 8),
                  _buildConfigRow('Importance', 'High (Heads-up alert & sound)'),
                  const SizedBox(height: 8),
                  _buildConfigRow('Vibration & Audio', 'Enabled'),
                  const SizedBox(height: 8),
                  _buildConfigRow('Schedule Mode', 'ExactAlarm (exactAllowWhileIdle)'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // 3. Instant Test Notification Card (Task 28)
          _buildSectionHeader(context, 'Trigger Test Notification', Icons.notifications_active_rounded),
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
                    'Send an immediate notification to test display title, body, and notification shade appearance.',
                    style: theme.textTheme.bodySmall?.copyWith(color: AppColors.lightTextSecondary),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: 'Notification Title',
                      prefixIcon: const Icon(Icons.title_rounded, color: AppColors.primary),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _bodyController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: 'Notification Body',
                      prefixIcon: const Icon(Icons.message_rounded, color: AppColors.primary),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  CustomButton(
                    text: _isTriggering ? 'Triggering...' : 'Trigger Test Notification',
                    icon: const Icon(Icons.send_rounded, color: Colors.white),
                    isLoading: _isTriggering,
                    onPressed: () async {
                      setState(() => _isTriggering = true);
                      final ok = await notifProvider.sendTestNotification(
                        title: _titleController.text.trim(),
                        body: _bodyController.text.trim(),
                      );
                      setState(() => _isTriggering = false);

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              ok
                                  ? 'Alert dispatched: "${_titleController.text}"'
                                  : 'Failed to trigger notification',
                            ),
                            backgroundColor: ok ? AppColors.success : AppColors.error,
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // 4. Scheduled Study Reminders Card (Task 27)
          _buildSectionHeader(context, 'Scheduled Study Reminders', Icons.alarm_rounded),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: AppColors.lightBorder),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Daily Study Reminder', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text('Recurring daily notification to reinforce reading habits'),
                    value: notifProvider.dailyReminderEnabled,
                    onChanged: (val) async {
                      if (val) {
                        await notifProvider.scheduleDailyReminder(
                          hour: _selectedTime.hour,
                          minute: _selectedTime.minute,
                        );
                      } else {
                        await notifProvider.cancelDailyReminder();
                      }
                    },
                  ),
                  const Divider(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.schedule_rounded, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Scheduled Time: ${_formatTimeOfDay(_selectedTime)}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const Spacer(),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.edit_calendar_rounded, size: 16),
                        label: const Text('Change'),
                        onPressed: () => _pickTime(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  CustomButton(
                    text: 'Save Scheduled Reminder',
                    icon: const Icon(Icons.alarm_on_rounded, color: Colors.white),
                    isOutlined: true,
                    onPressed: () async {
                      final ok = await notifProvider.scheduleDailyReminder(
                        hour: _selectedTime.hour,
                        minute: _selectedTime.minute,
                      );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              ok
                                  ? 'Study reminder scheduled daily at ${_formatTimeOfDay(_selectedTime)}'
                                  : 'Failed to schedule reminder',
                            ),
                            backgroundColor: ok ? AppColors.success : AppColors.error,
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // 5. Notification History & Activity
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSectionHeader(context, 'Notification Activity', Icons.history_rounded),
              if (notifProvider.recentAlerts.isNotEmpty)
                TextButton(
                  onPressed: () => notifProvider.clearAlertHistory(),
                  child: const Text('Clear Log'),
                ),
            ],
          ),
          if (notifProvider.recentAlerts.isEmpty)
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: AppColors.lightBorder),
              ),
              child: const Padding(
                padding: EdgeInsets.all(24.0),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.notifications_none_rounded, size: 40, color: AppColors.lightTextSecondary),
                      SizedBox(height: 8),
                      Text(
                        'No notification history yet.',
                        style: TextStyle(color: AppColors.lightTextSecondary),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            ...notifProvider.recentAlerts.map((alert) {
              final timestamp = alert['timestamp'] as DateTime;
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    child: Icon(
                      alert['type'] == 'Daily Schedule'
                          ? Icons.alarm_rounded
                          : Icons.notifications_active_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    alert['title'] as String,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  subtitle: Text(
                    alert['body'] as String,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: Text(
                    DateFormat('HH:mm').format(timestamp),
                    style: const TextStyle(fontSize: 11, color: AppColors.lightTextSecondary),
                  ),
                ),
              );
            }),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildPermissionBanner(BuildContext context, NotificationProvider notifProvider) {
    final isGranted = notifProvider.isPermissionGranted;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: (isGranted ? AppColors.success : AppColors.warning).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: (isGranted ? AppColors.success : AppColors.warning).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isGranted ? Icons.check_circle_rounded : Icons.warning_amber_rounded,
            color: isGranted ? AppColors.success : AppColors.warning,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isGranted ? 'Notifications Allowed' : 'Permission Required',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isGranted ? AppColors.success : AppColors.warning,
                    fontSize: 13,
                  ),
                ),
                Text(
                  isGranted
                      ? 'System notification delivery is active and ready.'
                      : 'Please grant notification access to receive alerts.',
                  style: const TextStyle(fontSize: 11, color: AppColors.lightTextSecondary),
                ),
              ],
            ),
          ),
          if (!isGranted)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.warning,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              onPressed: () => notifProvider.requestPermissions(),
              child: const Text('Allow', style: TextStyle(fontSize: 12)),
            ),
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

  Widget _buildConfigRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppColors.lightTextSecondary, fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}

