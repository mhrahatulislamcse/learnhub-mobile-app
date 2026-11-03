import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../../../core/errors/exceptions.dart';
import '../../../core/utils/app_logger.dart';
import '../../../models/user_model.dart';
import '../../../services/firebase_service.dart';

/// Handles Firebase Authentication and Cloud Firestore user profile operations
class AuthService {
  final FirebaseService _firebaseService;

  AuthService({FirebaseService? firebaseService})
      : _firebaseService = firebaseService ?? FirebaseService.instance;

  fb.FirebaseAuth get _auth => _firebaseService.auth;

  /// Stream of authentication state changes
  Stream<fb.User?> get authStateChanges => _auth.authStateChanges();

  /// Currently logged in Firebase User
  fb.User? get currentFirebaseUser => _auth.currentUser;

  /// Registers a new user with [username], [email], and [password]
  Future<UserModel> registerWithEmailPassword({
    required String username,
    required String email,
    required String password,
  }) async {
    final cleanUsername = username.trim();
    final cleanEmail = email.trim();

    if (cleanUsername.isEmpty || cleanUsername.length < 3) {
      throw const AuthException(message: 'Username must be at least 3 characters long.');
    }
    if (password.length < 6) {
      throw const AuthException(message: 'Password must be at least 6 characters long.');
    }

    try {
      // 1. Create account in Firebase Authentication
      final credential = await _auth.createUserWithEmailAndPassword(
        email: cleanEmail,
        password: password,
      );

      final fbUser = credential.user;
      if (fbUser == null) {
        throw const AuthException(message: 'Failed to create account. Please try again.');
      }

      // Update Firebase display name
      await fbUser.updateDisplayName(cleanUsername);

      // 2. Provision User Profile in Cloud Firestore
      final userModel = UserModel(
        uid: fbUser.uid,
        username: cleanUsername,
        email: cleanEmail,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        preferences: const {
          'theme': 'system',
          'notificationsEnabled': true,
        },
      );

      await _firebaseService.usersCollection
          .doc(fbUser.uid)
          .set(userModel.toFirestore());

      AppLogger.info('AuthService: User registered successfully (${fbUser.uid})');
      return userModel;
    } on fb.FirebaseAuthException catch (e) {
      AppLogger.error('AuthService: Registration error: ${e.code}');
      throw AuthException(
        code: e.code,
        message: _mapFirebaseAuthError(e.code, e.message),
      );
    } catch (e) {
      AppLogger.error('AuthService: Unexpected registration error: $e');
      throw AuthException(message: 'Registration error: $e');
    }
  }

  /// Logs in an existing user with [email] and [password]
  Future<UserModel> loginWithEmailPassword({
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.trim();

    if (cleanEmail.isEmpty) {
      throw const AuthException(message: 'Please enter your email address.');
    }
    if (password.isEmpty) {
      throw const AuthException(message: 'Please enter your password.');
    }

    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: cleanEmail,
        password: password,
      );

      final fbUser = credential.user;
      if (fbUser == null) {
        throw const AuthException(message: 'Sign in failed. No user found.');
      }

      // Fetch or initialize profile from Cloud Firestore
      final doc = await _firebaseService.usersCollection.doc(fbUser.uid).get();

      if (doc.exists && doc.data() != null) {
        return UserModel.fromFirestore(doc);
      } else {
        // Fallback: create Firestore profile if missing
        final userModel = UserModel.fromFirebaseUser(fbUser);
        await _firebaseService.usersCollection.doc(fbUser.uid).set(userModel.toFirestore());
        return userModel;
      }
    } on fb.FirebaseAuthException catch (e) {
      AppLogger.error('AuthService: Login error: ${e.code}');
      throw AuthException(
        code: e.code,
        message: _mapFirebaseAuthError(e.code, e.message),
      );
    } catch (e) {
      AppLogger.error('AuthService: Unexpected login error: $e');
      throw AuthException(message: 'Sign in error: $e');
    }
  }

  /// Fetches the profile for the currently signed-in user
  Future<UserModel?> getCurrentUserProfile() async {
    final fbUser = _auth.currentUser;
    if (fbUser == null) return null;

    try {
      final doc = await _firebaseService.usersCollection.doc(fbUser.uid).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromFirestore(doc);
      }
      return UserModel.fromFirebaseUser(fbUser);
    } catch (e) {
      AppLogger.warning('AuthService: Failed to retrieve user profile: $e');
      return UserModel.fromFirebaseUser(fbUser);
    }
  }

  /// Sends a password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    final cleanEmail = email.trim();
    if (cleanEmail.isEmpty) {
      throw const AuthException(message: 'Please provide a valid email address.');
    }

    try {
      await _auth.sendPasswordResetEmail(email: cleanEmail);
      AppLogger.info('AuthService: Password reset email sent to $cleanEmail');
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException(
        code: e.code,
        message: _mapFirebaseAuthError(e.code, e.message),
      );
    } catch (e) {
      throw AuthException(message: 'Password reset error: $e');
    }
  }

  /// Logs out the current user session
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      AppLogger.info('AuthService: User signed out successfully');
    } catch (e) {
      AppLogger.error('AuthService: Sign out error: $e');
      throw AuthException(message: 'Failed to sign out: $e');
    }
  }

  /// Maps Firebase error codes to clear, friendly error messages
  String _mapFirebaseAuthError(String code, String? defaultMessage) {
    switch (code) {
      case 'email-already-in-use':
        return 'An account with this email address already exists. Please sign in instead.';
      case 'invalid-email':
        return 'The email address format is invalid. Please check and try again.';
      case 'weak-password':
        return 'The password is too weak. Please use at least 6 characters with mixed symbols/numbers.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Invalid email or password. Please verify your credentials and try again.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      case 'too-many-requests':
        return 'Too many unsuccessful attempts. Access temporarily blocked for security. Try again later.';
      case 'network-request-failed':
        return 'Network connection failed. Please check your internet connection.';
      case 'operation-not-allowed':
        return 'Email/password sign-in is not enabled in Firebase Console.';
      default:
        return defaultMessage ?? 'An authentication error occurred. Please try again.';
    }
  }
}

