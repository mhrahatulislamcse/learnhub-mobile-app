import 'package:equatable/equatable.dart';

/// Core domain entity representing an authenticated user
class UserEntity extends Equatable {
  final String id;
  final String email;
  final String displayName;
  final String? photoUrl;
  final String role; // 'student', 'instructor', 'admin'
  final DateTime? createdAt;

  const UserEntity({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoUrl,
    this.role = 'student',
    this.createdAt,
  });

  @override
  List<Object?> get props => [id, email, displayName, photoUrl, role, createdAt];
}

