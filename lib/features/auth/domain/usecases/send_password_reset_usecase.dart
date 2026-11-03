import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/auth_repository.dart';

class ResetPasswordParams extends Equatable {
  final String email;

  const ResetPasswordParams({required this.email});

  @override
  List<Object?> get props => [email];
}

class SendPasswordResetUseCase implements UseCase<void, ResetPasswordParams> {
  final AuthRepository repository;

  const SendPasswordResetUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(ResetPasswordParams params) async {
    return await repository.sendPasswordResetEmail(email: params.email);
  }
}

