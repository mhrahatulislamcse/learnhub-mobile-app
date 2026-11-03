import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learnhub/features/notifications/services/notification_service.dart';
import 'package:mocktail/mocktail.dart';

class MockFlutterLocalNotificationsPlugin extends Mock
    implements FlutterLocalNotificationsPlugin {}

void main() {
  late MockFlutterLocalNotificationsPlugin mockPlugin;
  late NotificationService notificationService;

  setUpAll(() {
    registerFallbackValue(const InitializationSettings());
    registerFallbackValue(const NotificationDetails());
  });

  setUp(() {
    mockPlugin = MockFlutterLocalNotificationsPlugin();
    notificationService = NotificationService(notificationsPlugin: mockPlugin);

    when(() => mockPlugin.initialize(
          settings: any(named: 'settings'),
          onDidReceiveNotificationResponse: any(named: 'onDidReceiveNotificationResponse'),
        )).thenAnswer((_) async => true);

    when(() => mockPlugin.show(
          id: any(named: 'id'),
          title: any(named: 'title'),
          body: any(named: 'body'),
          notificationDetails: any(named: 'notificationDetails'),
          payload: any(named: 'payload'),
        )).thenAnswer((_) async {});

    when(() => mockPlugin.cancel(id: any(named: 'id'))).thenAnswer((_) async {});
    when(() => mockPlugin.cancelAll()).thenAnswer((_) async {});
  });

  group('NotificationService Tests (Task 26)', () {
    test('initialize configures settings and marks service as initialized', () async {
      final success = await notificationService.initialize();

      expect(success, isTrue);
      expect(notificationService.isInitialized, isTrue);
      verify(() => mockPlugin.initialize(
            settings: any(named: 'settings'),
            onDidReceiveNotificationResponse: any(named: 'onDidReceiveNotificationResponse'),
          )).called(1);
    });

    test('showInstantNotification triggers notification with title and body', () async {
      final success = await notificationService.showInstantNotification(
        id: 202,
        title: 'Time to Learn!',
        body: 'Explore new educational books.',
        payload: '/home',
      );

      expect(success, isTrue);
      verify(() => mockPlugin.show(
            id: 202,
            title: 'Time to Learn!',
            body: 'Explore new educational books.',
            notificationDetails: any(named: 'notificationDetails'),
            payload: '/home',
          )).called(1);
    });

    test('cancelNotification cancels specific notification id', () async {
      await notificationService.cancelNotification(101);
      verify(() => mockPlugin.cancel(id: 101)).called(1);
    });

    test('cancelAllNotifications cancels all notifications', () async {
      await notificationService.cancelAllNotifications();
      verify(() => mockPlugin.cancelAll()).called(1);
    });
  });
}

