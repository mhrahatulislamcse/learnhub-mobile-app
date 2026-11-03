import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learnhub/core/widgets/custom_button.dart';
import 'package:learnhub/features/auth/providers/auth_provider.dart';
import 'package:learnhub/features/auth/services/auth_service.dart';
import 'package:learnhub/features/books/providers/books_provider.dart';
import 'package:learnhub/features/favorites/providers/favorites_provider.dart';
import 'package:learnhub/features/favorites/screens/favorites_screen.dart';
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

  const testBook = BookModel(
    id: 'OL_TEST_FAV',
    title: 'Structure and Interpretation of Computer Programs',
    authors: ['Harold Abelson', 'Gerald Jay Sussman'],
    firstPublishYear: '1985',
  );

  setUpAll(() {
    registerFallbackValue(testBook);
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
        .thenAnswer((_) async => []);

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
        home: FavoritesScreen(),
      ),
    );
  }

  group('FavoritesScreen Widget Tests', () {
    testWidgets('displays empty state illustration and Browse Books button when empty', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pump();

      expect(find.text('My Favorites'), findsOneWidget);
      expect(find.text('No Favorites Saved Yet'), findsOneWidget);
      expect(find.widgetWithText(CustomButton, 'Browse Books'), findsOneWidget);
    });

    testWidgets('displays saved book cards and removal action when favorites exist', (WidgetTester tester) async {
      await favoritesProvider.addFavorite(testBook);

      await tester.pumpWidget(buildTestApp());
      await tester.pump();

      expect(find.text('My Favorites'), findsOneWidget);
      expect(find.text(testBook.title), findsOneWidget);
      expect(find.text(testBook.authorDisplay), findsOneWidget);
      expect(find.byType(BookCard), findsOneWidget);
      expect(find.byIcon(Icons.bookmark_remove_rounded), findsOneWidget);
    });

    testWidgets('tapping remove button removes book from favorites', (WidgetTester tester) async {
      await favoritesProvider.addFavorite(testBook);

      await tester.pumpWidget(buildTestApp());
      await tester.pump();

      expect(find.byType(BookCard), findsOneWidget);

      await tester.tap(find.byIcon(Icons.bookmark_remove_rounded));
      await tester.pump();

      expect(favoritesProvider.isFavorite(testBook.id), isFalse);
    });
  });
}
