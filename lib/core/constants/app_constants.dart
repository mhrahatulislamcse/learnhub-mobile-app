/// Core application constants including storage keys, collections, and limits.
class AppConstants {
  AppConstants._();

  // App Metadata
  static const String appName = 'LearnHub';
  static const String appTagline = 'Empower Your Learning Journey';
  static const String appVersion = '1.0.0';

  // Firestore Collection Names
  static const String usersCollection = 'users';
  static const String coursesCollection = 'courses';
  static const String lessonsCollection = 'lessons';
  static const String enrollmentsCollection = 'enrollments';
  static const String categoriesCollection = 'categories';
  static const String reviewsCollection = 'reviews';

  // SharedPreferences Keys
  static const String themeModeKey = 'pref_theme_mode';
  static const String userTokenKey = 'pref_user_token';
  static const String onBoardingCompletedKey = 'pref_onboarding_completed';

  // Network & Pagination
  static const int defaultPageSize = 20;
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}

