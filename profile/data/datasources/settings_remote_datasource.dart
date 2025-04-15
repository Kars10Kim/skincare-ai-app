import 'dart:convert';
import 'dart:io';

import '../../../../core/error/exceptions.dart';
import '../../../../core/network/network_client.dart';
import '../models/app_settings_model.dart';
import '../models/user_preferences_model.dart';

/// Remote data source constants
class SettingsApiEndpoints {
  /// Get user preferences
  static const String getUserPreferences = '/api/user/preferences';
  
  /// Update user preferences
  static const String updateUserPreferences = '/api/user/preferences';
  
  /// Reset user preferences to defaults
  static const String resetUserPreferences = '/api/user/preferences/reset';
  
  /// Get app settings
  static const String getAppSettings = '/api/app/settings';
  
  /// Update app settings
  static const String updateAppSettings = '/api/app/settings';
  
  /// Reset app settings to defaults
  static const String resetAppSettings = '/api/app/settings/reset';
}

/// Settings remote data source interface
abstract class SettingsRemoteDataSource {
  /// Get user preferences from server
  Future<UserPreferencesModel> getUserPreferences(String userId, String authToken);
  
  /// Update user preferences on server
  Future<UserPreferencesModel> updateUserPreferences(
    String userId,
    UserPreferencesModel preferences,
    String authToken,
  );
  
  /// Reset user preferences to defaults on server
  Future<UserPreferencesModel> resetUserPreferences(String userId, String authToken);
  
  /// Get app settings from server
  Future<AppSettingsModel> getAppSettings(String authToken);
  
  /// Update app settings on server
  Future<AppSettingsModel> updateAppSettings(AppSettingsModel settings, String authToken);
  
  /// Reset app settings to defaults on server
  Future<AppSettingsModel> resetAppSettings(String authToken);
  
  /// Toggle theme mode on server
  Future<UserPreferencesModel> toggleThemeMode(
    String userId,
    bool useDarkTheme,
    bool useSystemTheme,
    String authToken,
  );
  
  /// Toggle biometric authentication on server
  Future<UserPreferencesModel> toggleBiometrics(
    String userId,
    bool useBiometrics,
    String authToken,
  );
  
  /// Toggle notifications on server
  Future<UserPreferencesModel> toggleNotifications(
    String userId,
    bool enableNotifications,
    String authToken,
  );
}

/// Settings remote data source implementation
class SettingsRemoteDataSourceImpl implements SettingsRemoteDataSource {
  /// Network client
  final NetworkClient client;
  
  /// Create settings remote data source
  SettingsRemoteDataSourceImpl({
    required this.client,
  });
  
  @override
  Future<UserPreferencesModel> getUserPreferences(String userId, String authToken) async {
    try {
      final endpoint = '${SettingsApiEndpoints.getUserPreferences}/$userId';
      final response = await client.get(
        endpoint,
        requiresAuth: true,
        authToken: authToken,
      );
      
      return UserPreferencesModel.fromJson(response);
    } catch (e) {
      throw _handleException(e);
    }
  }
  
  @override
  Future<UserPreferencesModel> updateUserPreferences(
    String userId,
    UserPreferencesModel preferences,
    String authToken,
  ) async {
    try {
      final endpoint = '${SettingsApiEndpoints.updateUserPreferences}/$userId';
      final response = await client.put(
        endpoint,
        body: preferences.toJson(),
        requiresAuth: true,
        authToken: authToken,
      );
      
      return UserPreferencesModel.fromJson(response);
    } catch (e) {
      throw _handleException(e);
    }
  }
  
  @override
  Future<UserPreferencesModel> resetUserPreferences(String userId, String authToken) async {
    try {
      final endpoint = '${SettingsApiEndpoints.resetUserPreferences}/$userId';
      final response = await client.post(
        endpoint,
        requiresAuth: true,
        authToken: authToken,
      );
      
      return UserPreferencesModel.fromJson(response);
    } catch (e) {
      throw _handleException(e);
    }
  }
  
  @override
  Future<AppSettingsModel> getAppSettings(String authToken) async {
    try {
      final endpoint = SettingsApiEndpoints.getAppSettings;
      final response = await client.get(
        endpoint,
        requiresAuth: true,
        authToken: authToken,
      );
      
      return AppSettingsModel.fromJson(response);
    } catch (e) {
      throw _handleException(e);
    }
  }
  
  @override
  Future<AppSettingsModel> updateAppSettings(
    AppSettingsModel settings,
    String authToken,
  ) async {
    try {
      final endpoint = SettingsApiEndpoints.updateAppSettings;
      final response = await client.put(
        endpoint,
        body: settings.toJson(),
        requiresAuth: true,
        authToken: authToken,
      );
      
      return AppSettingsModel.fromJson(response);
    } catch (e) {
      throw _handleException(e);
    }
  }
  
  @override
  Future<AppSettingsModel> resetAppSettings(String authToken) async {
    try {
      final endpoint = SettingsApiEndpoints.resetAppSettings;
      final response = await client.post(
        endpoint,
        requiresAuth: true,
        authToken: authToken,
      );
      
      return AppSettingsModel.fromJson(response);
    } catch (e) {
      throw _handleException(e);
    }
  }
  
  @override
  Future<UserPreferencesModel> toggleThemeMode(
    String userId,
    bool useDarkTheme,
    bool useSystemTheme,
    String authToken,
  ) async {
    try {
      final endpoint = '${SettingsApiEndpoints.updateUserPreferences}/$userId/theme';
      final response = await client.put(
        endpoint,
        body: {
          'useDarkTheme': useDarkTheme,
          'useSystemTheme': useSystemTheme,
        },
        requiresAuth: true,
        authToken: authToken,
      );
      
      return UserPreferencesModel.fromJson(response);
    } catch (e) {
      throw _handleException(e);
    }
  }
  
  @override
  Future<UserPreferencesModel> toggleBiometrics(
    String userId,
    bool useBiometrics,
    String authToken,
  ) async {
    try {
      final endpoint = '${SettingsApiEndpoints.updateUserPreferences}/$userId/biometrics';
      final response = await client.put(
        endpoint,
        body: {
          'useBiometrics': useBiometrics,
        },
        requiresAuth: true,
        authToken: authToken,
      );
      
      return UserPreferencesModel.fromJson(response);
    } catch (e) {
      throw _handleException(e);
    }
  }
  
  @override
  Future<UserPreferencesModel> toggleNotifications(
    String userId,
    bool enableNotifications,
    String authToken,
  ) async {
    try {
      final endpoint = '${SettingsApiEndpoints.updateUserPreferences}/$userId/notifications';
      final response = await client.put(
        endpoint,
        body: {
          'enableNotifications': enableNotifications,
        },
        requiresAuth: true,
        authToken: authToken,
      );
      
      return UserPreferencesModel.fromJson(response);
    } catch (e) {
      throw _handleException(e);
    }
  }
  
  /// Handle exceptions from API calls
  Exception _handleException(dynamic error) {
    if (error is ServerException ||
        error is NetworkException ||
        error is AuthException ||
        error is ValidationException) {
      return error;
    }
    
    if (error is SocketException) {
      return const NetworkException(
        message: 'No internet connection',
      );
    }
    
    return ServerException(
      message: error.toString(),
    );
  }
}