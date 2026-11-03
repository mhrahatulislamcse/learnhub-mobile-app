import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learnhub/core/errors/failures.dart';
import 'package:learnhub/features/auth/domain/entities/user_entity.dart';
import 'package:learnhub/features/auth/domain/repositories/auth_repository.dart';
import 'package:learnhub/features/auth/domain/usecases/send_password_reset_usecase.dart';
import 'package:learnhub/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:learnhub/features/auth/domain/usecases/sign_up_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockRepository;
  late SignInUseCase signInUseCase;
  late SignUpUseCase signUpUseCase;
  late SendPasswordResetUseCase sendPasswordResetUseCase;

  setUp(() {
    mockRepository = MockAuthRepository();
    signInUseCase = SignInUseCase(mockRepository);
    signUpUseCase = SignUpUseCase(mockRepository);
    sendPasswordResetUseCase = SendPasswordResetUseCase(mockRepository);
  });

  const testUser = UserEntity(
    id: 'user_1',
    email: 'test@learnhub.com',
    displayName: 'Test User',
    role: 'student',
  );

  group('SignInUseCase', () {
    test('calls repository.signInWithEmail and returns user', () async {
      when(() => mockRepository.signInWithEmail(
            email: 'test@learnhub.com',
            password: 'password123',
          )).thenAnswer((_) async => const Right(testUser));

      final result = await signInUseCase(
        const SignInParams(email: 'test@learnhub.com', password: 'password123'),
      );

      expect(result, const Right(testUser));
      verify(() => mockRepository.signInWithEmail(
            email: 'test@learnhub.com',
            password: 'password123',
          )).called(1);
    });

    test('returns AuthFailure when repository fails', () async {
      when(() => mockRepository.signInWithEmail(
            email: 'test@learnhub.com',
            password: 'wrongpassword',
          )).thenAnswer((_) async => const Left(AuthFailure(message: 'Invalid password')));

      final result = await signInUseCase(
        const SignInParams(email: 'test@learnhub.com', password: 'wrongpassword'),
      );

      expect(result, const Left(AuthFailure(message: 'Invalid password')));
    });
  });

  group('SignUpUseCase', () {
    test('calls repository.signUpWithEmail and returns created user', () async {
      when(() => mockRepository.signUpWithEmail(
            email: 'test@learnhub.com',
            password: 'password123',
            displayName: 'Test User',
            role: 'student',
          )).thenAnswer((_) async => const Right(testUser));

      final result = await signUpUseCase(
        const SignUpParams(
          email: 'test@learnhub.com',
          password: 'password123',
          displayName: 'Test User',
          role: 'student',
        ),
      );

      expect(result, const Right(testUser));
      verify(() => mockRepository.signUpWithEmail(
            email: 'test@learnhub.com',
            password: 'password123',
            displayName: 'Test User',
            role: 'student',
          )).called(1);
    });
  });

  group('SendPasswordResetUseCase', () {
    test('calls repository.sendPasswordResetEmail', () async {
      when(() => mockRepository.sendPasswordResetEmail(email: 'test@learnhub.com'))
          .thenAnswer((_) async => const Right(null));

      final result = await sendPasswordResetUseCase(
        const ResetPasswordParams(email: 'test@learnhub.com'),
      );

      expect(result, const Right(null));
      verify(() => mockRepository.sendPasswordResetEmail(email: 'test@learnhub.com')).called(1);
    });
  });
}

