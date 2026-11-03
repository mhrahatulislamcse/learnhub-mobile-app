import 'package:flutter_test/flutter_test.dart';
import 'package:learnhub/features/favorites/providers/favorites_provider.dart';
import 'package:learnhub/models/book_model.dart';
import 'package:learnhub/services/firebase_service.dart';
import 'package:learnhub/services/storage_service.dart';
import 'package:mocktail/mocktail.dart';

class MockStorageService extends Mock implements StorageService {}
class MockFirebaseService extends Mock implements FirebaseService {}

void main() {
  late MockStorageService mockStorageService;
  late MockFirebaseService mockFirebaseService;
  late FavoritesProvider favoritesProvider;

  const testBook = BookModel(
    id: 'OL_FAV_10',
    title: 'Clean Architecture in Flutter',
    authors: ['Robert Martin'],
    firstPublishYear: '2022',
  );

  setUpAll(() {
    registerFallbackValue(testBook);
  });

  setUp(() {
    mockStorageService = MockStorageService();
    mockFirebaseService = MockFirebaseService();

    when(() => mockStorageService.getFavoriteBooks())
        .thenAnswer((_) async => []);
    when(() => mockStorageService.saveFavoriteBook(any()))
        .thenAnswer((_) async => true);
    when(() => mockStorageService.removeFavoriteBook(any()))
        .thenAnswer((_) async => true);

    favoritesProvider = FavoritesProvider(
      storageService: mockStorageService,
      firebaseService: mockFirebaseService,
    );
  });

  group('FavoritesProvider Tests', () {
    test('initial state has empty favorites', () {
      expect(favoritesProvider.favorites, isEmpty);
      expect(favoritesProvider.count, equals(0));
      expect(favoritesProvider.isFavorite('OL_FAV_10'), isFalse);
    });

    test('addFavorite adds book to list and calls StorageService', () async {
      await favoritesProvider.addFavorite(testBook);

      expect(favoritesProvider.favorites.length, equals(1));
      expect(favoritesProvider.isFavorite('OL_FAV_10'), isTrue);
      expect(favoritesProvider.count, equals(1));
      verify(() => mockStorageService.saveFavoriteBook(testBook)).called(1);
    });

    test('removeFavorite removes book from list and calls StorageService', () async {
      await favoritesProvider.addFavorite(testBook);
      expect(favoritesProvider.isFavorite('OL_FAV_10'), isTrue);

      await favoritesProvider.removeFavorite('OL_FAV_10');

      expect(favoritesProvider.favorites, isEmpty);
      expect(favoritesProvider.isFavorite('OL_FAV_10'), isFalse);
      verify(() => mockStorageService.removeFavoriteBook('OL_FAV_10')).called(1);
    });

    test('toggleFavorite toggles state from false to true and back', () async {
      final added = await favoritesProvider.toggleFavorite(testBook);
      expect(added, isTrue);
      expect(favoritesProvider.isFavorite('OL_FAV_10'), isTrue);

      final removed = await favoritesProvider.toggleFavorite(testBook);
      expect(removed, isFalse);
      expect(favoritesProvider.isFavorite('OL_FAV_10'), isFalse);
    });
  });
}
