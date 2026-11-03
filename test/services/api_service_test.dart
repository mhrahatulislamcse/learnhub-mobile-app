import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:learnhub/core/errors/exceptions.dart';
import 'package:learnhub/services/api_service.dart';
import 'package:mocktail/mocktail.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  late MockHttpClient mockClient;
  late ApiService apiService;

  setUpAll(() {
    registerFallbackValue(Uri.parse('https://openlibrary.org'));
  });

  setUp(() {
    mockClient = MockHttpClient();
    apiService = ApiService(client: mockClient);
  });

  group('ApiService Tests', () {
    const query = 'flutter';
    final sampleResponse = {
      'numFound': 1,
      'docs': [
        {
          'key': '/works/OL123W',
          'title': 'Flutter Apprentice',
          'author_name': ['Mike Katz'],
          'first_publish_year': 2021,
          'cover_i': 123456,
        }
      ]
    };

    test('searchBooks returns parsed books list on 200 OK', () async {
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response(json.encode(sampleResponse), 200));

      final books = await apiService.searchBooks(query);

      expect(books.length, equals(1));
      expect(books.first.title, equals('Flutter Apprentice'));
      expect(books.first.authors, contains('Mike Katz'));
      expect(books.first.id, equals('OL123W'));
    });

    test('searchBooks returns empty list for empty query without network call', () async {
      final books = await apiService.searchBooks('   ');
      expect(books, isEmpty);
      verifyNever(() => mockClient.get(any(), headers: any(named: 'headers')));
    });

    test('searchBooks throws ServerException on non-200 status', () async {
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response('Service Unavailable', 503));

      expect(
        () async => await apiService.searchBooks(query),
        throwsA(isA<ServerException>()),
      );
    });

    test('searchBooks throws NetworkException on client connection failure', () async {
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenThrow(http.ClientException('Failed to connect'));

      expect(
        () async => await apiService.searchBooks(query),
        throwsA(isA<NetworkException>()),
      );
    });
  });
}
