import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learnhub/core/errors/exceptions.dart';
import 'package:learnhub/core/widgets/custom_button.dart';
import 'package:learnhub/features/auth/providers/auth_provider.dart';
import 'package:learnhub/features/auth/screens/login_screen.dart';
import 'package:learnhub/features/auth/screens/register_screen.dart';
import 'package:learnhub/features/auth/services/auth_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

class MockAuthService extends Mock implements AuthService {}

void main() {
  late MockAuthService mockAuthService;
  late AuthProvider authProvider;

  setUp(() {
    mockAuthService = MockAuthService();
    when(() => mockAuthService.authStateChanges)
        .thenAnswer((_) => Stream.value(null));

    authProvider = AuthProvider(authService: mockAuthService);
  });

  Widget buildTestApp(Widget child) {
    return ChangeNotifierProvider<AuthProvider>.value(
      value: authProvider,
      child: MaterialApp(
        home: child,
      ),
    );
  }

  group('LoginScreen Widget Tests (Tasks 8, 9, 10)', () {
    testWidgets('renders all login screen UI components', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp(const LoginScreen()));

      expect(find.text('Sign In'), findsOneWidget);
      expect(find.text('Email Address'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Forgot Password?'), findsOneWidget);
      expect(find.text('Explore as Guest'), findsOneWidget);
      expect(find.text('Register Here'), findsOneWidget);
    });

    testWidgets('displays validation errors on empty submission', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp(const LoginScreen()));

      final buttonFinder = find.widgetWithText(CustomButton, 'Sign In');
      await tester.ensureVisible(buttonFinder);
      await tester.tap(buttonFinder);
      await tester.pump();

      expect(find.text('Please enter your email address.'), findsOneWidget);
      expect(find.text('Please enter your password.'), findsOneWidget);
    });

    testWidgets('displays error banner when login fails (Task 10 error state)', (WidgetTester tester) async {
      when(() => mockAuthService.loginWithEmailPassword(
            email: 'wrong@learnhub.com',
            password: 'password123',
          )).thenThrow(const AuthException(message: 'Invalid email or password.'));

      await tester.pumpWidget(buildTestApp(const LoginScreen()));

      // Enter email in first field and password in second field
      await tester.enterText(find.byType(TextFormField).at(0), 'wrong@learnhub.com');
      await tester.enterText(find.byType(TextFormField).at(1), 'password123');

      // Tap Sign In button
      final buttonFinder = find.widgetWithText(CustomButton, 'Sign In');
      await tester.ensureVisible(buttonFinder);
      await tester.tap(buttonFinder);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Verify the red error banner appears with the message
      expect(find.text('Invalid email or password.'), findsOneWidget);
    });
  });

  group('RegisterScreen Widget Tests (Tasks 5, 6, 7)', () {
    testWidgets('renders all registration screen UI components', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestApp(const RegisterScreen()));

      expect(find.text('Join LearnHub'), findsOneWidget);
      expect(find.text('Username'), findsOneWidget);
      expect(find.text('Email Address'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Confirm Password'), findsOneWidget);
      expect(find.widgetWithText(CustomButton, 'Create Account'), findsOneWidget);
    });

    testWidgets('displays validation error for weak/short password', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestApp(const RegisterScreen()));

      await tester.enterText(find.byType(TextFormField).at(0), 'rahatul');
      await tester.enterText(find.byType(TextFormField).at(1), 'rahatul@learnhub.com');
      await tester.enterText(find.byType(TextFormField).at(2), '123'); // short password
      await tester.enterText(find.byType(TextFormField).at(3), '123');

      final buttonFinder = find.widgetWithText(CustomButton, 'Create Account');
      await tester.ensureVisible(buttonFinder);
      await tester.tap(buttonFinder);
      await tester.pump();

      expect(find.text('Password must be at least 6 characters long.'), findsOneWidget);
    });

    testWidgets('displays error banner when duplicate email registered (Task 7 error state)', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      when(() => mockAuthService.registerWithEmailPassword(
            username: 'existing_user',
            email: 'duplicate@learnhub.com',
            password: 'password123',
          )).thenThrow(const AuthException(message: 'An account with this email address already exists. Please sign in instead.'));

      await tester.pumpWidget(buildTestApp(const RegisterScreen()));

      await tester.enterText(find.byType(TextFormField).at(0), 'existing_user');
      await tester.enterText(find.byType(TextFormField).at(1), 'duplicate@learnhub.com');
      await tester.enterText(find.byType(TextFormField).at(2), 'password123');
      await tester.enterText(find.byType(TextFormField).at(3), 'password123');

      final buttonFinder = find.widgetWithText(CustomButton, 'Create Account');
      await tester.ensureVisible(buttonFinder);
      await tester.tap(buttonFinder);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('An account with this email address already exists. Please sign in instead.'), findsOneWidget);
    });
  });
}
