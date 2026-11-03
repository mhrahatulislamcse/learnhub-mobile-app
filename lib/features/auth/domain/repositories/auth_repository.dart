import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';

/// Contract defining authentication and user profile operations
abstract class AuthRepository {
  Future<Either<Failure, UserEntity?>> getCurrentUser();

  Future<Either<Failure, UserEntity>> signInWithEmail({
    required String email,
    required String password,
  });

  Future<Either<Failure, UserEntity>> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
    required String role,
  });

  Future<Either<Failure, void>> sendPasswordResetEmail({
    required String email,
  });

  Future<Either<Failure, UserEntity>> updateUserProfile({
    required String displayName,
    String? photoUrl,
    String? role,
  });

  Future<Either<Failure, void>> signOut();
}
