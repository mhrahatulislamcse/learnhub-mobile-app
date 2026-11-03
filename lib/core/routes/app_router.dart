import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/profile_page.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/books/screens/api_integration_screen.dart';
import '../../features/details/screens/book_detail_screen.dart';
import '../../features/notifications/screens/notification_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/favorites/screens/favorites_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../widgets/app_error_widget.dart';
import 'app_routes.dart';

/// Central application navigation router using GoRouter
class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: false,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        name: AppRoutes.splashName,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: AppRoutes.home,
        name: AppRoutes.homeName,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: AppRoutes.loginName,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        name: AppRoutes.registerName,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        name: AppRoutes.forgotPasswordName,
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        name: AppRoutes.profileName,
        builder: (context, state) => const ProfilePage(),
      ),
      GoRoute(
        path: AppRoutes.bookDetails,
        name: AppRoutes.bookDetailsName,
        builder: (context, state) => const BookDetailScreen(),
      ),
      GoRoute(
        path: AppRoutes.favorites,
        name: AppRoutes.favoritesName,
        builder: (context, state) => const FavoritesScreen(),
      ),
      GoRoute(
        path: AppRoutes.apiIntegration,
        name: AppRoutes.apiIntegrationName,
        builder: (context, state) => const ApiIntegrationScreen(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        name: AppRoutes.settingsName,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.notifications,
        name: AppRoutes.notificationsName,
        builder: (context, state) => const NotificationScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: AppErrorWidget(
        message: 'No route found for ${state.uri}',
        onRetry: () => context.goNamed(AppRoutes.homeName),
      ),
    ),
  );
}
