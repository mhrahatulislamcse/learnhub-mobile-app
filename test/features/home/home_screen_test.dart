import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learnhub/features/auth/providers/auth_provider.dart';
import 'package:learnhub/features/auth/services/auth_service.dart';
import 'package:learnhub/features/books/providers/books_provider.dart';
import 'package:learnhub/features/favorites/providers/favorites_provider.dart';
import 'package:learnhub/features/home/screens/home_screen.dart';
import 'package:learnhub/features/home/widgets/book_card.dart';
import 'package:learnhub/models/book_model.dart';
import 'package:learnhub/services/api_service.dart';
import 'package:learnhub/services/firebase_service.dart';
import 'package:learnhub/services/storage_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

class MockAuthService extends Mock implements AuthService {}
class MockApiService extends Mock implements ApiService {}
class MockStorageService extends Mock implements StorageService {}
class MockFirebaseService extends Mock implements FirebaseService {}

void main() {
  late MockAuthService mockAuthService;
  late MockApiService mockApiService;
  late MockStorageService mockStorageService;
  late MockFirebaseService mockFirebaseService;

  late AuthProvider authProvider;
  late BooksProvider booksProvider;
  late FavoritesProvider favoritesProvider;

  const sampleBook = BookModel(
    id: 'OL100W',
    title: 'Flutter in Depth',
    authors: ['Expert Developer'],
    firstPublishYear: '2023',
    language: 'EN',
  );

  setUpAll(() {
    registerFallbackValue(sampleBook);
  });

  setUp(() {
    mockAuthService = MockAuthService();
    mockApiService = MockApiService();
    mockStorageService = MockStorageService();
    mockFirebaseService = MockFirebaseService();

    when(() => mockAuthService.authStateChanges)
        .thenAnswer((_) => Stream.value(null));
    when(() => mockAuthService.currentFirebaseUser).thenReturn(null);

    when(() => mockApiService.getFeaturedBooks(limit: any(named: 'limit')))
        .thenAnswer((_) async => [sampleBook]);
    when(() => mockApiService.searchBooks(any(), limit: any(named: 'limit')))
        .thenAnswer((_) async => [sampleBook]);

    when(() => mockStorageService.getFavoriteBooks())
        .thenAnswer((_) async => []);
    when(() => mockStorageService.saveFavoriteBook(any()))
        .thenAnswer((_) async => true);
    when(() => mockStorageService.removeFavoriteBook(any()))
        .thenAnswer((_) async => true);

    authProvider = AuthProvider(authService: mockAuthService);
    booksProvider = BooksProvider(apiService: mockApiService);
    favoritesProvider = FavoritesProvider(
      storageService: mockStorageService,
      firebaseService: mockFirebaseService,
    );
  });

  Widget buildTestApp() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        ChangeNotifierProvider<BooksProvider>.value(value: booksProvider),
        ChangeNotifierProvider<FavoritesProvider>.value(value: favoritesProvider),
      ],
      child: const MaterialApp(
        home: HomeScreen(),
      ),
    );
  }

  group('HomeScreen Widget Tests (Tasks 11 & 12)', () {
    testWidgets('renders header, discovery banner, search bar, and book list', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestApp());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // App title & branding
      expect(find.text('LearnHub'), findsOneWidget);

      // Discovery banner
      expect(find.textContaining('Hello,'), findsOneWidget);

      // Category chips
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Flutter'), findsOneWidget);
      expect(find.text('Computer Science'), findsOneWidget);

      // Book card rendered
      expect(find.text('Flutter in Depth'), findsOneWidget);
      expect(find.text('Expert Developer'), findsOneWidget);
      expect(find.byType(BookCard), findsOneWidget);
    });

    testWidgets('triggers search on query entry', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestApp());
      await tester.pump();

      // Enter search query
      await tester.enterText(find.byType(TextField), 'Dart');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Search Results for "Dart"'), findsOneWidget);
    });
  });
}
