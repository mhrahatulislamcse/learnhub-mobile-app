import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class SignUpParams extends Equatable {
  final String email;
  final String password;
  final String displayName;
  final String role;

  const SignUpParams({
    required this.email,
    required this.password,
    required this.displayName,
    this.role = 'student',
  });

  @override
  List<Object?> get props => [email, password, displayName, role];
}

class SignUpUseCase implements UseCase<UserEntity, SignUpParams> {
  final AuthRepository repository;

  const SignUpUseCase(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(SignUpParams params) async {
    return await repository.signUpWithEmail(
      email: params.email,
      password: params.password,
      displayName: params.displayName,
      role: params.role,
    );
  }
}

