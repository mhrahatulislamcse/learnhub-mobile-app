import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import '../core/utils/app_logger.dart';
import '../firebase_options.dart';

/// Explicit status tracking for Firebase initialization
enum FirebaseInitStatus {
  uninitialized,
  initializing,
  connected,
  failed,
}

/// Centralized service handling Firebase initialization, Auth, and Firestore collections.
///
/// Implements production-ready lifecycle management, failure tracking, and safe accessors.
class FirebaseService {
  static final FirebaseService instance = FirebaseService._internal();

  FirebaseService._internal();

  static FirebaseInitStatus _status = FirebaseInitStatus.uninitialized;
  static Object? _lastError;
  static StackTrace? _lastStackTrace;

  /// Current initialization lifecycle status
  static FirebaseInitStatus get status => _status;

  /// Whether Firebase Core has completed initialization and is active
  static bool get isInitialized => _status == FirebaseInitStatus.connected;

  /// Last error captured during initialization, if any
  static Object? get lastError => _lastError;

  /// Stack trace associated with the initialization error
  static StackTrace? get lastStackTrace => _lastStackTrace;

  /// Resets state for testing purposes
  static void resetStateForTesting() {
    _status = FirebaseInitStatus.uninitialized;
    _lastError = null;
    _lastStackTrace = null;
  }

  /// Global initialization for Firebase Core.
  ///
  /// [fatalOnError]: If `true`, rethrows the underlying exception to halt startup
  /// in strict environments (e.g., CI/CD or production release builds).
  static Future<bool> initialize({bool fatalOnError = false}) async {
    if (_status == FirebaseInitStatus.connected) {
      return true;
    }

    _status = FirebaseInitStatus.initializing;
    AppLogger.info('FirebaseService: Initializing Firebase Core for platform...');

    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      _status = FirebaseInitStatus.connected;
      _lastError = null;
      _lastStackTrace = null;
      AppLogger.info(
        'FirebaseService: Firebase Core initialized successfully (apps: ${Firebase.apps.length}).',
      );
      return true;
    } catch (e, stack) {
      _status = FirebaseInitStatus.failed;
      _lastError = e;
      _lastStackTrace = stack;

      AppLogger.error(
        'FirebaseService: Fatal initialization failure: $e\n'
        'Ensure Firebase credentials in firebase_options.dart or --dart-define are configured.',
        e,
        stack,
      );

      if (fatalOnError) {
        throw FirebaseException(
          plugin: 'core',
          code: 'initialization-failed',
          message: 'Firebase Core initialization failed: $e',
        );
      }
      return false;
    }
  }

  /// Safe FirebaseAuth instance accessor
  FirebaseAuth get auth {
    if (!isInitialized && Firebase.apps.isEmpty) {
      AppLogger.warning(
        'FirebaseService: Accessing FirebaseAuth before Firebase is connected. Status: $_status',
      );
    }
    return FirebaseAuth.instance;
  }

  /// Safe FirebaseFirestore instance accessor
  FirebaseFirestore get firestore {
    if (!isInitialized && Firebase.apps.isEmpty) {
      AppLogger.warning(
        'FirebaseService: Accessing FirebaseFirestore before Firebase is connected. Status: $_status',
      );
    }
    return FirebaseFirestore.instance;
  }

  /// References to Firestore collections as defined in Project Specification Section 7
  CollectionReference<Map<String, dynamic>> get usersCollection =>
      firestore.collection('users');

  CollectionReference<Map<String, dynamic>> userFavoritesCollection(String uid) =>
      firestore.collection('favorites').doc(uid).collection('books');
}
