import 'package:flutter_test/flutter_test.dart';
import 'package:learnhub/core/errors/failures.dart';

void main() {
  group('Failures', () {
    test('ServerFailure supports value equality', () {
      expect(
        const ServerFailure(message: 'Error', code: '500'),
        equals(const ServerFailure(message: 'Error', code: '500')),
      );
    });

    test('AuthFailure supports value equality', () {
      expect(
        const AuthFailure(message: 'Invalid credentials', code: 'user-not-found'),
        equals(const AuthFailure(message: 'Invalid credentials', code: 'user-not-found')),
      );
    });

    test('NetworkFailure provides default message', () {
      const failure = NetworkFailure();
      expect(failure.message, contains('internet connection'));
    });
  });
}

