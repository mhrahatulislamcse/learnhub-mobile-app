import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import '../core/utils/app_logger.dart';
import '../firebase_options.dart';

/// Centralized service handling Firebase initialization, Auth, and Firestore collections
class FirebaseService {
  static final FirebaseService instance = FirebaseService._internal();

  FirebaseService._internal();

  FirebaseAuth get auth => FirebaseAuth.instance;
  FirebaseFirestore get firestore => FirebaseFirestore.instance;

  /// Global initialization for Firebase Core
  static Future<void> initialize() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      AppLogger.info('FirebaseService: Firebase Core initialized successfully');
    } catch (e) {
      AppLogger.warning('FirebaseService: Notice during initialization: $e');
    }
  }

  /// References to Firestore collections as defined in Project Specification Section 7
  CollectionReference<Map<String, dynamic>> get usersCollection =>
      firestore.collection('users');

  CollectionReference<Map<String, dynamic>> userFavoritesCollection(String uid) =>
      firestore.collection('favorites').doc(uid).collection('books');
}

