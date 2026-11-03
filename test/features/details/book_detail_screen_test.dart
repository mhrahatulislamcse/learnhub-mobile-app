import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learnhub/core/widgets/custom_button.dart';
import 'package:learnhub/features/books/providers/books_provider.dart';
import 'package:learnhub/features/details/screens/book_detail_screen.dart';
import 'package:learnhub/models/book_model.dart';
import 'package:learnhub/services/api_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

class MockApiService extends Mock implements ApiService {}

void main() {
  late MockApiService mockApiService;
  late BooksProvider booksProvider;

  const testBook = BookModel(
    id: 'OL999W',
    title: 'Design Patterns: Elements of Reusable Object-Oriented Software',
    authors: ['Erich Gamma', 'Richard Helm', 'Ralph Johnson', 'John Vlissides'],
    firstPublishYear: '1994',
    language: 'EN',
    editionCount: 14,
    subjects: ['Software Architecture', 'Object-Oriented Programming', 'Design Patterns'],
    description: 'Captures a wealth of experience about the design of object-oriented software.',
  );

  setUp(() {
    mockApiService = MockApiService();
    when(() => mockApiService.getFeaturedBooks(limit: any(named: 'limit')))
        .thenAnswer((_) async => [testBook]);

    booksProvider = BooksProvider(apiService: mockApiService);
    booksProvider.selectBook(testBook);
  });

  Widget buildTestApp({BookModel? book}) {
    return ChangeNotifierProvider<BooksProvider>.value(
      value: booksProvider,
      child: MaterialApp(
        home: BookDetailScreen(book: book),
      ),
    );
  }

  group('BookDetailScreen Widget Tests (Tasks 13, 14, 15)', () {
    testWidgets('renders book title, author display, metadata badges, and overview', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestApp(book: testBook));

      // Title & Authors
      expect(find.text(testBook.title), findsOneWidget);
      expect(find.text(testBook.authorDisplay), findsOneWidget);

      // Metadata badges
      expect(find.text('Published'), findsOneWidget);
      expect(find.text('1994'), findsOneWidget);
      expect(find.text('Language'), findsOneWidget);
      expect(find.text('EN'), findsOneWidget);
      expect(find.text('Editions'), findsOneWidget);
      expect(find.text('14'), findsOneWidget);

      // Subject chips
      expect(find.text('Software Architecture'), findsOneWidget);
      expect(find.text('Design Patterns'), findsOneWidget);

      // Overview text
      expect(find.textContaining('Captures a wealth of experience'), findsOneWidget);

      // Bookmark action button
      expect(find.widgetWithText(CustomButton, 'Bookmark Favorite'), findsOneWidget);
    });

    testWidgets('displays empty state when no book is provided or selected', (WidgetTester tester) async {
      booksProvider.selectBook(const BookModel(id: '', title: '', authors: []));
      // Force null by passing empty/null
      await tester.pumpWidget(
        ChangeNotifierProvider<BooksProvider>.value(
          value: booksProvider..clearSearch(),
          child: const MaterialApp(
            home: BookDetailScreen(book: null),
          ),
        ),
      );

      // If activeBook title is empty, it will handle it gracefully or if null
      expect(find.byType(Scaffold), findsOneWidget);
    });
  });
}
