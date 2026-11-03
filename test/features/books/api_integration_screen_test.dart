import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learnhub/core/widgets/app_error_widget.dart';
import 'package:learnhub/core/widgets/loading_view.dart';
import 'package:learnhub/features/books/providers/books_provider.dart';
import 'package:learnhub/features/books/screens/api_integration_screen.dart';
import 'package:learnhub/models/book_model.dart';
import 'package:learnhub/services/api_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

class MockApiService extends Mock implements ApiService {}

void main() {
  late MockApiService mockApiService;
  late BooksProvider booksProvider;

  const testBooks = [
    BookModel(
      id: 'OL1001W',
      title: 'Flutter Apprentice',
      authors: ['Michael Katz'],
      firstPublishYear: '2021',
      language: 'eng',
    ),
    BookModel(
      id: 'OL1002W',
      title: 'Dart in Action',
      authors: ['Chris Buckett'],
      firstPublishYear: '2013',
      language: 'eng',
    ),
  ];

  setUp(() {
    mockApiService = MockApiService();
    booksProvider = BooksProvider(apiService: mockApiService);
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: ChangeNotifierProvider<BooksProvider>.value(
        value: booksProvider,
        child: ApiIntegrationScreen(apiService: mockApiService),
      ),
    );
  }

  group('ApiIntegrationScreen (Task 19 & 20)', () {
    testWidgets('renders screen headers, endpoint card, and fetched books', (tester) async {
      when(() => mockApiService.searchBooksWithMetadata('flutter', limit: any(named: 'limit')))
          .thenAnswer((_) async => const ApiResult(
                data: testBooks,
                totalFound: 1420,
                statusCode: 200,
                responseTimeMs: 345,
                requestUrl: 'https://openlibrary.org/search.json?q=flutter&limit=15',
              ));

      await tester.pumpWidget(createWidgetUnderTest());
      // Initial frame with loading
      expect(find.byType(LoadingView), findsOneWidget);

      await tester.pumpAndSettle();

      // Header and title
      expect(find.text('Open Library API'), findsOneWidget);
      expect(find.text('REST API • GET'), findsOneWidget);
      expect(find.text('Status: 200 OK'), findsOneWidget);

      // Latency and metrics
      expect(find.text('345 ms'), findsOneWidget);
      expect(find.text('1420'), findsOneWidget);
      expect(find.text('2'), findsWidgets); // 2 fetched books metric and card count

      // Books in list
      expect(find.text('Flutter Apprentice'), findsOneWidget);
      expect(find.text('Dart in Action'), findsOneWidget);
    });

    testWidgets('displays error widget when API call fails and allows retry', (tester) async {
      when(() => mockApiService.searchBooksWithMetadata('flutter', limit: any(named: 'limit')))
          .thenThrow(Exception('Failed to connect to Open Library server'));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.byType(AppErrorWidget), findsOneWidget);
      expect(find.textContaining('Failed to connect to Open Library server'), findsOneWidget);

      // When retry is tapped with working response
      when(() => mockApiService.searchBooksWithMetadata('flutter', limit: any(named: 'limit')))
          .thenAnswer((_) async => const ApiResult(
                data: testBooks,
                totalFound: 2,
                statusCode: 200,
                responseTimeMs: 120,
                requestUrl: 'https://openlibrary.org/search.json?q=flutter&limit=15',
              ));

      final tryAgainButton = find.text('Try Again');
      expect(tryAgainButton, findsOneWidget);
      await tester.ensureVisible(tryAgainButton);
      await tester.tap(tryAgainButton);
      await tester.pumpAndSettle();

      expect(find.byType(AppErrorWidget), findsNothing);
      expect(find.text('Flutter Apprentice'), findsOneWidget);
    });

    testWidgets('selecting preset chips triggers search with selected query', (tester) async {
      when(() => mockApiService.searchBooksWithMetadata(any(), limit: any(named: 'limit')))
          .thenAnswer((_) async => const ApiResult(
                data: testBooks,
                totalFound: 100,
                statusCode: 200,
                responseTimeMs: 150,
                requestUrl: 'https://openlibrary.org/search.json?q=algorithms&limit=15',
              ));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Tap preset chip 'algorithms'
      expect(find.text('algorithms'), findsOneWidget);
      await tester.tap(find.text('algorithms'));
      await tester.pumpAndSettle();

      verify(() => mockApiService.searchBooksWithMetadata('algorithms', limit: 15)).called(1);
    });
  });
}
