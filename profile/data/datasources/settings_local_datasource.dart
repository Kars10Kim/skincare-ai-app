import 'dart:convert';

import '../../../../core/error/exceptions.dart';
import '../../../../core/storage/hive_manager.dart';
import '../models/app_settings_model.dart';
import '../models/user_preferences_model.dart';

/// Settings local data source interface
abstract class SettingsLocalDataSource {
  /// Get user preferences from local storage
  Future<UserPreferencesModel> getUserPreferences(String userId);
  
  /// Save user preferences to local storage
  Future<void> saveUserPreferences(UserPreferencesModel preferences);
  
  /// Reset user preferences to defaults
  Future<UserPreferencesModel> resetUserPreferences(String userId);
  
  /// Get app settings from local storage
  Future<AppSettingsModel> getAppSettings();
  
  /// Save app settings to local storage
  Future<void> saveAppSettings(AppSettingsModel settings);
  
  /// Reset app settings to defaults
  Future<AppSettingsModel> resetAppSettings();
  
  /// Toggle theme mode
  Future<UserPreferencesModel> toggleThemeMode(
    String userId,
    bool useDarkTheme,
    bool useSystemTheme,
  );
  
  /// Toggle biometric authentication
  Future<UserPreferencesModel> toggleBiometrics(
    String userId,
    bool useBiometrics,
  );
  
  /// Toggle notifications
  Future<UserPreferencesModel> toggleNotifications(
    String userId,
    bool enableNotifications,
  );
  
  /// Export user preferences to JSON string
  Future<String> exportUserPreferences(String userId);
  
  /// Import user preferences from JSON string
  Future<void> importUserPreferences(String userId, String jsonData);
  
  /// Export app settings to JSON string
  Future<String> exportAppSettings();
  
  /// Import app settings from JSON string
  Future<void> importAppSettings(String jsonData);
  
  /// Clear all settings data
  Future<void> clearAllData();
}

/// Settings local data source implementation using Hive
class SettingsLocalDataSourceImpl implements SettingsLocalDataSource {
  /// Hive manager
  final HiveManager hiveManager;
  
  /// Create settings local data source
  SettingsLocalDataSourceImpl({
    required this.hiveManager,
  });
  
  @override
  Future<UserPreferencesModel> getUserPreferences(String userId) async {
    try {
      final preferencesBox = hiveManager.userPreferencesBox;
      final preferences = preferencesBox.get(userId);
      
      if (preferences == null) {
        // If no preferences found, create default ones
        final defaultPreferences = UserPreferencesModel(
          userId: userId,
          lastUpdated: DateTime.now(),
        );
        
        // Save default preferences for future use
        await saveUserPreferences(defaultPreferences);
        return defaultPreferences;
      }
      
      return preferences as UserPreferencesModel;
    } catch (e) {
      throw CacheException(message: e.toString());
    }
  }
  
  @override
  Future<void> saveUserPreferences(UserPreferencesModel preferences) async {
    try {
      final preferencesBox = hiveManager.userPreferencesBox;
      await preferencesBox.put(preferences.userId, preferences);
    } catch (e) {
      throw CacheException(message: e.toString());
    }
  }
  
  @override
  Future<UserPreferencesModel> resetUserPreferences(String userId) async {
    try {
      final preferencesBox = hiveManager.userPreferencesBox;
      final defaultPreferences = UserPreferencesModel(
        userId: userId,
        lastUpdated: DateTime.now(),
      );
      
      await preferencesBox.put(userId, defaultPreferences);
      return defaultPreferences;
    } catch (e) {
      throw CacheException(message: e.toString());
    }
  }
  
  @override
  Future<AppSettingsModel> getAppSettings() async {
    try {
      final settingsBox = hiveManager.appSettingsBox;
      final settings = settingsBox.get('app_settings');
      
      if (settings == null) {
        // If no settings found, create default ones
        final defaultSettings = AppSettingsModel(
          lastUpdated: DateTime.now(),
        );
        
        // Save default settings for future use
        await saveAppSettings(defaultSettings);
        return defaultSettings;
      }
      
      return settings as AppSettingsModel;
    } catch (e) {
      throw CacheException(message: e.toString());
    }
  }
  
  @override
  Future<void> saveAppSettings(AppSettingsModel settings) async {
    try {
      final settingsBox = hiveManager.appSettingsBox;
      await settingsBox.put('app_settings', settings);
    } catch (e) {
      throw CacheException(message: e.toString());
    }
  }
  
  @override
  Future<AppSettingsModel> resetAppSettings() async {
    try {
      final settingsBox = hiveManager.appSettingsBox;
      final defaultSettings = AppSettingsModel(
        lastUpdated: DateTime.now(),
      );
      
      await settingsBox.put('app_settings', defaultSettings);
      return defaultSettings;
    } catch (e) {
      throw CacheException(message: e.toString());
    }
  }
  
  @override
  Future<UserPreferencesModel> toggleThemeMode(
    String userId,
    bool useDarkTheme,
    bool useSystemTheme,
  ) async {
    try {
      final preferences = await getUserPreferences(userId);
      
      final updatedPreferences = UserPreferencesModel(
        userId: userId,
        useSystemTheme: useSystemTheme,
        useDarkTheme: useDarkTheme,
        useBiometrics: preferences.useBiometrics,
        enableNotifications: preferences.enableNotifications,
        enableReminders: preferences.enableReminders,
        enableProductUpdates: preferences.enableProductUpdates,
        notificationType: preferences.notificationType,
        languagePreference: preferences.languagePreference,
        autoSaveScanResults: preferences.autoSaveScanResults,
        syncOnWifiOnly: preferences.syncOnWifiOnly,
        autoDeleteScansAfterDays: preferences.autoDeleteScansAfterDays,
        showScientificReferences: preferences.showScientificReferences,
        lastUpdated: DateTime.now(),
      );
      
      await saveUserPreferences(updatedPreferences);
      return updatedPreferences;
    } catch (e) {
      throw CacheException(message: e.toString());
    }
  }
  
  @override
  Future<UserPreferencesModel> toggleBiometrics(
    String userId,
    bool useBiometrics,
  ) async {
    try {
      final preferences = await getUserPreferences(userId);
      
      final updatedPreferences = UserPreferencesModel(
        userId: userId,
        useSystemTheme: preferences.useSystemTheme,
        useDarkTheme: preferences.useDarkTheme,
        useBiometrics: useBiometrics,
        enableNotifications: preferences.enableNotifications,
        enableReminders: preferences.enableReminders,
        enableProductUpdates: preferences.enableProductUpdates,
        notificationType: preferences.notificationType,
        languagePreference: preferences.languagePreference,
        autoSaveScanResults: preferences.autoSaveScanResults,
        syncOnWifiOnly: preferences.syncOnWifiOnly,
        autoDeleteScansAfterDays: preferences.autoDeleteScansAfterDays,
        showScientificReferences: preferences.showScientificReferences,
        lastUpdated: DateTime.now(),
      );
      
      await saveUserPreferences(updatedPreferences);
      return updatedPreferences;
    } catch (e) {
      throw CacheException(message: e.toString());
    }
  }
  
  @override
  Future<UserPreferencesModel> toggleNotifications(
    String userId,
    bool enableNotifications,
  ) async {
    try {
      final preferences = await getUserPreferences(userId);
      
      final updatedPreferences = UserPreferencesModel(
        userId: userId,
        useSystemTheme: preferences.useSystemTheme,
        useDarkTheme: preferences.useDarkTheme,
        useBiometrics: preferences.useBiometrics,
        enableNotifications: enableNotifications,
        enableReminders: preferences.enableReminders,
        enableProductUpdates: preferences.enableProductUpdates,
        notificationType: enableNotifications 
            ? preferences.notificationType 
            : NotificationType.none,
        languagePreference: preferences.languagePreference,
        autoSaveScanResults: preferences.autoSaveScanResults,
        syncOnWifiOnly: preferences.syncOnWifiOnly,
        autoDeleteScansAfterDays: preferences.autoDeleteScansAfterDays,
        showScientificReferences: preferences.showScientificReferences,
        lastUpdated: DateTime.now(),
      );
      
      await saveUserPreferences(updatedPreferences);
      return updatedPreferences;
    } catch (e) {
      throw CacheException(message: e.toString());
    }
  }
  
  @override
  Future<String> exportUserPreferences(String userId) async {
    try {
      final preferences = await getUserPreferences(userId);
      return jsonEncode(preferences.toJson());
    } catch (e) {
      throw CacheException(message: e.toString());
    }
  }
  
  @override
  Future<void> importUserPreferences(String userId, String jsonData) async {
    try {
      final jsonMap = jsonDecode(jsonData) as Map<String, dynamic>;
      final preferences = UserPreferencesModel.fromJson(jsonMap);
      
      // Make sure the imported preferences have the correct user ID
      final updatedPreferences = UserPreferencesModel(
        userId: userId,
        useSystemTheme: preferences.useSystemTheme,
        useDarkTheme: preferences.useDarkTheme,
        useBiometrics: preferences.useBiometrics,
        enableNotifications: preferences.enableNotifications,
        enableReminders: preferences.enableReminders,
        enableProductUpdates: preferences.enableProductUpdates,
        notificationType: preferences.notificationType,
        languagePreference: preferences.languagePreference,
        autoSaveScanResults: preferences.autoSaveScanResults,
        syncOnWifiOnly: preferences.syncOnWifiOnly,
        autoDeleteScansAfterDays: preferences.autoDeleteScansAfterDays,
        showScientificReferences: preferences.showScientificReferences,
        lastUpdated: DateTime.now(),
      );
      
      await saveUserPreferences(updatedPreferences);
    } catch (e) {
      throw ValidationException(
        message: 'Invalid preferences data format: ${e.toString()}',
        field: 'jsonData',
      );
    }
  }
  
  @override
  Future<String> exportAppSettings() async {
    try {
      final settings = await getAppSettings();
      return jsonEncode(settings.toJson());
    } catch (e) {
      throw CacheException(message: e.toString());
    }
  }
  
  @override
  Future<void> importAppSettings(String jsonData) async {
    try {
      final jsonMap = jsonDecode(jsonData) as Map<String, dynamic>;
      final settings = AppSettingsModel.fromJson(jsonMap);
      
      // Make sure we have the current timestamp
      final updatedSettings = AppSettingsModel(
        themeMode: settings.themeMode,
        fontScale: settings.fontScale,
        brightnessOverride: settings.brightnessOverride,
        enableAnalytics: settings.enableAnalytics,
        enableCrashReporting: settings.enableCrashReporting,
        preferredScanMode: settings.preferredScanMode,
        conflictDisplayMode: settings.conflictDisplayMode,
        maxIngredientsInDetail: settings.maxIngredientsInDetail,
        enableOfflineMode: settings.enableOfflineMode,
        lastUpdated: DateTime.now(),
      );
      
      await saveAppSettings(updatedSettings);
    } catch (e) {
      throw ValidationException(
        message: 'Invalid settings data format: ${e.toString()}',
        field: 'jsonData',
      );
    }
  }
  
  @override
  Future<void> clearAllData() async {
    try {
      final preferencesBox = hiveManager.userPreferencesBox;
      final settingsBox = hiveManager.appSettingsBox;
      
      await preferencesBox.clear();
      await settingsBox.clear();
    } catch (e) {
      throw CacheException(message: e.toString());
    }
  }
}