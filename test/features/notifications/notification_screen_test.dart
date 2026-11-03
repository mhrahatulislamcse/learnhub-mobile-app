import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learnhub/features/notifications/providers/notification_provider.dart';
import 'package:learnhub/features/notifications/screens/notification_screen.dart';
import 'package:learnhub/features/notifications/services/notification_service.dart';
import 'package:learnhub/services/storage_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

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

  Widget createWidgetUnderTest() {
    return ChangeNotifierProvider<NotificationProvider>.value(
      value: notificationProvider,
      child: const MaterialApp(
        home: NotificationScreen(),
      ),
    );
  }

  group('NotificationScreen Widget Tests (Tasks 26, 27, 28)', () {
    testWidgets('renders all notification configuration cards, channel settings, and controls', (tester) async {
      tester.view.physicalSize = const Size(800, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Screen Header
      expect(find.text('Notification Center'), findsOneWidget);

      // 1. Permission Banner
      expect(find.text('Notifications Allowed'), findsOneWidget);

      // 2. Channel Configuration Card (Task 27 evidence)
      expect(find.text('Notification Channel Settings'), findsOneWidget);
      expect(find.text('ANDROID CHANNEL'), findsOneWidget);
      expect(find.text('learnhub_study_reminders'), findsOneWidget);
      expect(find.text('High (Heads-up alert & sound)'), findsOneWidget);

      // 3. Instant Test Notification Card (Task 28 evidence)
      expect(find.text('Trigger Test Notification'), findsWidgets);
      expect(find.text('Time to Learn!'), findsOneWidget);

      // 4. Scheduled Study Reminders Card (Task 27 evidence)
      expect(find.text('Scheduled Study Reminders'), findsOneWidget);
      expect(find.text('Daily Study Reminder'), findsOneWidget);
      expect(find.text('Save Scheduled Reminder'), findsOneWidget);
    });

    testWidgets('tapping Trigger Test Notification sends instant alert and displays snackbar', (tester) async {
      tester.view.physicalSize = const Size(800, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final triggerBtn = find.widgetWithText(ElevatedButton, 'Trigger Test Notification');
      expect(triggerBtn, findsOneWidget);

      await tester.tap(triggerBtn);
      await tester.pumpAndSettle();

      verify(() => mockNotificationService.showInstantNotification(
            id: 202,
            title: any(named: 'title'),
            body: any(named: 'body'),
            payload: '/home',
          )).called(1);

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('Alert dispatched:'), findsOneWidget);
    });

    testWidgets('saving scheduled study reminder triggers notification service schedule', (tester) async {
      tester.view.physicalSize = const Size(800, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final saveScheduleBtn = find.text('Save Scheduled Reminder');
      expect(saveScheduleBtn, findsOneWidget);

      await tester.tap(saveScheduleBtn);
      await tester.pumpAndSettle();

      verify(() => mockNotificationService.scheduleDailyStudyReminder(
            id: 101,
            hour: any(named: 'hour'),
            minute: any(named: 'minute'),
            title: any(named: 'title'),
            body: any(named: 'body'),
            payload: '/favorites',
          )).called(1);

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('Study reminder scheduled'), findsOneWidget);
    });
  });
}
