/// Route constants used by GoRouter across the application
class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String splashName = 'splash';

  static const String home = '/home';
  static const String homeName = 'home';

  static const String login = '/login';
  static const String loginName = 'login';

  static const String register = '/register';
  static const String registerName = 'register';

  static const String forgotPassword = '/forgot-password';
  static const String forgotPasswordName = 'forgot-password';

  static const String profile = '/profile';
  static const String profileName = 'profile';

  static const String courseDetails = '/course/:id';
  static const String courseDetailsName = 'course-details';
}
