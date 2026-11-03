import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel?> getCurrentUser();

  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  });

  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
    required String role,
  });

  Future<void> sendPasswordResetEmail({
    required String email,
  });

  Future<UserModel> updateUserProfile({
    required String displayName,
    String? photoUrl,
    String? role,
  });

  Future<void> signOut();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final fb.FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;

  AuthRemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.firestore,
  });

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final currentUser = firebaseAuth.currentUser;
      if (currentUser == null) return null;

      final doc = await firestore
          .collection(AppConstants.usersCollection)
          .doc(currentUser.uid)
          .get();

      if (doc.exists && doc.data() != null) {
        return UserModel.fromJson({...doc.data()!, 'id': doc.id});
      }
      return UserModel.fromFirebaseUser(currentUser);
    } catch (e) {
      throw ServerException(message: 'Failed to fetch current user profile: $e');
    }
  }

  @override
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        throw const AuthException(message: 'Sign in failed. No user received.');
      }

      final doc = await firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .get();

      if (doc.exists && doc.data() != null) {
        return UserModel.fromJson({...doc.data()!, 'id': doc.id});
      }
      return UserModel.fromFirebaseUser(user);
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException(code: e.code, message: e.message ?? 'Authentication error');
    } catch (e) {
      throw ServerException(message: 'Sign in error: $e');
    }
  }

  @override
  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
    required String role,
  }) async {
    try {
      final credential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        throw const AuthException(message: 'Account creation failed.');
      }

      await user.updateDisplayName(displayName);

      final userModel = UserModel(
        id: user.uid,
        email: email,
        displayName: displayName,
        photoUrl: user.photoURL,
        role: role,
        createdAt: DateTime.now(),
      );

      await firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .set(userModel.toJson());

      return userModel;
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException(code: e.code, message: e.message ?? 'Registration error');
    } catch (e) {
      throw ServerException(message: 'Registration error: $e');
    }
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException(code: e.code, message: e.message ?? 'Password reset error');
    } catch (e) {
      throw ServerException(message: 'Password reset error: $e');
    }
  }

  @override
  Future<UserModel> updateUserProfile({
    required String displayName,
    String? photoUrl,
    String? role,
  }) async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) {
        throw const AuthException(message: 'No authenticated user to update');
      }

      await user.updateDisplayName(displayName);
      if (photoUrl != null && photoUrl.isNotEmpty) {
        await user.updatePhotoURL(photoUrl);
      }

      final updateData = <String, dynamic>{
        'displayName': displayName,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (photoUrl != null && photoUrl.isNotEmpty) {
        updateData['photoUrl'] = photoUrl;
      }
      if (role != null && role.isNotEmpty) {
        updateData['role'] = role;
      }

      await firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .update(updateData);

      final updatedDoc = await firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .get();

      if (updatedDoc.exists && updatedDoc.data() != null) {
        return UserModel.fromJson({...updatedDoc.data()!, 'id': updatedDoc.id});
      }

      return UserModel(
        id: user.uid,
        email: user.email ?? '',
        displayName: displayName,
        photoUrl: photoUrl ?? user.photoURL,
        role: role ?? 'student',
      );
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException(code: e.code, message: e.message ?? 'Profile update error');
    } catch (e) {
      throw ServerException(message: 'Profile update error: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await firebaseAuth.signOut();
    } catch (e) {
      throw ServerException(message: 'Sign out failed: $e');
    }
  }
}
