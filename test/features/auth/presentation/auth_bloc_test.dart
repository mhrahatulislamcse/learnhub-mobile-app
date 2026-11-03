import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learnhub/core/errors/failures.dart';
import 'package:learnhub/core/usecase/usecase.dart';
import 'package:learnhub/features/auth/domain/entities/user_entity.dart';
import 'package:learnhub/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:learnhub/features/auth/domain/usecases/send_password_reset_usecase.dart';
import 'package:learnhub/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:learnhub/features/auth/domain/usecases/sign_up_usecase.dart';
import 'package:learnhub/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:learnhub/features/auth/domain/usecases/update_profile_usecase.dart';
import 'package:learnhub/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:learnhub/features/auth/presentation/bloc/auth_event.dart';
import 'package:learnhub/features/auth/presentation/bloc/auth_state.dart';
import 'package:mocktail/mocktail.dart';

class MockGetCurrentUserUseCase extends Mock implements GetCurrentUserUseCase {}
class MockSignInUseCase extends Mock implements SignInUseCase {}
class MockSignUpUseCase extends Mock implements SignUpUseCase {}
class MockSendPasswordResetUseCase extends Mock implements SendPasswordResetUseCase {}
class MockUpdateProfileUseCase extends Mock implements UpdateProfileUseCase {}
class MockSignOutUseCase extends Mock implements SignOutUseCase {}

void main() {
  late MockGetCurrentUserUseCase mockGetCurrentUserUseCase;
  late MockSignInUseCase mockSignInUseCase;
  late MockSignUpUseCase mockSignUpUseCase;
  late MockSendPasswordResetUseCase mockSendPasswordResetUseCase;
  late MockUpdateProfileUseCase mockUpdateProfileUseCase;
  late MockSignOutUseCase mockSignOutUseCase;
  late AuthBloc authBloc;

  setUp(() {
    mockGetCurrentUserUseCase = MockGetCurrentUserUseCase();
    mockSignInUseCase = MockSignInUseCase();
    mockSignUpUseCase = MockSignUpUseCase();
    mockSendPasswordResetUseCase = MockSendPasswordResetUseCase();
    mockUpdateProfileUseCase = MockUpdateProfileUseCase();
    mockSignOutUseCase = MockSignOutUseCase();

    authBloc = AuthBloc(
      getCurrentUserUseCase: mockGetCurrentUserUseCase,
      signInUseCase: mockSignInUseCase,
      signUpUseCase: mockSignUpUseCase,
      sendPasswordResetUseCase: mockSendPasswordResetUseCase,
      updateProfileUseCase: mockUpdateProfileUseCase,
      signOutUseCase: mockSignOutUseCase,
    );
  });

  tearDown(() {
    authBloc.close();
  });

  const testUser = UserEntity(
    id: 'user_123',
    email: 'test@learnhub.com',
    displayName: 'Test Learner',
    role: 'student',
  );

  test('initial state should be AuthInitial', () {
    expect(authBloc.state, equals(AuthInitial()));
  });

  group('CheckAuthStatusEvent', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, Authenticated] when user is signed in',
      build: () {
        when(() => mockGetCurrentUserUseCase(const NoParams()))
            .thenAnswer((_) async => const Right(testUser));
        return authBloc;
      },
      act: (bloc) => bloc.add(CheckAuthStatusEvent()),
      expect: () => [
        AuthLoading(),
        const Authenticated(user: testUser),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, Unauthenticated] when user is not signed in',
      build: () {
        when(() => mockGetCurrentUserUseCase(const NoParams()))
            .thenAnswer((_) async => const Right(null));
        return authBloc;
      },
      act: (bloc) => bloc.add(CheckAuthStatusEvent()),
      expect: () => [
        AuthLoading(),
        Unauthenticated(),
      ],
    );
  });

  group('SignInRequestedEvent', () {
    const signInParams = SignInParams(email: 'test@learnhub.com', password: 'password123');

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, Authenticated] on successful sign in',
      build: () {
        when(() => mockSignInUseCase(signInParams))
            .thenAnswer((_) async => const Right(testUser));
        return authBloc;
      },
      act: (bloc) => bloc.add(const SignInRequestedEvent(
        email: 'test@learnhub.com',
        password: 'password123',
      )),
      expect: () => [
        AuthLoading(),
        const Authenticated(user: testUser),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] when sign in fails',
      build: () {
        when(() => mockSignInUseCase(signInParams))
            .thenAnswer((_) async => const Left(AuthFailure(message: 'Invalid credentials')));
        return authBloc;
      },
      act: (bloc) => bloc.add(const SignInRequestedEvent(
        email: 'test@learnhub.com',
        password: 'password123',
      )),
      expect: () => [
        AuthLoading(),
        const AuthError(message: 'Invalid credentials'),
      ],
    );
  });

  group('SignUpRequestedEvent', () {
    const signUpParams = SignUpParams(
      email: 'test@learnhub.com',
      password: 'password123',
      displayName: 'Test Learner',
      role: 'student',
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, Authenticated] on successful registration',
      build: () {
        when(() => mockSignUpUseCase(signUpParams))
            .thenAnswer((_) async => const Right(testUser));
        return authBloc;
      },
      act: (bloc) => bloc.add(const SignUpRequestedEvent(
        email: 'test@learnhub.com',
        password: 'password123',
        displayName: 'Test Learner',
        role: 'student',
      )),
      expect: () => [
        AuthLoading(),
        const Authenticated(user: testUser),
      ],
    );
  });

  group('SendPasswordResetEvent', () {
    const resetParams = ResetPasswordParams(email: 'test@learnhub.com');

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, PasswordResetSent] on successful reset request',
      build: () {
        when(() => mockSendPasswordResetUseCase(resetParams))
            .thenAnswer((_) async => const Right(null));
        return authBloc;
      },
      act: (bloc) => bloc.add(const SendPasswordResetEvent(email: 'test@learnhub.com')),
      expect: () => [
        AuthLoading(),
        const PasswordResetSent(email: 'test@learnhub.com'),
      ],
    );
  });

  group('SignOutRequestedEvent', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, Unauthenticated] on successful sign out',
      build: () {
        when(() => mockSignOutUseCase(const NoParams()))
            .thenAnswer((_) async => const Right(null));
        return authBloc;
      },
      act: (bloc) => bloc.add(SignOutRequestedEvent()),
      expect: () => [
        AuthLoading(),
        Unauthenticated(),
      ],
    );
  });
}
