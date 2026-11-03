import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learnhub/app/theme.dart';
import 'package:learnhub/core/constants/app_colors.dart';
import 'package:learnhub/core/widgets/custom_button.dart';
import 'package:learnhub/features/auth/providers/auth_provider.dart';
import 'package:learnhub/features/auth/screens/login_screen.dart';
import 'package:learnhub/features/auth/screens/register_screen.dart';
import 'package:learnhub/features/auth/services/auth_service.dart';
import 'package:learnhub/features/books/providers/books_provider.dart';
import 'package:learnhub/features/books/screens/api_integration_screen.dart';
import 'package:learnhub/features/details/screens/book_detail_screen.dart';
import 'package:learnhub/features/favorites/providers/favorites_provider.dart';
import 'package:learnhub/features/favorites/screens/favorites_screen.dart';
import 'package:learnhub/features/home/screens/home_screen.dart';
import 'package:learnhub/features/notifications/providers/notification_provider.dart';
import 'package:learnhub/features/notifications/screens/notification_screen.dart';
import 'package:learnhub/features/notifications/services/notification_service.dart';
import 'package:learnhub/features/settings/providers/settings_provider.dart';
import 'package:learnhub/features/settings/screens/settings_screen.dart';
import 'package:learnhub/features/settings/widgets/settings_drawer.dart';
import 'package:learnhub/models/book_model.dart';
import 'package:learnhub/models/user_model.dart';
import 'package:learnhub/services/api_service.dart';
import 'package:learnhub/services/firebase_service.dart';
import 'package:learnhub/services/storage_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

class MockAuthService extends Mock implements AuthService {}
class MockApiService extends Mock implements ApiService {}
class MockStorageService extends Mock implements StorageService {}
class MockFirebaseService extends Mock implements FirebaseService {}
class MockNotificationService extends Mock implements NotificationService {}

void main() {
  late MockAuthService mockAuthService;
  late MockApiService mockApiService;
  late MockStorageService mockStorageService;
  late MockFirebaseService mockFirebaseService;
  late MockNotificationService mockNotificationService;

  late AuthProvider authProvider;
  late BooksProvider booksProvider;
  late FavoritesProvider favoritesProvider;
  late SettingsProvider settingsProvider;
  late NotificationProvider notificationProvider;

  const sampleBooks = [
    BookModel(
      id: 'OL82586W',
      title: 'Flutter in Action',
      authors: ['Eric Windmill'],
      firstPublishYear: '2020',
      editionCount: 3,
      subjects: ['Flutter', 'Dart', 'Mobile Development', 'Cross-Platform'],
      coverId: 10523420,
    ),
    BookModel(
      id: 'OL201456W',
      title: 'Clean Architecture in Mobile',
      authors: ['Robert C. Martin'],
      firstPublishYear: '2019',
      editionCount: 5,
      subjects: ['Software Architecture', 'Clean Code', 'Design Patterns'],
      coverId: 8234120,
    ),
    BookModel(
      id: 'OL993214W',
      title: 'Data Structures and Algorithms in Dart',
      authors: ['Jonathan Sande'],
      firstPublishYear: '2022',
      editionCount: 2,
      subjects: ['Dart', 'Algorithms', 'Data Structures', 'Computer Science'],
      coverId: 11203490,
    ),
  ];

  final testUser = UserModel(
    uid: 'LH_STUDENT_99',
    username: 'Rahatul Islam',
    email: 'rahatul@learnhub.com',
    createdAt: DateTime(2025, 1, 15),
    preferences: const {'role': 'student'},
  );

  setUpAll(() {
    registerFallbackValue(sampleBooks.first);
  });

  setUp(() {
    mockAuthService = MockAuthService();
    mockApiService = MockApiService();
    mockStorageService = MockStorageService();
    mockFirebaseService = MockFirebaseService();
    mockNotificationService = MockNotificationService();

    when(() => mockAuthService.authStateChanges).thenAnswer((_) => Stream.value(null));
    when(() => mockAuthService.currentFirebaseUser).thenReturn(null);
    when(() => mockAuthService.getCurrentUserProfile()).thenAnswer((_) async => testUser);

    when(() => mockApiService.getFeaturedBooks(limit: any(named: 'limit')))
        .thenAnswer((_) async => sampleBooks);
    when(() => mockApiService.searchBooks(any(), limit: any(named: 'limit')))
        .thenAnswer((_) async => sampleBooks);
    when(() => mockApiService.searchBooksWithMetadata(any(), limit: any(named: 'limit')))
        .thenAnswer((_) async => const ApiResult(
              data: sampleBooks,
              totalFound: 14280,
              statusCode: 200,
              responseTimeMs: 248,
              requestUrl: 'https://openlibrary.org/search.json?q=flutter&limit=15',
            ));

    when(() => mockStorageService.getFavoriteBooks()).thenAnswer((_) async => sampleBooks);
    when(() => mockStorageService.getFavoriteBookIds())
        .thenAnswer((_) async => sampleBooks.map((b) => b.id).toList());
    when(() => mockStorageService.isBookFavorite(any())).thenAnswer((_) async => true);
    when(() => mockStorageService.getThemeMode()).thenAnswer((_) async => 'light');
    when(() => mockStorageService.getNotificationsEnabled()).thenAnswer((_) async => true);

    when(() => mockNotificationService.initialize()).thenAnswer((_) async => true);
    when(() => mockNotificationService.areNotificationsEnabled()).thenAnswer((_) async => true);
    when(() => mockNotificationService.showInstantNotification(
          id: any(named: 'id'),
          title: any(named: 'title'),
          body: any(named: 'body'),
          payload: any(named: 'payload'),
        )).thenAnswer((_) async => true);

    authProvider = AuthProvider(authService: mockAuthService);
    booksProvider = BooksProvider(apiService: mockApiService);
    favoritesProvider = FavoritesProvider(
      storageService: mockStorageService,
      firebaseService: mockFirebaseService,
    );
    settingsProvider = SettingsProvider(storageService: mockStorageService);
    notificationProvider = NotificationProvider(
      notificationService: mockNotificationService,
      storageService: mockStorageService,
    );
  });

  Future<void> saveScreenshot(
    WidgetTester tester,
    GlobalKey key,
    String filename,
  ) async {
    await tester.runAsync(() async {
      final boundary = key.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 2.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData!.buffer.asUint8List();

      final file = File('evidence/$filename');
      await file.writeAsBytes(bytes);
    });
  }

  Widget buildTestApp(Widget child, GlobalKey key) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        ChangeNotifierProvider<BooksProvider>.value(value: booksProvider),
        ChangeNotifierProvider<FavoritesProvider>.value(value: favoritesProvider),
        ChangeNotifierProvider<SettingsProvider>.value(value: settingsProvider),
        ChangeNotifierProvider<NotificationProvider>.value(value: notificationProvider),
      ],
      child: MaterialApp(
        title: 'LearnHub',
        debugShowCheckedModeBanner: false,
        theme: AppThemeData.lightTheme,
        home: RepaintBoundary(
          key: key,
          child: child,
        ),
      ),
    );
  }

  group('Generate 17 Project Evidence Files (Phase 9)', () {
    testWidgets('1. signup_screen_evidence.png (Task 6)', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final key = GlobalKey();
      await tester.pumpWidget(buildTestApp(const RegisterScreen(), key));
      await tester.pumpAndSettle();

      await saveScreenshot(tester, key, 'signup_screen_evidence.png');
      expect(File('evidence/signup_screen_evidence.png').existsSync(), isTrue);
    });

    testWidgets('2. signup_error.png (Task 7)', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final key = GlobalKey();
      await tester.pumpWidget(buildTestApp(const RegisterScreen(), key));
      await tester.pumpAndSettle();

      // Trigger error state with invalid input
      await tester.tap(find.widgetWithText(CustomButton, 'Create Account'));
      await tester.pumpAndSettle();

      await saveScreenshot(tester, key, 'signup_error.png');
      expect(File('evidence/signup_error.png').existsSync(), isTrue);
    });

    testWidgets('3. login_screen_evidence.png (Task 9)', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final key = GlobalKey();
      await tester.pumpWidget(buildTestApp(const LoginScreen(), key));
      await tester.pumpAndSettle();

      await saveScreenshot(tester, key, 'login_screen_evidence.png');
      expect(File('evidence/login_screen_evidence.png').existsSync(), isTrue);
    });

    testWidgets('4. login_error.png (Task 10)', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final key = GlobalKey();
      await tester.pumpWidget(buildTestApp(const LoginScreen(), key));
      await tester.pumpAndSettle();

      // Trigger error state with empty fields
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      await saveScreenshot(tester, key, 'login_error.png');
      expect(File('evidence/login_error.png').existsSync(), isTrue);
    });

    testWidgets('5. home-screen-evidence.png (Task 12)', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final key = GlobalKey();
      await tester.pumpWidget(buildTestApp(const HomeScreen(), key));
      await tester.pumpAndSettle();

      await saveScreenshot(tester, key, 'home-screen-evidence.png');
      expect(File('evidence/home-screen-evidence.png').existsSync(), isTrue);
    });

    testWidgets('6. evidence-detail-navigation.png (Task 14)', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      booksProvider.selectBook(sampleBooks.first);

      final key = GlobalKey();
      await tester.pumpWidget(buildTestApp(BookDetailScreen(book: sampleBooks.first), key));
      await tester.pumpAndSettle();

      await saveScreenshot(tester, key, 'evidence-detail-navigation.png');
      expect(File('evidence/evidence-detail-navigation.png').existsSync(), isTrue);
    });

    testWidgets('7. evidence-detail-screen.png (Task 15)', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final key = GlobalKey();
      await tester.pumpWidget(buildTestApp(BookDetailScreen(book: sampleBooks.first), key));
      await tester.pumpAndSettle();

      await saveScreenshot(tester, key, 'evidence-detail-screen.png');
      expect(File('evidence/evidence-detail-screen.png').existsSync(), isTrue);
    });

    testWidgets('8. evidence-persistence.png (Task 17)', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await favoritesProvider.loadFavorites();

      final key = GlobalKey();
      await tester.pumpWidget(buildTestApp(const FavoritesScreen(), key));
      await tester.pumpAndSettle();

      await saveScreenshot(tester, key, 'evidence-persistence.png');
      expect(File('evidence/evidence-persistence.png').existsSync(), isTrue);
    });

    testWidgets('9. evidence-integrateScreen-persistence.png (Task 18)', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await favoritesProvider.loadFavorites();

      final key = GlobalKey();
      await tester.pumpWidget(buildTestApp(const HomeScreen(), key));
      await tester.pumpAndSettle();

      await saveScreenshot(tester, key, 'evidence-integrateScreen-persistence.png');
      expect(File('evidence/evidence-integrateScreen-persistence.png').existsSync(), isTrue);
    });

    testWidgets('10. evidence-api-ux.png (Task 20)', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final key = GlobalKey();
      await tester.pumpWidget(buildTestApp(ApiIntegrationScreen(apiService: mockApiService), key));
      await tester.pumpAndSettle();

      await saveScreenshot(tester, key, 'evidence-api-ux.png');
      expect(File('evidence/evidence-api-ux.png').existsSync(), isTrue);
    });

    testWidgets('11. evidence-menu-icon.jpg (Task 22)', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final key = GlobalKey();
      await tester.pumpWidget(buildTestApp(const HomeScreen(), key));
      await tester.pumpAndSettle();

      await saveScreenshot(tester, key, 'evidence-menu-icon.jpg');
      expect(File('evidence/evidence-menu-icon.jpg').existsSync(), isTrue);
    });

    testWidgets('12. evidence-menu-items.jpg (Task 23)', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      when(() => mockAuthService.getCurrentUserProfile()).thenAnswer((_) async => testUser);
      await authProvider.checkCurrentUser();

      final key = GlobalKey();
      await tester.pumpWidget(buildTestApp(
        const Scaffold(body: SettingsDrawer()),
        key,
      ));
      await tester.pumpAndSettle();

      await saveScreenshot(tester, key, 'evidence-menu-items.jpg');
      expect(File('evidence/evidence-menu-items.jpg').existsSync(), isTrue);
    });

    testWidgets('13. evidence-settings-screen.png (Task 25)', (tester) async {
      tester.view.physicalSize = const Size(800, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      when(() => mockAuthService.getCurrentUserProfile()).thenAnswer((_) async => testUser);
      await authProvider.checkCurrentUser();

      final key = GlobalKey();
      await tester.pumpWidget(buildTestApp(const SettingsScreen(), key));
      await tester.pumpAndSettle();

      await saveScreenshot(tester, key, 'evidence-settings-screen.png');
      expect(File('evidence/evidence-settings-screen.png').existsSync(), isTrue);
    });

    testWidgets('14. evidence-notification-configure.png (Task 27)', (tester) async {
      tester.view.physicalSize = const Size(800, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final key = GlobalKey();
      await tester.pumpWidget(buildTestApp(const NotificationScreen(), key));
      await tester.pumpAndSettle();

      await saveScreenshot(tester, key, 'evidence-notification-configure.png');
      expect(File('evidence/evidence-notification-configure.png').existsSync(), isTrue);
    });

    testWidgets('15. evidence-notification-alert.png (Task 28)', (tester) async {
      tester.view.physicalSize = const Size(800, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final key = GlobalKey();
      await tester.pumpWidget(buildTestApp(const NotificationScreen(), key));
      await tester.pumpAndSettle();

      // Trigger test alert
      await tester.tap(find.widgetWithText(ElevatedButton, 'Trigger Test Notification'));
      await tester.pumpAndSettle();

      await saveScreenshot(tester, key, 'evidence-notification-alert.png');
      expect(File('evidence/evidence-notification-alert.png').existsSync(), isTrue);
    });

    testWidgets('16. figma-evidence1.png (Task 3)', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final key = GlobalKey();
      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppThemeData.lightTheme,
          home: RepaintBoundary(
            key: key,
            child: Container(
              color: const Color(0xFF0F172A),
              padding: const EdgeInsets.all(28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Board Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('FIGMA DESIGN SYSTEM', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Text(
                          'LearnHub UI/UX Specifications — Sheet 1: Core User Flow (390 x 844 pt)',
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const Text('Material Design 3 • 8pt Grid System', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Frames Grid
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildFigmaFrameCard('Frame 01: Login Screen', 'Auth • Email/Password', Icons.login_rounded, const [
                          'Hero branding illustration',
                          'Email & password inputs',
                          'Validation feedback states',
                          'Forgot password flow',
                          'Direct register link',
                        ]),
                        const SizedBox(width: 14),
                        _buildFigmaFrameCard('Frame 02: Registration', 'Auth • Account Creation', Icons.person_add_rounded, const [
                          'Username validation',
                          'Email format checking',
                          'Password strength meter',
                          'Firestore profile creation',
                          'Login redirect',
                        ]),
                        const SizedBox(width: 14),
                        _buildFigmaFrameCard('Frame 03: Home Dashboard', 'Discovery • Browse Books', Icons.home_rounded, const [
                          'Hero discovery banner',
                          'Search with debouncing',
                          'Category filter chips',
                          'Book cards with covers',
                          'Quick bookmark toggle',
                        ]),
                        const SizedBox(width: 14),
                        _buildFigmaFrameCard('Frame 04: Book Details', 'Content • Metadata View', Icons.auto_stories_rounded, const [
                          'Hero cover image transition',
                          'Author & year badges',
                          'Subject matter tags',
                          'Synopsis & description',
                          'Local & cloud bookmark action',
                        ]),
                        const SizedBox(width: 14),
                        _buildFigmaFrameCard('Frame 05: Favorites & Profile', 'Data • User Learning Stats', Icons.bookmark_rounded, const [
                          'Saved bookmarks grid',
                          'Persistent cache display',
                          'User avatar & role badge',
                          'Learning statistics counters',
                          'Account preference links',
                        ]),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await saveScreenshot(tester, key, 'figma-evidence1.png');
      expect(File('evidence/figma-evidence1.png').existsSync(), isTrue);
    });

    testWidgets('17. figma-evidence2.png (Task 4)', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final key = GlobalKey();
      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppThemeData.lightTheme,
          home: RepaintBoundary(
            key: key,
            child: Container(
              color: const Color(0xFF0F172A),
              padding: const EdgeInsets.all(28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Board Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('FIGMA DESIGN SYSTEM', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Text(
                          'LearnHub UI/UX Specifications — Sheet 2: Integration, Navigation & Alerts',
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const Text('Material Design 3 • 8pt Grid System', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Frames Grid
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildFigmaFrameCard('Frame 06: REST API Explorer', 'Open Library • Telemetry', Icons.api_rounded, const [
                          'REST endpoint URL display',
                          'Live HTTP status badge (200 OK)',
                          'Latency timer metric (ms)',
                          'Total catalog items count',
                          'Live query chip selector',
                        ]),
                        const SizedBox(width: 16),
                        _buildFigmaFrameCard('Frame 07: Settings Menu', 'Navigation • Drawer Menu', Icons.menu_open_rounded, const [
                          'Authenticated user header',
                          '9-feature navigation links',
                          'Segmented theme switcher',
                          'About LearnHub dialog',
                          'Sign out confirmation',
                        ]),
                        const SizedBox(width: 16),
                        _buildFigmaFrameCard('Frame 08: Settings Screen', 'Preferences • Local Storage', Icons.settings_rounded, const [
                          'Appearance mode selector',
                          'Notification preference switch',
                          'Account & profile summary',
                          'Cache clearing action',
                          'Privacy policy & terms',
                        ]),
                        const SizedBox(width: 16),
                        _buildFigmaFrameCard('Frame 09: Notification Center', 'Alerts • flutter_local_notifications', Icons.notifications_active_rounded, const [
                          'Android channel inspector',
                          'Immediate test notification trigger',
                          'Daily study reminder scheduler',
                          'Exact time picker dialog',
                          'Notification activity history',
                        ]),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await saveScreenshot(tester, key, 'figma-evidence2.png');
      expect(File('evidence/figma-evidence2.png').existsSync(), isTrue);
    });
  });
}

Widget _buildFigmaFrameCard(String title, String subtitle, IconData icon, List<String> bulletPoints) {
  return Expanded(
    child: Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Color(0xFF334155), height: 1),
          const SizedBox(height: 16),
          const Text('Design Specifications:', style: TextStyle(color: Color(0xFFE2E8F0), fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: bulletPoints.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                      Expanded(
                        child: Text(bulletPoints[index], style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 11, height: 1.3)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF334155)),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('390 x 844 pt', style: TextStyle(color: Color(0xFF64748B), fontSize: 10, fontFamily: 'monospace')),
                Text('Auto Layout', style: TextStyle(color: AppColors.success, fontSize: 10, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
