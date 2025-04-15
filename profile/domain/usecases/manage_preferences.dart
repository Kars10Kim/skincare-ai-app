import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../repositories/settings_repository.dart';
import '../entities/user_preferences.dart';
import '../entities/app_settings.dart';

/// Use case to manage user preferences and app settings
class ManagePreferences {
  /// Settings repository
  final SettingsRepository repository;
  
  /// Create manage preferences use case
  ManagePreferences(this.repository);
  
  /// Toggle theme mode (dark/light/system)
  Future<Either<Failure, UserPreferences>> toggleThemeMode({
    required String userId,
    required bool useDarkTheme,
    required bool useSystemTheme,
  }) async {
    return repository.toggleThemeMode(userId, useDarkTheme, useSystemTheme);
  }
  
  /// Toggle biometric authentication
  Future<Either<Failure, UserPreferences>> toggleBiometrics({
    required String userId,
    required bool useBiometrics,
  }) async {
    return repository.toggleBiometrics(userId, useBiometrics);
  }
  
  /// Toggle notifications
  Future<Either<Failure, UserPreferences>> toggleNotifications({
    required String userId,
    required bool enableNotifications,
    bool? enableReminders,
    bool? enableProductUpdates,
  }) async {
    // Get current preferences
    final preferencesResult = await repository.getUserPreferences(userId);
    
    if (preferencesResult.isLeft()) {
      return preferencesResult;
    }
    
    // Get current preferences value
    final currentPreferences = preferencesResult.getOrElse(() => const UserPreferences());
    
    // Create updated preferences
    final updatedPreferences = currentPreferences.copyWith(
      enableNotifications: enableNotifications,
      enableReminders: enableReminders,
      enableProductUpdates: enableProductUpdates,
    );
    
    // Update preferences
    return repository.updateUserPreferences(userId, updatedPreferences);
  }
  
  /// Update app settings
  Future<Either<Failure, AppSettings>> updateAppSettings({
    required AppSettings settings,
  }) async {
    return repository.updateAppSettings(settings);
  }
  
  /// Reset user preferences to defaults
  Future<Either<Failure, UserPreferences>> resetUserPreferences({
    required String userId,
  }) async {
    return repository.resetUserPreferences(userId);
  }
  
  /// Reset app settings to defaults
  Future<Either<Failure, AppSettings>> resetAppSettings() async {
    return repository.resetAppSettings();
  }
  
  /// Export user data as JSON string
  Future<Either<Failure, String>> exportUserData({
    required String userId,
  }) async {
    return repository.exportUserData(userId);
  }
  
  /// Import user data from JSON string
  Future<Either<Failure, Unit>> importUserData({
    required String userId,
    required String jsonData,
  }) async {
    // Validate JSON data format
    try {
      // Note: The actual validation would be performed in the repository
      return repository.importUserData(userId, jsonData);
    } catch (e) {
      return Left(ValidationFailure(
        message: 'Invalid data format',
        field: 'jsonData',
      ));
    }
  }
  
  /// Clear all local data
  Future<Either<Failure, Unit>> clearLocalData({
    required String userId,
  }) async {
    return repository.clearLocalData(userId);
  }
}