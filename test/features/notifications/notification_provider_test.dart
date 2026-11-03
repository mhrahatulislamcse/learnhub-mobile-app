import 'package:flutter_test/flutter_test.dart';
import 'package:learnhub/features/notifications/providers/notification_provider.dart';
import 'package:learnhub/features/notifications/services/notification_service.dart';
import 'package:learnhub/services/storage_service.dart';
import 'package:mocktail/mocktail.dart';

class MockNotificationService extends Mock implements NotificationService {}
class MockStorageService extends Mock implements StorageService {}

void main() {
  late MockNotificationService mockNotificationService;
  late MockStorageService mockStorageService;
  late NotificationProvider notificationProvider;

  setUp(() {
    mockNotificationService = MockNotificationService();
    mockStorageService = MockStorageService();

    when(() => mockNotificationService.initialize())
        .thenAnswer((_) async => true);
    when(() => mockNotificationService.areNotificationsEnabled())
        .thenAnswer((_) async => true);
    when(() => mockStorageService.getNotificationsEnabled())
        .thenAnswer((_) async => true);
    when(() => mockStorageService.saveNotificationsEnabled(any()))
        .thenAnswer((_) async => true);

    when(() => mockNotificationService.showInstantNotification(
          id: any(named: 'id'),
          title: any(named: 'title'),
          body: any(named: 'body'),
          payload: any(named: 'payload'),
        )).thenAnswer((_) async => true);

    when(() => mockNotificationService.scheduleDailyStudyReminder(
          id: any(named: 'id'),
          hour: any(named: 'hour'),
          minute: any(named: 'minute'),
          title: any(named: 'title'),
          body: any(named: 'body'),
          payload: any(named: 'payload'),
        )).thenAnswer((_) async => true);

    when(() => mockNotificationService.cancelNotification(any()))
        .thenAnswer((_) async {});

    notificationProvider = NotificationProvider(
      notificationService: mockNotificationService,
      storageService: mockStorageService,
    );
  });

  group('NotificationProvider Tests (Task 26)', () {
    test('initializes and verifies active permission and reminder status', () async {
      await notificationProvider.initialize();

      expect(notificationProvider.isPermissionGranted, isTrue);
      expect(notificationProvider.dailyReminderEnabled, isTrue);
      expect(notificationProvider.isLoading, isFalse);
    });

    test('sendTestNotification dispatches instant alert and logs to recent activity', () async {
      final success = await notificationProvider.sendTestNotification(
        title: 'LearnHub Test Alert',
        body: 'Testing notification shade delivery',
      );

      expect(success, isTrue);
      expect(notificationProvider.recentAlerts, isNotEmpty);
      expect(notificationProvider.recentAlerts.first['title'], equals('LearnHub Test Alert'));
      expect(notificationProvider.recentAlerts.first['status'], equals('Delivered'));
    });

    test('scheduleDailyReminder configures reminder and persists preference', () async {
      final success = await notificationProvider.scheduleDailyReminder(
        hour: 21,
        minute: 30,
      );

      expect(success, isTrue);
      expect(notificationProvider.reminderHour, equals(21));
      expect(notificationProvider.reminderMinute, equals(30));
      expect(notificationProvider.dailyReminderEnabled, isTrue);
      verify(() => mockStorageService.saveNotificationsEnabled(true)).called(1);
    });

    test('cancelDailyReminder cancels scheduled notification and disables flag', () async {
      await notificationProvider.cancelDailyReminder();

      expect(notificationProvider.dailyReminderEnabled, isFalse);
      verify(() => mockNotificationService.cancelNotification(NotificationProvider.dailyReminderId)).called(1);
      verify(() => mockStorageService.saveNotificationsEnabled(false)).called(1);
    });

    test('clearAlertHistory empties notification log', () async {
      await notificationProvider.sendTestNotification();
      expect(notificationProvider.recentAlerts, isNotEmpty);

      notificationProvider.clearAlertHistory();
      expect(notificationProvider.recentAlerts, isEmpty);
    });
  });
}

