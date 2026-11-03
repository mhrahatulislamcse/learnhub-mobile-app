import 'package:flutter_test/flutter_test.dart';
import 'package:learnhub/models/book_model.dart';
import 'package:learnhub/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late StorageService storageService;

  const sampleBook = BookModel(
    id: 'OL_TEST_1',
    title: 'Design Patterns',
    authors: ['Gang of Four'],
    firstPublishYear: '1994',
    coverUrl: 'https://covers.openlibrary.org/b/id/100-M.jpg',
  );

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    storageService = StorageService(prefs: prefs);
  });

  group('StorageService Tests (Task 16)', () {
    test('saveFavoriteBook persists book and ID in SharedPreferences', () async {
      final success = await storageService.saveFavoriteBook(sampleBook);
      expect(success, isTrue);

      final isFav = await storageService.isBookFavorite('OL_TEST_1');
      expect(isFav, isTrue);

      final books = await storageService.getFavoriteBooks();
      expect(books.length, equals(1));
      expect(books.first.title, equals('Design Patterns'));
      expect(books.first.id, equals('OL_TEST_1'));
    });

    test('removeFavoriteBook removes book and ID from SharedPreferences', () async {
      await storageService.saveFavoriteBook(sampleBook);
      expect(await storageService.isBookFavorite('OL_TEST_1'), isTrue);

      final removed = await storageService.removeFavoriteBook('OL_TEST_1');
      expect(removed, isTrue);

      expect(await storageService.isBookFavorite('OL_TEST_1'), isFalse);
      expect(await storageService.getFavoriteBooks(), isEmpty);
    });

    test('saveThemeMode persists and retrieves theme preference', () async {
      await storageService.saveThemeMode('dark');
      final mode = await storageService.getThemeMode();
      expect(mode, equals('dark'));
    });

    test('saveNotificationsEnabled persists and retrieves notification setting', () async {
      await storageService.saveNotificationsEnabled(false);
      final enabled = await storageService.getNotificationsEnabled();
      expect(enabled, isFalse);
    });

    test('clearFavorites wipes all stored favorite data', () async {
      await storageService.saveFavoriteBook(sampleBook);
      expect(await storageService.getFavoriteBooks(), isNotEmpty);

      await storageService.clearFavorites();
      expect(await storageService.getFavoriteBooks(), isEmpty);
      expect(await storageService.getFavoriteBookIds(), isEmpty);
    });
  });
}

