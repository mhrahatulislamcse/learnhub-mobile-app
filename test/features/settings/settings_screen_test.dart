import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learnhub/features/auth/providers/auth_provider.dart';
import 'package:learnhub/features/auth/services/auth_service.dart';
import 'package:learnhub/features/favorites/providers/favorites_provider.dart';
import 'package:learnhub/features/settings/providers/settings_provider.dart';
import 'package:learnhub/features/settings/screens/settings_screen.dart';
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
    uid: 'TEST_USER_99',
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
    when(() => mockStorageService.saveNotificationsEnabled(any()))
        .thenAnswer((_) async => true);
    when(() => mockStorageService.clearFavorites())
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
        home: SettingsScreen(),
      ),
    );
  }

  group('SettingsScreen Widget Tests (Task 24 & 25)', () {
    testWidgets('renders all settings sections, preference controls, and legal tiles', (tester) async {
      tester.view.physicalSize = const Size(800, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Screen Header
      expect(find.text('Settings'), findsOneWidget);

      // Section 1: Appearance
      expect(find.text('Appearance & Theme'), findsOneWidget);
      expect(find.text('System'), findsOneWidget);
      expect(find.text('Light'), findsOneWidget);
      expect(find.text('Dark'), findsOneWidget);

      // Section 2: Notifications
      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('Push & Local Notifications'), findsOneWidget);
      expect(find.text('Configure Notifications & Alerts'), findsOneWidget);

      // Section 3: Account & Profile
      expect(find.text('Account & Profile'), findsOneWidget);

      // Section 4: Data & Local Storage
      expect(find.text('Data & Local Storage'), findsOneWidget);
      expect(find.text('Active Saved Favorites'), findsOneWidget);
      expect(find.text('Clear Favorites Cache'), findsOneWidget);

      // Section 5: Legal & About
      expect(find.text('About & Information'), findsOneWidget);
      expect(find.text('About LearnHub'), findsOneWidget);
      expect(find.text('Privacy Policy'), findsOneWidget);
      expect(find.text('Terms of Service'), findsOneWidget);

      // Build footer
      expect(find.textContaining('com.rahatul.learnhub'), findsOneWidget);
    });

    testWidgets('switching theme updates settings provider', (tester) async {
      tester.view.physicalSize = const Size(800, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Switch to Dark theme
      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();

      expect(settingsProvider.themeMode, equals(ThemeMode.dark));
      verify(() => mockStorageService.saveThemeMode('dark')).called(1);
    });

    testWidgets('clear favorites triggers confirmation dialog and wipes local cache', (tester) async {
      tester.view.physicalSize = const Size(800, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Tap Clear Favorites Cache
      await tester.tap(find.text('Clear Favorites Cache'));
      await tester.pumpAndSettle();

      expect(find.text('Clear Favorites Cache?'), findsOneWidget);
      expect(find.text('Clear'), findsOneWidget);

      // Confirm clearing
      await tester.tap(find.text('Clear'));
      await tester.pumpAndSettle();

      verify(() => mockStorageService.clearFavorites()).called(1);
    });

    testWidgets('tapping Terms of Service displays agreement modal', (tester) async {
      tester.view.physicalSize = const Size(800, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Terms of Service'));
      await tester.pumpAndSettle();

      expect(find.textContaining('By using LearnHub'), findsOneWidget);
      expect(find.text('Agree'), findsOneWidget);

      await tester.tap(find.text('Agree'));
      await tester.pumpAndSettle();
      expect(find.text('Agree'), findsNothing);
    });

    testWidgets('renders authenticated user profile row and sign out button', (tester) async {
      when(() => mockAuthService.getCurrentUserProfile())
          .thenAnswer((_) async => testUser);
      await authProvider.checkCurrentUser();

      tester.view.physicalSize = const Size(800, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Rahatul Islam'), findsOneWidget);
      expect(find.text('rahatul@learnhub.com • student'), findsOneWidget);
      expect(find.text('Sign Out of LearnHub'), findsOneWidget);
    });
  });
}
