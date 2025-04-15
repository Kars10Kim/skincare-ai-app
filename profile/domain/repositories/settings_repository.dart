import 'package:dartz/dartz.dart';

import '../entities/app_settings.dart';
import '../entities/user_preferences.dart';
import '../../../../core/error/failures.dart';

/// Repository for settings operations
abstract class SettingsRepository {
  /// Get user preferences
  Future<Either<Failure, UserPreferences>> getUserPreferences(String userId);
  
  /// Get cached user preferences (for offline use)
  Future<Either<Failure, UserPreferences>> getCachedUserPreferences(String userId);
  
  /// Update user preferences
  Future<Either<Failure, UserPreferences>> updateUserPreferences(
    String userId,
    UserPreferences preferences,
  );
  
  /// Reset user preferences to defaults
  Future<Either<Failure, UserPreferences>> resetUserPreferences(String userId);
  
  /// Get app settings
  Future<Either<Failure, AppSettings>> getAppSettings();
  
  /// Get cached app settings (for offline use)
  Future<Either<Failure, AppSettings>> getCachedAppSettings();
  
  /// Update app settings
  Future<Either<Failure, AppSettings>> updateAppSettings(AppSettings settings);
  
  /// Reset app settings to defaults
  Future<Either<Failure, AppSettings>> resetAppSettings();
  
  /// Toggle theme mode (dark/light/system)
  Future<Either<Failure, UserPreferences>> toggleThemeMode(
    String userId, 
    bool useDarkTheme, 
    bool useSystemTheme,
  );
  
  /// Toggle biometric authentication
  Future<Either<Failure, UserPreferences>> toggleBiometrics(
    String userId, 
    bool useBiometrics,
  );
  
  /// Toggle notifications
  Future<Either<Failure, UserPreferences>> toggleNotifications(
    String userId, 
    bool enableNotifications,
  );
  
  /// Export user data as JSON string
  Future<Either<Failure, String>> exportUserData(String userId);
  
  /// Import user data from JSON string
  Future<Either<Failure, Unit>> importUserData(String userId, String jsonData);
  
  /// Clear all local data
  Future<Either<Failure, Unit>> clearLocalData(String userId);
  
  /// Dispose any resources
  Future<void> dispose();
}