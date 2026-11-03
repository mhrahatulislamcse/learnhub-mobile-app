import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/widgets/app_error_widget.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/register_screen.dart';
import '../features/details/screens/book_detail_screen.dart';
import '../features/favorites/screens/favorites_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../features/splash/presentation/pages/splash_page.dart';

/// Central application routes definition using GoRouter
class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String bookDetails = '/book-details';
  static const String favorites = '/favorites';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String notifications = '/notifications';

  static final GoRouter router = GoRouter(
    initialLocation: splash,
    debugLogDiagnostics: false,
    routes: [
      GoRoute(
        path: splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: bookDetails,
        builder: (context, state) => const BookDetailScreen(),
      ),
      GoRoute(
        path: favorites,
        builder: (context, state) => const FavoritesScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: AppErrorWidget(
        message: 'No route found for ${state.uri}',
        onRetry: () => context.go(home),
      ),
    ),
  );
}
