import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class UpdateProfileParams extends Equatable {
  final String displayName;
  final String? photoUrl;
  final String? role;

  const UpdateProfileParams({
    required this.displayName,
    this.photoUrl,
    this.role,
  });

  @override
  List<Object?> get props => [displayName, photoUrl, role];
}

class UpdateProfileUseCase implements UseCase<UserEntity, UpdateProfileParams> {
  final AuthRepository repository;

  const UpdateProfileUseCase(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(UpdateProfileParams params) async {
    return await repository.updateUserProfile(
      displayName: params.displayName,
      photoUrl: params.photoUrl,
      role: params.role,
    );
  }
}

