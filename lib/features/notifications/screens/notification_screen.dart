import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../providers/notification_provider.dart';
import '../services/notification_service.dart';

/// Task 26: Notification Implementation Source Code (4 points)
/// Replicates Figma Screen 09 (Notifications / Stay on track) with channel inspector and daily scheduler
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
    return DateFormat('h:mm a').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final notifProvider = context.watch<NotificationProvider>();

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: AppColors.lightBackground,
        elevation: 0,
        title: const Text(
          'Notification Center',
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
          // Figma 09 Headline: Stay on track
          const Text(
            'Stay on track',
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Small reminders help build big habits.',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 16),

          // Figma 09: Daily Learning Reminder Highlight Card (Background #EAF1FC, rx 15)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.pillBlue,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(Icons.notifications_active_rounded, color: AppColors.secondary, size: 22),
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Daily Study Reminder',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Daily learning reminder • A little progress every day.',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: notifProvider.dailyReminderEnabled,
                  activeColor: AppColors.secondary,
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
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Figma 09: Scheduled Study Reminders Card
          const Text(
            'Scheduled Study Reminders',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.lightBorder),
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Every day',
                      style: TextStyle(fontSize: 11, color: AppColors.lightTextSecondary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatTimeOfDay(_selectedTime),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => _pickTime(context),
                  child: const Text(
                    'Edit',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.secondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Save scheduled reminder button for test & schedule confirmation
          CustomButton(
            text: 'Save Scheduled Reminder',
            height: 48,
            backgroundColor: AppColors.secondary,
            textColor: Colors.white,
            icon: const Icon(Icons.alarm_on_rounded, color: Colors.white, size: 18),
            onPressed: () async {
              await notifProvider.scheduleDailyReminder(
                hour: _selectedTime.hour,
                minute: _selectedTime.minute,
              );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Study reminder scheduled for ${_formatTimeOfDay(_selectedTime)}',
                    ),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
          ),
          const SizedBox(height: 24),

          // Figma 09: Recent Activity Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent activity',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('All notifications marked as read')),
                  );
                },
                child: const Text(
                  'Mark all read',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          _buildActivityCard(
            title: 'Your daily goal is waiting',
            body: 'Take 10 minutes to explore a new book.',
            timestamp: 'Today · 9:00 AM',
            isUnread: true,
          ),
          const SizedBox(height: 10),
          _buildActivityCard(
            title: 'A book for your interests',
            body: 'New titles in Design are ready to explore.',
            timestamp: 'Yesterday',
            isUnread: true,
          ),
          const SizedBox(height: 10),
          _buildActivityCard(
            title: 'Welcome to LearnHub',
            body: 'Your learning journey starts now.',
            timestamp: 'Monday',
            isUnread: true,
          ),
          const SizedBox(height: 24),

          // Trigger Test Notification Section (Task 28)
          const Text(
            'Trigger Test Notification',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: AppColors.lightBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Notification Title',
                    contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _bodyController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Notification Body',
                    contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
                const SizedBox(height: 14),
                CustomButton(
                  text: _isTriggering ? 'Triggering...' : 'Trigger Test Notification',
                  height: 48,
                  backgroundColor: AppColors.secondary,
                  textColor: Colors.white,
                  icon: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
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
          const SizedBox(height: 24),

          // Channel Configuration Card (Task 27)
          const Text(
            'Notification Channel Settings',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 10),
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
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.pillBlue,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'ANDROID CHANNEL',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.secondary),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Notifications Allowed',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.success),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildChannelRow('Channel ID', NotificationService.channelIdReminders),
                const SizedBox(height: 6),
                _buildChannelRow('Channel Name', NotificationService.channelNameReminders),
                const SizedBox(height: 6),
                _buildChannelRow('Importance', 'High (Heads-up alert & sound)'),
                const SizedBox(height: 6),
                _buildChannelRow('Vibration & Audio', 'Enabled'),
                const SizedBox(height: 6),
                _buildChannelRow('Study Reminders', 'Daily Study Reminder Active'),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildActivityCard({
    required String title,
    required String body,
    required String timestamp,
    bool isUnread = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: AppColors.lightBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
              color: AppColors.pillBlue,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(Icons.notifications_rounded, color: AppColors.secondary, size: 18),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  body,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  timestamp,
                  style: const TextStyle(
                    fontSize: 9,
                    color: AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (isUnread)
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(top: 4),
              decoration: const BoxDecoration(
                color: AppColors.secondary,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildChannelRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.lightTextSecondary),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
        ),
      ],
    );
  }
}
