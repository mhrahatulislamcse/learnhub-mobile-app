import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learnhub/features/favorites/providers/favorites_provider.dart';
import 'package:learnhub/features/settings/providers/settings_provider.dart';
import 'package:learnhub/services/storage_service.dart';
import 'package:mocktail/mocktail.dart';

class MockStorageService extends Mock implements StorageService {}
class MockFavoritesProvider extends Mock implements FavoritesProvider {}

void main() {
  late MockStorageService mockStorageService;
  late MockFavoritesProvider mockFavoritesProvider;

  setUp(() {
    mockStorageService = MockStorageService();
    mockFavoritesProvider = MockFavoritesProvider();

    when(() => mockStorageService.getThemeMode())
        .thenAnswer((_) async => 'dark');
    when(() => mockStorageService.getNotificationsEnabled())
        .thenAnswer((_) async => true);
    when(() => mockStorageService.saveThemeMode(any()))
        .thenAnswer((_) async => true);
    when(() => mockStorageService.saveNotificationsEnabled(any()))
        .thenAnswer((_) async => true);
    when(() => mockStorageService.clearFavorites())
        .thenAnswer((_) async => true);
    when(() => mockFavoritesProvider.loadFavorites(userId: any(named: 'userId')))
        .thenAnswer((_) async {});
  });

  group('SettingsProvider Tests', () {
    test('loads saved preferences on initialization', () async {
      final provider = SettingsProvider(storageService: mockStorageService);
      await provider.loadSettings();

      expect(provider.themeMode, equals(ThemeMode.dark));
      expect(provider.notificationsEnabled, isTrue);
      expect(provider.isInitialized, isTrue);
      verify(() => mockStorageService.getThemeMode()).called(greaterThanOrEqualTo(1));
    });

    test('setThemeMode updates theme and persists preference', () async {
      final provider = SettingsProvider(storageService: mockStorageService);
      await provider.loadSettings();

      await provider.setThemeMode(ThemeMode.light);
      expect(provider.themeMode, equals(ThemeMode.light));
      verify(() => mockStorageService.saveThemeMode('light')).called(1);

      await provider.setThemeMode(ThemeMode.system);
      expect(provider.themeMode, equals(ThemeMode.system));
      verify(() => mockStorageService.saveThemeMode('system')).called(1);
    });

    test('setNotificationsEnabled persists preference', () async {
      final provider = SettingsProvider(storageService: mockStorageService);
      await provider.loadSettings();

      await provider.setNotificationsEnabled(false);
      expect(provider.notificationsEnabled, isFalse);
      verify(() => mockStorageService.saveNotificationsEnabled(false)).called(1);
    });

    test('clearFavoritesCache wipes local storage and reloads favorites provider', () async {
      final provider = SettingsProvider(storageService: mockStorageService);
      final success = await provider.clearFavoritesCache(mockFavoritesProvider);

      expect(success, isTrue);
      verify(() => mockStorageService.clearFavorites()).called(1);
      verify(() => mockFavoritesProvider.loadFavorites()).called(1);
    });
  });
}
