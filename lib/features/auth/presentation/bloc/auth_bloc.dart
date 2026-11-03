import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/send_password_reset_usecase.dart';
import '../../domain/usecases/sign_in_usecase.dart';
import '../../domain/usecases/sign_up_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final SignInUseCase signInUseCase;
  final SignUpUseCase signUpUseCase;
  final SendPasswordResetUseCase sendPasswordResetUseCase;
  final UpdateProfileUseCase updateProfileUseCase;
  final SignOutUseCase signOutUseCase;

  AuthBloc({
    required this.getCurrentUserUseCase,
    required this.signInUseCase,
    required this.signUpUseCase,
    required this.sendPasswordResetUseCase,
    required this.updateProfileUseCase,
    required this.signOutUseCase,
  }) : super(AuthInitial()) {
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<SignInRequestedEvent>(_onSignInRequested);
    on<SignUpRequestedEvent>(_onSignUpRequested);
    on<SendPasswordResetEvent>(_onSendPasswordReset);
    on<UpdateProfileEvent>(_onUpdateProfile);
    on<SignOutRequestedEvent>(_onSignOutRequested);
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await getCurrentUserUseCase(const NoParams());
    result.fold(
      (failure) => emit(Unauthenticated()),
      (user) {
        if (user != null) {
          emit(Authenticated(user: user));
        } else {
          emit(Unauthenticated());
        }
      },
    );
  }

  Future<void> _onSignInRequested(
    SignInRequestedEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await signInUseCase(
      SignInParams(email: event.email, password: event.password),
    );
    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (user) => emit(Authenticated(user: user)),
    );
  }

  Future<void> _onSignUpRequested(
    SignUpRequestedEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await signUpUseCase(
      SignUpParams(
        email: event.email,
        password: event.password,
        displayName: event.displayName,
        role: event.role,
      ),
    );
    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (user) => emit(Authenticated(user: user)),
    );
  }

  Future<void> _onSendPasswordReset(
    SendPasswordResetEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await sendPasswordResetUseCase(
      ResetPasswordParams(email: event.email),
    );
    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (_) => emit(PasswordResetSent(email: event.email)),
    );
  }

  Future<void> _onUpdateProfile(
    UpdateProfileEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await updateProfileUseCase(
      UpdateProfileParams(
        displayName: event.displayName,
        photoUrl: event.photoUrl,
        role: event.role,
      ),
    );
    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (user) => emit(Authenticated(user: user)),
    );
  }

  Future<void> _onSignOutRequested(
    SignOutRequestedEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await signOutUseCase(const NoParams());
    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (_) => emit(Unauthenticated()),
    );
  }
}
