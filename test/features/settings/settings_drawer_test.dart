import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learnhub/features/auth/providers/auth_provider.dart';
import 'package:learnhub/features/auth/services/auth_service.dart';
import 'package:learnhub/features/favorites/providers/favorites_provider.dart';
import 'package:learnhub/features/settings/providers/settings_provider.dart';
import 'package:learnhub/features/settings/widgets/settings_drawer.dart';
import 'package:learnhub/models/user_model.dart';
import 'package:learnhub/services/firebase_service.dart';
import 'package:learnhub/services/storage_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

class MockAuthService extends Mock implements AuthService {}
class MockStorageService extends Mock implements StorageService {}
class MockFirebaseService extends Mock implements FirebaseService {}

void main() {
  late MockAuthService mockAuthService;
  late MockStorageService mockStorageService;
  late MockFirebaseService mockFirebaseService;

  late AuthProvider authProvider;
  late FavoritesProvider favoritesProvider;
  late SettingsProvider settingsProvider;

  final testUser = UserModel(
    uid: 'USER_101',
    username: 'Rahatul Islam',
    email: 'rahatul@learnhub.com',
    createdAt: DateTime(2025, 1, 1),
    preferences: const {'role': 'student'},
  );

  setUp(() {
    mockAuthService = MockAuthService();
    mockStorageService = MockStorageService();
    mockFirebaseService = MockFirebaseService();

    when(() => mockAuthService.authStateChanges)
        .thenAnswer((_) => Stream.value(null));
    when(() => mockAuthService.currentFirebaseUser).thenReturn(null);

    when(() => mockStorageService.getThemeMode())
        .thenAnswer((_) async => 'system');
    when(() => mockStorageService.getNotificationsEnabled())
        .thenAnswer((_) async => true);
    when(() => mockStorageService.getFavoriteBooks())
        .thenAnswer((_) async => []);
    when(() => mockStorageService.saveThemeMode(any()))
        .thenAnswer((_) async => true);

    authProvider = AuthProvider(authService: mockAuthService);
    favoritesProvider = FavoritesProvider(
      storageService: mockStorageService,
      firebaseService: mockFirebaseService,
    );
    settingsProvider = SettingsProvider(storageService: mockStorageService);
  });

  Widget createWidgetUnderTest() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        ChangeNotifierProvider<FavoritesProvider>.value(value: favoritesProvider),
        ChangeNotifierProvider<SettingsProvider>.value(value: settingsProvider),
      ],
      child: const MaterialApp(
        home: Scaffold(
          body: SettingsDrawer(),
        ),
      ),
    );
  }

  group('SettingsDrawer Tests (Tasks 21, 22, 23)', () {
    testWidgets('renders drawer header and all required menu items', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Drawer Header
      expect(find.byType(SettingsDrawer), findsOneWidget);
      expect(find.text('Welcome to LearnHub'), findsOneWidget);

      // Menu Navigation Items (Task 23: evidence-menu-items)
      expect(find.text('Home Dashboard'), findsOneWidget);
      expect(find.text('Open Library REST API'), findsOneWidget);
      expect(find.text('My Favorites'), findsOneWidget);
      expect(find.text('User Profile'), findsOneWidget);
      expect(find.text('Notifications & Alerts'), findsOneWidget);
      expect(find.text('Settings Screen'), findsOneWidget);

      // Theme Switcher & Legal info
      expect(find.text('Theme Mode'), findsOneWidget);
      expect(find.text('About LearnHub'), findsOneWidget);
      expect(find.text('Privacy Policy'), findsOneWidget);

      // Action Item
      expect(find.text('Sign In'), findsOneWidget);
    });

    testWidgets('tapping About LearnHub displays details dialog', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.text('About LearnHub'));
      await tester.pumpAndSettle();

      expect(find.textContaining('v1.0.0'), findsOneWidget);
      expect(find.textContaining('Md. Rahatul Islam'), findsOneWidget);
      expect(find.text('Close'), findsOneWidget);

      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
      expect(find.text('Close'), findsNothing);
    });

    testWidgets('tapping Privacy Policy displays policy dialog', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Privacy Policy'));
      await tester.pumpAndSettle();

      expect(find.text('Data Protection Commitment'), findsOneWidget);
      expect(find.textContaining('Firebase Authentication'), findsOneWidget);
      expect(find.text('Understood'), findsOneWidget);

      await tester.tap(find.text('Understood'));
      await tester.pumpAndSettle();
      expect(find.text('Understood'), findsNothing);
    });

    testWidgets('renders authenticated user information and sign out tile', (tester) async {
      when(() => mockAuthService.getCurrentUserProfile())
          .thenAnswer((_) async => testUser);
      await authProvider.checkCurrentUser();

      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Rahatul Islam'), findsOneWidget);
      expect(find.text('rahatul@learnhub.com'), findsOneWidget);
      expect(find.text('STUDENT'), findsOneWidget);
      expect(find.text('Sign Out'), findsOneWidget);
    });
  });
}
