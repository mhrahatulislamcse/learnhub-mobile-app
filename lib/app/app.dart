import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_constants.dart';
import '../features/auth/providers/auth_provider.dart';
import '../features/books/providers/books_provider.dart';
import '../features/favorites/providers/favorites_provider.dart';
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
      ],
      child: MaterialApp.router(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppThemeData.lightTheme,
        darkTheme: AppThemeData.darkTheme,
        themeMode: ThemeMode.system,
        routerConfig: AppRoutes.router,
      ),
    );
  }
}
