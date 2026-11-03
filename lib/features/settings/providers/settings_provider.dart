import 'package:flutter/material.dart';
import '../../../core/utils/app_logger.dart';
import '../../../services/storage_service.dart';
import '../../favorites/providers/favorites_provider.dart';

/// Provider managing application settings, theme preferences, and notifications configuration
class SettingsProvider extends ChangeNotifier {
  final StorageService _storageService;

  ThemeMode _themeMode = ThemeMode.system;
  bool _notificationsEnabled = true;
  bool _offlineSyncEnabled = true;
  int _studyReminderHour = 20; // 8:00 PM
  int _studyReminderMinute = 0;
  bool _isInitialized = false;

  SettingsProvider({StorageService? storageService})
      : _storageService = storageService ?? StorageService() {
    loadSettings();
  }

  ThemeMode get themeMode => _themeMode;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get offlineSyncEnabled => _offlineSyncEnabled;
  int get studyReminderHour => _studyReminderHour;
  int get studyReminderMinute => _studyReminderMinute;
  bool get isInitialized => _isInitialized;

  /// Loads persisted settings from SharedPreferences
  Future<void> loadSettings() async {
    try {
      final savedTheme = await _storageService.getThemeMode();
      switch (savedTheme.toLowerCase()) {
        case 'light':
          _themeMode = ThemeMode.light;
          break;
        case 'dark':
          _themeMode = ThemeMode.dark;
          break;
        case 'system':
        default:
          _themeMode = ThemeMode.system;
          break;
      }

      _notificationsEnabled = await _storageService.getNotificationsEnabled();
      _isInitialized = true;
      notifyListeners();
      AppLogger.info('SettingsProvider: Settings loaded (Theme: $_themeMode, Notifications: $_notificationsEnabled)');
    } catch (e) {
      AppLogger.error('SettingsProvider: Failed to load settings: $e');
      _isInitialized = true;
      notifyListeners();
    }
  }

  /// Sets the application theme mode and persists it locally
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();

    final modeString = mode == ThemeMode.light
        ? 'light'
        : mode == ThemeMode.dark
            ? 'dark'
            : 'system';

    await _storageService.saveThemeMode(modeString);
    AppLogger.info('SettingsProvider: Theme updated to $modeString');
  }

  /// Sets whether local notifications are enabled
  Future<void> setNotificationsEnabled(bool enabled) async {
    if (_notificationsEnabled == enabled) return;
    _notificationsEnabled = enabled;
    notifyListeners();

    await _storageService.saveNotificationsEnabled(enabled);
    AppLogger.info('SettingsProvider: Notifications enabled set to $enabled');
  }

  /// Updates study reminder schedule time
  void setStudyReminderTime(int hour, int minute) {
    _studyReminderHour = hour;
    _studyReminderMinute = minute;
    notifyListeners();
  }

  /// Toggles offline synchronization preference
  void setOfflineSyncEnabled(bool enabled) {
    _offlineSyncEnabled = enabled;
    notifyListeners();
  }

  /// Clears local favorites cache and refreshes FavoritesProvider
  Future<bool> clearFavoritesCache(FavoritesProvider? favoritesProvider) async {
    try {
      final success = await _storageService.clearFavorites();
      if (favoritesProvider != null) {
        await favoritesProvider.loadFavorites();
      }
      notifyListeners();
      AppLogger.info('SettingsProvider: Favorites cache cleared successfully');
      return success;
    } catch (e) {
      AppLogger.error('SettingsProvider: Failed to clear favorites cache: $e');
      return false;
    }
  }
}

