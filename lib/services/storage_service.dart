import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/utils/app_logger.dart';
import '../models/book_model.dart';

/// Task 16: Local Storage Service Source Code (4 points)
/// Manages local data persistence for favorites, theme mode, and settings using SharedPreferences
class StorageService {
  final SharedPreferences? prefs;

  static const String _keyFavoriteBooks = 'pref_favorite_books_json';
  static const String _keyFavoriteIds = 'pref_favorite_book_ids';
  static const String _keyThemeMode = 'pref_theme_mode';
  static const String _keyNotifications = 'pref_notifications_enabled';

  StorageService({this.prefs});

  Future<SharedPreferences> get _instance async => prefs ?? await SharedPreferences.getInstance();

  // ==================== FAVORITES PERSISTENCE ====================

  /// Persists a book to local favorites storage
  Future<bool> saveFavoriteBook(BookModel book) async {
    try {
      final prefs = await _instance;

      // 1. Update ID set
      final idList = await getFavoriteBookIds();
      if (!idList.contains(book.id)) {
        idList.add(book.id);
        await prefs.setStringList(_keyFavoriteIds, idList);
      }

      // 2. Update Book JSON list
      final books = await getFavoriteBooks();
      books.removeWhere((b) => b.id == book.id);
      books.insert(0, book);

      final encodedList = books.map((b) => json.encode(b.toJson())).toList();
      final success = await prefs.setStringList(_keyFavoriteBooks, encodedList);

      AppLogger.info('StorageService: Saved favorite book "${book.title}" (${book.id})');
      return success;
    } catch (e) {
      AppLogger.error('StorageService: Failed to save favorite: $e');
      return false;
    }
  }

  /// Removes a book from local favorites storage
  Future<bool> removeFavoriteBook(String bookId) async {
    try {
      final prefs = await _instance;

      // 1. Remove from ID set
      final idList = await getFavoriteBookIds();
      idList.remove(bookId);
      await prefs.setStringList(_keyFavoriteIds, idList);

      // 2. Remove from Book JSON list
      final books = await getFavoriteBooks();
      books.removeWhere((b) => b.id == bookId);

      final encodedList = books.map((b) => json.encode(b.toJson())).toList();
      final success = await prefs.setStringList(_keyFavoriteBooks, encodedList);

      AppLogger.info('StorageService: Removed favorite book ($bookId)');
      return success;
    } catch (e) {
      AppLogger.error('StorageService: Failed to remove favorite: $e');
      return false;
    }
  }

  /// Retrieves all saved favorite books from local storage
  Future<List<BookModel>> getFavoriteBooks() async {
    try {
      final prefs = await _instance;
      final encodedList = prefs.getStringList(_keyFavoriteBooks) ?? [];

      return encodedList.map((encoded) {
        final Map<String, dynamic> map = json.decode(encoded) as Map<String, dynamic>;
        return BookModel.fromJson(map);
      }).toList();
    } catch (e) {
      AppLogger.error('StorageService: Failed to load favorite books: $e');
      return [];
    }
  }

  /// Retrieves the list of favorite book IDs
  Future<List<String>> getFavoriteBookIds() async {
    final prefs = await _instance;
    return prefs.getStringList(_keyFavoriteIds) ?? [];
  }

  /// Checks if a book ID is saved as favorite locally
  Future<bool> isBookFavorite(String bookId) async {
    final idList = await getFavoriteBookIds();
    return idList.contains(bookId);
  }

  /// Clears all stored favorites
  Future<bool> clearFavorites() async {
    final prefs = await _instance;
    await prefs.remove(_keyFavoriteIds);
    return await prefs.remove(_keyFavoriteBooks);
  }

  // ==================== PREFERENCES PERSISTENCE ====================

  /// Saves theme preference ('system', 'light', or 'dark')
  Future<bool> saveThemeMode(String themeMode) async {
    final prefs = await _instance;
    return await prefs.setString(_keyThemeMode, themeMode);
  }

  /// Retrieves saved theme preference
  Future<String> getThemeMode() async {
    final prefs = await _instance;
    return prefs.getString(_keyThemeMode) ?? 'system';
  }

  /// Saves local notifications preference
  Future<bool> saveNotificationsEnabled(bool enabled) async {
    final prefs = await _instance;
    return await prefs.setBool(_keyNotifications, enabled);
  }

  /// Retrieves local notifications preference
  Future<bool> getNotificationsEnabled() async {
    final prefs = await _instance;
    return prefs.getBool(_keyNotifications) ?? true;
  }
}
