import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learnhub/features/auth/providers/auth_provider.dart';
import 'package:learnhub/features/auth/services/auth_service.dart';
import 'package:learnhub/features/favorites/providers/favorites_provider.dart';
import 'package:learnhub/features/profile/screens/profile_screen.dart';
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

  final testUser = UserModel(
    uid: 'USER_PROFILE_1',
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

    when(() => mockStorageService.getFavoriteBooks())
        .thenAnswer((_) async => []);

    authProvider = AuthProvider(authService: mockAuthService);
    favoritesProvider = FavoritesProvider(
      storageService: mockStorageService,
      firebaseService: mockFirebaseService,
    );
  });

  Widget createWidgetUnderTest() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        ChangeNotifierProvider<FavoritesProvider>.value(value: favoritesProvider),
      ],
      child: const MaterialApp(
        home: ProfileScreen(),
      ),
    );
  }

  group('ProfileScreen Widget Tests (Screen 6 / Screen 9)', () {
    testWidgets('renders unauthenticated state when no user logged in', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('My Profile'), findsOneWidget);
      expect(find.text('Not Signed In'), findsOneWidget);
      expect(find.text('Sign In to LearnHub'), findsOneWidget);
    });

    testWidgets('renders user credentials, badges, and learning stats when authenticated', (tester) async {
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

      // User credentials
      expect(find.text('Rahatul Islam'), findsOneWidget);
      expect(find.text('rahatul@learnhub.com'), findsOneWidget);
      expect(find.text('STUDENT'), findsOneWidget);

      // Learning stats & account card
      expect(find.text('Saved Books'), findsOneWidget);
      expect(find.text('Account Details'), findsOneWidget);
      expect(find.text('USER_PROFILE_1'), findsOneWidget);

      // Actions
      expect(find.text('Reset Password'), findsOneWidget);
      expect(find.text('Sign Out'), findsOneWidget);
    });
  });
}

