import 'package:flutter_test/flutter_test.dart';
import 'package:learnhub/models/user_model.dart';

void main() {
  group('UserModel Tests', () {
    final now = DateTime(2026, 11, 3, 10, 0, 0);

    final user = UserModel(
      uid: 'user_test_123',
      username: 'rahatul_learner',
      email: 'rahatul@learnhub.com',
      createdAt: now,
      preferences: const {'theme': 'dark'},
    );

    test('serializes to and from JSON correctly', () {
      final json = user.toJson();
      final fromJsonUser = UserModel.fromJson(json);

      expect(fromJsonUser.uid, equals(user.uid));
      expect(fromJsonUser.username, equals(user.username));
      expect(fromJsonUser.email, equals(user.email));
      expect(fromJsonUser.preferences['theme'], equals('dark'));
    });

    test('creates copyWith modified fields', () {
      final updated = user.copyWith(username: 'new_username');
      expect(updated.username, equals('new_username'));
      expect(updated.email, equals(user.email));
      expect(updated.uid, equals(user.uid));
    });

    test('toFirestore contains required schema keys', () {
      final map = user.toFirestore();
      expect(map.containsKey('username'), isTrue);
      expect(map.containsKey('email'), isTrue);
      expect(map.containsKey('createdAt'), isTrue);
      expect(map.containsKey('preferences'), isTrue);
    });
  });
}

