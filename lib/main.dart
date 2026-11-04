import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_constants.dart';
import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/app_logger.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/books/providers/books_provider.dart';
import 'features/favorites/providers/favorites_provider.dart';
import 'features/notifications/providers/notification_provider.dart';
import 'features/settings/providers/settings_provider.dart';
import 'injection_container.dart' as di;
import 'services/firebase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase Core services with explicit lifecycle verification
  final firebaseSuccess = await FirebaseService.initialize();
  if (!firebaseSuccess) {
    AppLogger.error(
      'Startup Warning: Firebase Core could not establish connection. '
      'Error: ${FirebaseService.lastError}. '
      'Check google-services.json or supply --dart-define=FIREBASE_API_KEY=... '
      'Running in offline fallback mode.',
    );
  } else {
    AppLogger.info('Startup Success: Firebase connected successfully.');
  }

  // Initialize Clean Architecture dependency injection
  await di.initDependencyInjection();

  runApp(const LearnHubMain());
}

/// ============================================================================
/// LearnHub Hybrid State-Management Strategy (ADR-001)
/// ============================================================================
/// 1. BLoC (flutter_bloc) — Core Enterprise Domain & Authentication:
///    - Manages [AuthBloc], [AuthEvent], and [AuthState] stream transitions.
///    - Enforces Clean Architecture boundaries (Domain / Data / Presentation).
///    - Handles authentication flows, use cases, credentials, and error states.
///
/// 2. Provider (provider / ChangeNotifier) — Feature & Reactive UI State:
///    - [AuthProvider]: Reactive UI facade exposing session data to widgets.
///    - [BooksProvider]: Catalog management, search queries, and Open Library results.
///    - [FavoritesProvider]: Local persistence (SharedPreferences) & Firestore sync.
///    - [SettingsProvider]: Theme mode (System/Light/Dark) & notification switches.
///    - [NotificationProvider]: Daily study scheduling, time picker & instant alerts.
/// ============================================================================
class LearnHubMain extends StatelessWidget {
  const LearnHubMain({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(),
        ),
        ChangeNotifierProvider<BooksProvider>(
          create: (_) => BooksProvider(),
        ),
        ChangeNotifierProvider<FavoritesProvider>(
          create: (_) => FavoritesProvider(),
        ),
        ChangeNotifierProvider<SettingsProvider>(
          create: (_) => SettingsProvider(),
        ),
        ChangeNotifierProvider<NotificationProvider>(
          create: (_) => NotificationProvider(),
        ),
        BlocProvider<AuthBloc>(
          create: (_) => di.sl<AuthBloc>(),
        ),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, _) {
          return MaterialApp.router(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settingsProvider.themeMode,
            routerConfig: AppRouter.router,
          );
        },
      ),
    );
  }
}
