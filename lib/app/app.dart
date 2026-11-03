import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_constants.dart';
import '../features/auth/providers/auth_provider.dart';
import '../features/books/providers/books_provider.dart';
import '../features/favorites/providers/favorites_provider.dart';
import '../features/notifications/providers/notification_provider.dart';
import '../features/settings/providers/settings_provider.dart';
import 'routes.dart';
import 'theme.dart';

/// Root application widget initializing multi-provider state and GoRouter
class LearnHubAppRoot extends StatelessWidget {
  const LearnHubAppRoot({super.key});

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
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, _) {
          return MaterialApp.router(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: AppThemeData.lightTheme,
            darkTheme: AppThemeData.darkTheme,
            themeMode: settingsProvider.themeMode,
            routerConfig: AppRoutes.router,
          );
        },
      ),
    );
  }
}
