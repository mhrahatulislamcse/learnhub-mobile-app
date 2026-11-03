import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

/// Represents a registered user in LearnHub
class UserModel {
  final String uid;
  final String username;
  final String email;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic> preferences;

  const UserModel({
    required this.uid,
    required this.username,
    required this.email,
    required this.createdAt,
    this.updatedAt,
    this.preferences = const {},
  });

  /// User role (e.g. 'student', 'instructor')
  String get role => preferences['role'] as String? ?? 'student';

  /// Factory constructor to build a [UserModel] from Firebase User + Firestore document
  factory UserModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    DateTime parseTimestamp(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    return UserModel(
      uid: doc.id,
      username: data['username'] as String? ?? 'Learner',
      email: data['email'] as String? ?? '',
      createdAt: parseTimestamp(data['createdAt']),
      updatedAt: data['updatedAt'] != null ? parseTimestamp(data['updatedAt']) : null,
      preferences: (data['preferences'] as Map<String, dynamic>?) ?? {},
    );
  }

  /// Factory constructor to create from Firebase Auth User
  factory UserModel.fromFirebaseUser(fb.User user, {String? username}) {
    return UserModel(
      uid: user.uid,
      username: username ?? user.displayName ?? (user.email?.split('@').first ?? 'Learner'),
      email: user.email ?? '',
      createdAt: user.metadata.creationTime ?? DateTime.now(),
      updatedAt: user.metadata.lastSignInTime,
      preferences: const {},
    );
  }

  /// Converts model to Firestore-compatible JSON map
  Map<String, dynamic> toFirestore() {
    return {
      'username': username,
      'email': email,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : FieldValue.serverTimestamp(),
      'preferences': preferences,
    };
  }

  /// JSON serialization for caching and local storage
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String? ?? '',
      username: json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
      preferences: (json['preferences'] as Map<String, dynamic>?) ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'username': username,
      'email': email,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'preferences': preferences,
    };
  }

  UserModel copyWith({
    String? username,
    String? email,
    DateTime? updatedAt,
    Map<String, dynamic>? preferences,
  }) {
    return UserModel(
      uid: uid,
      username: username ?? this.username,
      email: email ?? this.email,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      preferences: preferences ?? this.preferences,
    );
  }
}

