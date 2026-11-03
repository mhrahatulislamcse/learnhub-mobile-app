import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class CheckAuthStatusEvent extends AuthEvent {}

class SignInRequestedEvent extends AuthEvent {
  final String email;
  final String password;

  const SignInRequestedEvent({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class SignUpRequestedEvent extends AuthEvent {
  final String email;
  final String password;
  final String displayName;
  final String role;

  const SignUpRequestedEvent({
    required this.email,
    required this.password,
    required this.displayName,
    this.role = 'student',
  });

  @override
  List<Object?> get props => [email, password, displayName, role];
}

class SendPasswordResetEvent extends AuthEvent {
  final String email;

  const SendPasswordResetEvent({required this.email});

  @override
  List<Object?> get props => [email];
}

class UpdateProfileEvent extends AuthEvent {
  final String displayName;
  final String? photoUrl;
  final String? role;

  const UpdateProfileEvent({
    required this.displayName,
    this.photoUrl,
    this.role,
  });

  @override
  List<Object?> get props => [displayName, photoUrl, role];
}

class SignOutRequestedEvent extends AuthEvent {}
