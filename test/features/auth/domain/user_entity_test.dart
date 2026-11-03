import 'package:flutter_test/flutter_test.dart';
import 'package:learnhub/features/auth/domain/entities/user_entity.dart';

void main() {
  group('UserEntity', () {
    test('supports value equality', () {
      final now = DateTime.now();
      final user1 = UserEntity(
        id: 'user_1',
        email: 'test@learnhub.com',
        displayName: 'Test User',
        role: 'student',
        createdAt: now,
      );

      final user2 = UserEntity(
        id: 'user_1',
        email: 'test@learnhub.com',
        displayName: 'Test User',
        role: 'student',
        createdAt: now,
      );

      expect(user1, equals(user2));
    });

    test('default role is student', () {
      const user = UserEntity(
        id: 'user_2',
        email: 'student@learnhub.com',
        displayName: 'Student',
      );

      expect(user.role, equals('student'));
    });
  });
}

