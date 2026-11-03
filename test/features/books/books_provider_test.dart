import 'package:flutter_test/flutter_test.dart';
import 'package:learnhub/core/errors/exceptions.dart';
import 'package:learnhub/features/books/providers/books_provider.dart';
import 'package:learnhub/models/book_model.dart';
import 'package:learnhub/services/api_service.dart';
import 'package:mocktail/mocktail.dart';

class MockApiService extends Mock implements ApiService {}

void main() {
  late MockApiService mockApiService;
  late BooksProvider booksProvider;

  const testBook = BookModel(
    id: 'OL100W',
    title: 'Effective Dart',
    authors: ['Google Engineers'],
    firstPublishYear: '2020',
  );

  setUp(() {
    mockApiService = MockApiService();
    when(() => mockApiService.getFeaturedBooks(limit: any(named: 'limit')))
        .thenAnswer((_) async => [testBook]);

    booksProvider = BooksProvider(apiService: mockApiService);
  });

  group('BooksProvider Tests', () {
    test('initial state loads featured books', () async {
      // Allow initial load to complete
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(booksProvider.featuredBooks.length, equals(1));
      expect(booksProvider.displayBooks.length, equals(1));
      expect(booksProvider.isSearching, isFalse);
      expect(booksProvider.selectedCategory, equals('All'));
    });

    test('searchBooks updates searchResults and sets isSearching to true', () async {
      when(() => mockApiService.searchBooks('algorithms', limit: any(named: 'limit')))
          .thenAnswer((_) async => [testBook]);

      await booksProvider.searchBooks('algorithms');

      expect(booksProvider.isSearching, isTrue);
      expect(booksProvider.currentQuery, equals('algorithms'));
      expect(booksProvider.searchResults.length, equals(1));
      expect(booksProvider.displayBooks.length, equals(1));
    });

    test('searchBooks sets errorMessage on NetworkException', () async {
      when(() => mockApiService.searchBooks('offline', limit: any(named: 'limit')))
          .thenThrow(const NetworkException(message: 'No internet connection'));

      await booksProvider.searchBooks('offline');

      expect(booksProvider.errorMessage, equals('No internet connection'));
      expect(booksProvider.searchResults, isEmpty);
    });

    test('selectCategory updates selectedCategory and fetches category books', () async {
      when(() => mockApiService.getBooksByCategory('Programming', limit: any(named: 'limit')))
          .thenAnswer((_) async => [testBook]);

      await booksProvider.selectCategory('Programming');

      expect(booksProvider.selectedCategory, equals('Programming'));
      expect(booksProvider.isSearching, isFalse);
    });

    test('selectBook sets selectedBook property', () {
      booksProvider.selectBook(testBook);
      expect(booksProvider.selectedBook, equals(testBook));
    });

    test('clearSearch clears query and searchResults', () async {
      when(() => mockApiService.searchBooks('test', limit: any(named: 'limit')))
          .thenAnswer((_) async => [testBook]);

      await booksProvider.searchBooks('test');
      expect(booksProvider.isSearching, isTrue);

      booksProvider.clearSearch();
      expect(booksProvider.isSearching, isFalse);
      expect(booksProvider.currentQuery, isEmpty);
      expect(booksProvider.searchResults, isEmpty);
    });
  });
}
