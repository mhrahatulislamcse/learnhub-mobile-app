import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learnhub/core/errors/failures.dart';
import 'package:learnhub/core/usecase/usecase.dart';
import 'package:learnhub/features/auth/domain/entities/user_entity.dart';
import 'package:learnhub/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:learnhub/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:learnhub/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:learnhub/features/auth/presentation/bloc/auth_event.dart';
import 'package:learnhub/features/auth/presentation/bloc/auth_state.dart';
import 'package:mocktail/mocktail.dart';

class MockGetCurrentUserUseCase extends Mock implements GetCurrentUserUseCase {}
class MockSignOutUseCase extends Mock implements SignOutUseCase {}

void main() {
  late MockGetCurrentUserUseCase mockGetCurrentUserUseCase;
  late MockSignOutUseCase mockSignOutUseCase;
  late AuthBloc authBloc;

  setUp(() {
    mockGetCurrentUserUseCase = MockGetCurrentUserUseCase();
    mockSignOutUseCase = MockSignOutUseCase();
    authBloc = AuthBloc(
      getCurrentUserUseCase: mockGetCurrentUserUseCase,
      signOutUseCase: mockSignOutUseCase,
    );
  });

  tearDown(() {
    authBloc.close();
  });

  const testUser = UserEntity(
    id: 'user_123',
    email: 'test@learnhub.com',
    displayName: 'Test User',
  );

  test('initial state should be AuthInitial', () {
    expect(authBloc.state, equals(AuthInitial()));
  });

  blocTest<AuthBloc, AuthState>(
    'emits [AuthLoading, Authenticated] when GetCurrentUserUseCase returns a user',
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
    'emits [AuthLoading, Unauthenticated] when GetCurrentUserUseCase returns null',
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

  blocTest<AuthBloc, AuthState>(
    'emits [AuthLoading, Unauthenticated] when GetCurrentUserUseCase returns a failure',
    build: () {
      when(() => mockGetCurrentUserUseCase(const NoParams()))
          .thenAnswer((_) async => const Left(AuthFailure(message: 'Not authenticated')));
      return authBloc;
    },
    act: (bloc) => bloc.add(CheckAuthStatusEvent()),
    expect: () => [
      AuthLoading(),
      Unauthenticated(),
    ],
  );

  blocTest<AuthBloc, AuthState>(
    'emits [AuthLoading, Unauthenticated] when sign out succeeds',
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
}

