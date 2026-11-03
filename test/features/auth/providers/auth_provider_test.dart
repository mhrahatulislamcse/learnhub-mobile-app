import 'package:flutter_test/flutter_test.dart';
import 'package:learnhub/core/errors/exceptions.dart';
import 'package:learnhub/features/auth/providers/auth_provider.dart';
import 'package:learnhub/features/auth/services/auth_service.dart';
import 'package:learnhub/models/user_model.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthService extends Mock implements AuthService {}

void main() {
  late MockAuthService mockAuthService;
  late AuthProvider authProvider;

  final testUser = UserModel(
    uid: 'user_456',
    username: 'test_user',
    email: 'test@learnhub.com',
    createdAt: DateTime.now(),
  );

  setUp(() {
    mockAuthService = MockAuthService();
    when(() => mockAuthService.authStateChanges)
        .thenAnswer((_) => Stream.value(null));

    authProvider = AuthProvider(authService: mockAuthService);
  });

  group('AuthProvider Tests', () {
    test('initial state has no user and not loading', () {
      expect(authProvider.currentUser, isNull);
      expect(authProvider.isLoading, isFalse);
      expect(authProvider.errorMessage, isNull);
      expect(authProvider.isAuthenticated, isFalse);
    });

    test('login success sets currentUser and clears errors', () async {
      when(() => mockAuthService.loginWithEmailPassword(
            email: 'test@learnhub.com',
            password: 'password123',
          )).thenAnswer((_) async => testUser);

      final success = await authProvider.login(
        email: 'test@learnhub.com',
        password: 'password123',
      );

      expect(success, isTrue);
      expect(authProvider.currentUser, equals(testUser));
      expect(authProvider.isAuthenticated, isTrue);
      expect(authProvider.errorMessage, isNull);
    });

    test('login failure sets errorMessage and keeps user null', () async {
      when(() => mockAuthService.loginWithEmailPassword(
            email: 'test@learnhub.com',
            password: 'wrongpassword',
          )).thenThrow(const AuthException(message: 'Invalid email or password.'));

      final success = await authProvider.login(
        email: 'test@learnhub.com',
        password: 'wrongpassword',
      );

      expect(success, isFalse);
      expect(authProvider.currentUser, isNull);
      expect(authProvider.isAuthenticated, isFalse);
      expect(authProvider.errorMessage, equals('Invalid email or password.'));
    });

    test('register success sets currentUser', () async {
      when(() => mockAuthService.registerWithEmailPassword(
            username: 'new_learner',
            email: 'new@learnhub.com',
            password: 'password123',
          )).thenAnswer((_) async => testUser);

      final success = await authProvider.register(
        username: 'new_learner',
        email: 'new@learnhub.com',
        password: 'password123',
      );

      expect(success, isTrue);
      expect(authProvider.currentUser, equals(testUser));
      expect(authProvider.isAuthenticated, isTrue);
    });

    test('register failure sets errorMessage', () async {
      when(() => mockAuthService.registerWithEmailPassword(
            username: 'new_learner',
            email: 'duplicate@learnhub.com',
            password: 'password123',
          )).thenThrow(const AuthException(message: 'An account with this email address already exists.'));

      final success = await authProvider.register(
        username: 'new_learner',
        email: 'duplicate@learnhub.com',
        password: 'password123',
      );

      expect(success, isFalse);
      expect(authProvider.errorMessage, contains('already exists'));
    });

    test('clearError resets errorMessage', () async {
      when(() => mockAuthService.loginWithEmailPassword(
            email: 'test@learnhub.com',
            password: 'wrong',
          )).thenThrow(const AuthException(message: 'Error'));

      await authProvider.login(email: 'test@learnhub.com', password: 'wrong');
      expect(authProvider.errorMessage, isNotNull);

      authProvider.clearError();
      expect(authProvider.errorMessage, isNull);
    });
  });
}

