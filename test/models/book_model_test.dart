import 'package:flutter_test/flutter_test.dart';
import 'package:learnhub/models/book_model.dart';

void main() {
  group('BookModel Tests', () {
    final openLibrarySample = {
      'key': '/works/OL45804W',
      'title': 'Flutter in Action',
      'author_name': ['Eric Windmill'],
      'first_publish_year': 2020,
      'cover_i': 10521406,
      'subject': ['Flutter (Software framework)', 'Dart (Computer program language)', 'Mobile apps'],
      'edition_count': 3,
      'language': ['eng'],
    };

    test('fromOpenLibraryJson parses fields correctly', () {
      final book = BookModel.fromOpenLibraryJson(openLibrarySample);

      expect(book.id, equals('OL45804W'));
      expect(book.title, equals('Flutter in Action'));
      expect(book.authors, contains('Eric Windmill'));
      expect(book.firstPublishYear, equals('2020'));
      expect(book.coverId, equals(10521406));
      expect(book.coverUrl, contains('10521406-M.jpg'));
      expect(book.subjects.length, equals(3));
      expect(book.language, equals('ENG'));
    });

    test('serializes to and from JSON correctly', () {
      const book = BookModel(
        id: 'OL123W',
        title: 'Dart Apprentice',
        authors: ['Jonathan Sande', 'Matt Galloway'],
        firstPublishYear: '2021',
        coverUrl: 'https://covers.openlibrary.org/b/id/123-M.jpg',
        editionCount: 2,
        language: 'EN',
      );

      final json = book.toJson();
      final fromJsonBook = BookModel.fromJson(json);

      expect(fromJsonBook.id, equals(book.id));
      expect(fromJsonBook.title, equals(book.title));
      expect(fromJsonBook.authors, equals(book.authors));
      expect(fromJsonBook.authorDisplay, equals('Jonathan Sande, Matt Galloway'));
    });

    test('toFirestore formats fields for cloud storage', () {
      const book = BookModel(
        id: 'OL999W',
        title: 'Clean Code',
        authors: ['Robert C. Martin'],
      );

      final firestoreMap = book.toFirestore();
      expect(firestoreMap['id'], equals('OL999W'));
      expect(firestoreMap['title'], equals('Clean Code'));
      expect(firestoreMap['author'], equals('Robert C. Martin'));
      expect(firestoreMap.containsKey('savedAt'), isTrue);
    });

    test('handles missing authors and covers gracefully', () {
      final emptyJson = <String, dynamic>{'title': 'Mystery Book'};
      final book = BookModel.fromOpenLibraryJson(emptyJson);

      expect(book.title, equals('Mystery Book'));
      expect(book.authors, equals(['Unknown Author']));
      expect(book.coverUrl, isNull);
    });
  });
}
