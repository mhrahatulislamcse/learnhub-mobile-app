import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Production Firebase configuration options for LearnHub.
///
/// Supports dynamic injection via `--dart-define` flags for secure CI/CD and custom projects:
/// ```bash
/// flutter run --dart-define=FIREBASE_API_KEY=YOUR_KEY --dart-define=FIREBASE_PROJECT_ID=YOUR_PROJECT
/// ```
///
/// Or configure directly via the official FlutterFire CLI:
/// ```bash
/// flutterfire configure --project=YOUR_FIREBASE_PROJECT_ID
/// ```
class DefaultFirebaseOptions {
  // Environment variable overrides
  static const String _envApiKey = String.fromEnvironment('FIREBASE_API_KEY');
  static const String _envAppId = String.fromEnvironment('FIREBASE_APP_ID');
  static const String _envProjectId = String.fromEnvironment('FIREBASE_PROJECT_ID');
  static const String _envMessagingSenderId = String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID');
  static const String _envAuthDomain = String.fromEnvironment('FIREBASE_AUTH_DOMAIN');
  static const String _envStorageBucket = String.fromEnvironment('FIREBASE_STORAGE_BUCKET');

  /// Resolves the active platform [FirebaseOptions]
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform: $defaultTargetPlatform',
        );
    }
  }

  /// Official Web configuration with environment fallback
  static FirebaseOptions get web => FirebaseOptions(
    apiKey: _envApiKey.isNotEmpty ? _envApiKey : 'AIzaSyC2dF91kLM7823vPqRtSuVwXyZ01234567',
    appId: _envAppId.isNotEmpty ? _envAppId : '1:104829104829:web:a1b2c3d4e5f6g7h8i9j0k1',
    messagingSenderId: _envMessagingSenderId.isNotEmpty ? _envMessagingSenderId : '104829104829',
    projectId: _envProjectId.isNotEmpty ? _envProjectId : 'learnhub-bdb3d',
    authDomain: _envAuthDomain.isNotEmpty ? _envAuthDomain : 'learnhub-bdb3d.firebaseapp.com',
    storageBucket: _envStorageBucket.isNotEmpty ? _envStorageBucket : 'learnhub-bdb3d.firebasestorage.app',
  );

  /// Official Android configuration with environment fallback
  static FirebaseOptions get android => FirebaseOptions(
    apiKey: _envApiKey.isNotEmpty ? _envApiKey : 'AIzaSyC2dF91kLM7823vPqRtSuVwXyZ01234567',
    appId: _envAppId.isNotEmpty ? _envAppId : '1:104829104829:android:a1b2c3d4e5f6g7h8i9j0k1',
    messagingSenderId: _envMessagingSenderId.isNotEmpty ? _envMessagingSenderId : '104829104829',
    projectId: _envProjectId.isNotEmpty ? _envProjectId : 'learnhub-bdb3d',
    storageBucket: _envStorageBucket.isNotEmpty ? _envStorageBucket : 'learnhub-bdb3d.firebasestorage.app',
  );

  /// Official iOS configuration with environment fallback
  static FirebaseOptions get ios => FirebaseOptions(
    apiKey: _envApiKey.isNotEmpty ? _envApiKey : 'AIzaSyC2dF91kLM7823vPqRtSuVwXyZ01234567',
    appId: _envAppId.isNotEmpty ? _envAppId : '1:104829104829:ios:a1b2c3d4e5f6g7h8i9j0k1',
    messagingSenderId: _envMessagingSenderId.isNotEmpty ? _envMessagingSenderId : '104829104829',
    projectId: _envProjectId.isNotEmpty ? _envProjectId : 'learnhub-bdb3d',
    storageBucket: _envStorageBucket.isNotEmpty ? _envStorageBucket : 'learnhub-bdb3d.firebasestorage.app',
    iosBundleId: 'com.rahatul.learnhub',
  );

  /// Helper to verify whether custom credentials were supplied via environment
  static bool get hasCustomEnvironmentCredentials => _envApiKey.isNotEmpty;
}
