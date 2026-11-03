import 'package:flutter/foundation.dart';
import '../../../core/utils/app_logger.dart';
import '../../../models/book_model.dart';
import '../../../services/firebase_service.dart';
import '../../../services/storage_service.dart';

/// Provider managing favorites state, local persistence, and Firestore cloud synchronization
class FavoritesProvider extends ChangeNotifier {
  final StorageService _storageService;
  final FirebaseService _firebaseService;

  List<BookModel> _favorites = [];
  Set<String> _favoriteIds = {};
  bool _isLoading = false;
  String? _errorMessage;

  FavoritesProvider({
    StorageService? storageService,
    FirebaseService? firebaseService,
  })  : _storageService = storageService ?? StorageService(),
        _firebaseService = firebaseService ?? FirebaseService.instance {
    loadFavorites();
  }

  List<BookModel> get favorites => _favorites;
  Set<String> get favoriteIds => _favoriteIds;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get count => _favorites.length;

  /// Checks if a book is currently in favorites
  bool isFavorite(String bookId) => _favoriteIds.contains(bookId);

  /// Loads favorites from local storage, then syncs with Firestore if [userId] is available
  Future<void> loadFavorites({String? userId}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Fast local load from SharedPreferences
      final localBooks = await _storageService.getFavoriteBooks();
      _favorites = localBooks;
      _favoriteIds = localBooks.map((b) => b.id).toSet();
      AppLogger.info('FavoritesProvider: Loaded ${_favorites.length} local favorites');

      // 2. Cloud sync if user is authenticated
      if (userId != null && userId.isNotEmpty) {
        try {
          final snapshot = await _firebaseService.userFavoritesCollection(userId).get();
          final cloudBooks = snapshot.docs.map((doc) {
            final data = doc.data();
            return BookModel(
              id: doc.id,
              title: data['title'] as String? ?? 'Untitled Book',
              authors: data['authors'] is List
                  ? (data['authors'] as List).map((e) => e.toString()).toList()
                  : [data['author']?.toString() ?? 'Unknown Author'],
              coverUrl: data['coverUrl'] as String?,
              firstPublishYear: data['firstPublishYear'] as String?,
            );
          }).toList();

          if (cloudBooks.isNotEmpty) {
            // Merge cloud items into local list
            for (final cloudBook in cloudBooks) {
              if (!_favoriteIds.contains(cloudBook.id)) {
                _favorites.add(cloudBook);
                _favoriteIds.add(cloudBook.id);
                await _storageService.saveFavoriteBook(cloudBook);
              }
            }
          }
        } catch (cloudError) {
          AppLogger.warning('FavoritesProvider: Cloud sync notice (offline or unauthenticated): $cloudError');
        }
      }
    } catch (e) {
      _errorMessage = 'Failed to load favorites: $e';
      AppLogger.error('FavoritesProvider: Error loading favorites: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Toggles favorite state for a book
  Future<bool> toggleFavorite(BookModel book, {String? userId}) async {
    if (isFavorite(book.id)) {
      await removeFavorite(book.id, userId: userId);
      return false;
    } else {
      await addFavorite(book, userId: userId);
      return true;
    }
  }

  /// Adds a book to favorites locally and in Firestore
  Future<void> addFavorite(BookModel book, {String? userId}) async {
    _favorites.removeWhere((b) => b.id == book.id);
    _favorites.insert(0, book);
    _favoriteIds.add(book.id);
    notifyListeners();

    // 1. Persist locally to SharedPreferences
    await _storageService.saveFavoriteBook(book);

    // 2. Persist to Firestore if user is authenticated
    if (userId != null && userId.isNotEmpty) {
      try {
        await _firebaseService
            .userFavoritesCollection(userId)
            .doc(book.id)
            .set(book.toFirestore());
        AppLogger.info('FavoritesProvider: Synced added favorite "${book.title}" to Firestore');
      } catch (e) {
        AppLogger.warning('FavoritesProvider: Firestore save notice: $e');
      }
    }
  }

  /// Removes a book from favorites locally and in Firestore
  Future<void> removeFavorite(String bookId, {String? userId}) async {
    _favorites.removeWhere((b) => b.id == bookId);
    _favoriteIds.remove(bookId);
    notifyListeners();

    // 1. Remove from local SharedPreferences
    await _storageService.removeFavoriteBook(bookId);

    // 2. Remove from Firestore if user is authenticated
    if (userId != null && userId.isNotEmpty) {
      try {
        await _firebaseService
            .userFavoritesCollection(userId)
            .doc(bookId)
            .delete();
        AppLogger.info('FavoritesProvider: Removed favorite "$bookId" from Firestore');
      } catch (e) {
        AppLogger.warning('FavoritesProvider: Firestore delete notice: $e');
      }
    }
  }
}

