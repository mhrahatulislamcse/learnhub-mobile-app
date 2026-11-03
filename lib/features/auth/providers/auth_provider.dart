import 'package:flutter/foundation.dart';
import '../../../core/errors/exceptions.dart';
import '../../../core/utils/app_logger.dart';
import '../../../models/user_model.dart';
import '../services/auth_service.dart';

/// Provider managing authentication state, login, registration, and user session
class AuthProvider extends ChangeNotifier {
  final AuthService _authService;

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider({AuthService? authService})
      : _authService = authService ?? AuthService() {
    _init();
  }

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  void _init() {
    _authService.authStateChanges.listen((fbUser) async {
      if (fbUser != null) {
        _currentUser = await _authService.getCurrentUserProfile();
      } else {
        _currentUser = null;
      }
      notifyListeners();
    });
  }

  /// Initial load of the current user profile
  Future<void> checkCurrentUser() async {
    _setLoading(true);
    try {
      _currentUser = await _authService.getCurrentUserProfile();
      _errorMessage = null;
    } catch (e) {
      AppLogger.warning('AuthProvider: checkCurrentUser failed: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Registers a new user. Returns true on success, false on error.
  Future<bool> register({
    required String username,
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final user = await _authService.registerWithEmailPassword(
        username: username,
        email: email,
        password: password,
      );
      _currentUser = user;
      _setLoading(false);
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      _setLoading(false);
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected registration error occurred: $e';
      _setLoading(false);
      return false;
    }
  }

  /// Logs in an existing user. Returns true on success, false on error.
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final user = await _authService.loginWithEmailPassword(
        email: email,
        password: password,
      );
      _currentUser = user;
      _setLoading(false);
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      _setLoading(false);
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected sign in error occurred: $e';
      _setLoading(false);
      return false;
    }
  }

  /// Sends a password reset email.
  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await _authService.sendPasswordResetEmail(email);
      _setLoading(false);
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      _setLoading(false);
      return false;
    } catch (e) {
      _errorMessage = 'Password reset failed: $e';
      _setLoading(false);
      return false;
    }
  }

  /// Signs out the user and clears state.
  Future<void> logout() async {
    _setLoading(true);
    try {
      await _authService.signOut();
      _currentUser = null;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to sign out: $e';
    } finally {
      _setLoading(false);
    }
  }

  /// Clears active error message
  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}

