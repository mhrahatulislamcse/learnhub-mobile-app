import 'package:flutter/foundation.dart';
import '../../../core/utils/app_logger.dart';
import '../../../services/storage_service.dart';
import '../services/notification_service.dart';

/// Provider managing notification state, permissions, instant test alerts, and daily reminder schedules
class NotificationProvider extends ChangeNotifier {
  final NotificationService _notificationService;
  final StorageService _storageService;

  bool _isPermissionGranted = true;
  bool _dailyReminderEnabled = true;
  int _reminderHour = 20; // 8:00 PM
  int _reminderMinute = 0;
  bool _isLoading = false;

  final List<Map<String, dynamic>> _recentAlerts = [];

  static const int dailyReminderId = 101;
  static const int instantAlertId = 202;

  NotificationProvider({
    NotificationService? notificationService,
    StorageService? storageService,
  })  : _notificationService = notificationService ?? NotificationService(),
        _storageService = storageService ?? StorageService() {
    initialize();
  }

  bool get isPermissionGranted => _isPermissionGranted;
  bool get dailyReminderEnabled => _dailyReminderEnabled;
  int get reminderHour => _reminderHour;
  int get reminderMinute => _reminderMinute;
  bool get isLoading => _isLoading;
  List<Map<String, dynamic>> get recentAlerts => List.unmodifiable(_recentAlerts);

  /// Initializes notification plugin and verifies permission status
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _notificationService.initialize();
      _isPermissionGranted = await _notificationService.areNotificationsEnabled();
      _dailyReminderEnabled = await _storageService.getNotificationsEnabled();

      AppLogger.info('NotificationProvider: Initialized (Permission: $_isPermissionGranted, Reminder: $_dailyReminderEnabled)');
    } catch (e) {
      AppLogger.error('NotificationProvider: Initialization error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Requests notification permissions from the OS
  Future<bool> requestPermissions() async {
    try {
      final granted = await _notificationService.requestPermissions();
      _isPermissionGranted = granted;
      notifyListeners();
      return granted;
    } catch (e) {
      AppLogger.error('NotificationProvider: Permission request error: $e');
      return false;
    }
  }

  /// Triggers an immediate test notification alert
  Future<bool> sendTestNotification({
    String title = 'Time to Learn!',
    String body = 'Explore new books and continue your learning streak on LearnHub.',
  }) async {
    try {
      final success = await _notificationService.showInstantNotification(
        id: instantAlertId,
        title: title,
        body: body,
        payload: '/home',
      );

      if (success) {
        _recentAlerts.insert(0, {
          'title': title,
          'body': body,
          'type': 'Instant Alert',
          'timestamp': DateTime.now(),
          'status': 'Delivered',
        });
        notifyListeners();
      }
      return success;
    } catch (e) {
      AppLogger.error('NotificationProvider: Send test notification failed: $e');
      return false;
    }
  }

  /// Schedules daily recurring study reminder
  Future<bool> scheduleDailyReminder({
    required int hour,
    required int minute,
    String title = 'Daily Study Reminder',
    String body = 'Keep your daily learning habits strong with 15 minutes of reading.',
  }) async {
    try {
      _reminderHour = hour;
      _reminderMinute = minute;
      _dailyReminderEnabled = true;

      final success = await _notificationService.scheduleDailyStudyReminder(
        id: dailyReminderId,
        hour: hour,
        minute: minute,
        title: title,
        body: body,
        payload: '/favorites',
      );

      if (success) {
        await _storageService.saveNotificationsEnabled(true);
        _recentAlerts.insert(0, {
          'title': title,
          'body': '$body (Scheduled for ${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')})',
          'type': 'Daily Schedule',
          'timestamp': DateTime.now(),
          'status': 'Active',
        });
        notifyListeners();
      }
      return success;
    } catch (e) {
      AppLogger.error('NotificationProvider: Schedule daily reminder failed: $e');
      return false;
    }
  }

  /// Cancels scheduled daily reminder
  Future<void> cancelDailyReminder() async {
    try {
      await _notificationService.cancelNotification(dailyReminderId);
      _dailyReminderEnabled = false;
      await _storageService.saveNotificationsEnabled(false);
      notifyListeners();
      AppLogger.info('NotificationProvider: Daily reminder cancelled');
    } catch (e) {
      AppLogger.error('NotificationProvider: Cancel reminder error: $e');
    }
  }

  /// Clears recent alert activity logs
  void clearAlertHistory() {
    _recentAlerts.clear();
    notifyListeners();
  }
}
