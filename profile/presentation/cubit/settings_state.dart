import 'package:equatable/equatable.dart';

import '../../domain/entities/app_settings.dart';
import '../../domain/entities/user_preferences.dart';

/// Settings state
abstract class SettingsState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Settings initial state
class SettingsInitial extends SettingsState {}

/// Settings loading state
class SettingsLoading extends SettingsState {}

/// Settings loaded state
class SettingsLoaded extends SettingsState {
  /// User preferences
  final UserPreferences preferences;
  
  /// App settings
  final AppSettings appSettings;
  
  /// Whether settings are being updated
  final bool isUpdating;
  
  /// Create settings loaded state
  SettingsLoaded({
    required this.preferences,
    required this.appSettings,
    this.isUpdating = false,
  });
  
  @override
  List<Object?> get props => [preferences, appSettings, isUpdating];
  
  /// Create copy with modified fields
  SettingsLoaded copyWith({
    UserPreferences? preferences,
    AppSettings? appSettings,
    bool? isUpdating,
  }) {
    return SettingsLoaded(
      preferences: preferences ?? this.preferences,
      appSettings: appSettings ?? this.appSettings,
      isUpdating: isUpdating ?? this.isUpdating,
    );
  }
}

/// Settings error state
class SettingsError extends SettingsState {
  /// Error message
  final String message;
  
  /// Error code
  final int? code;
  
  /// Create settings error state
  SettingsError({
    required this.message,
    this.code,
  });
  
  @override
  List<Object?> get props => [message, code];
}

/// Theme update state
class ThemeUpdateSuccess extends SettingsState {
  /// Use dark theme
  final bool useDarkTheme;
  
  /// Use system theme
  final bool useSystemTheme;
  
  /// Create theme update success state
  ThemeUpdateSuccess({
    required this.useDarkTheme,
    required this.useSystemTheme,
  });
  
  @override
  List<Object?> get props => [useDarkTheme, useSystemTheme];
}

/// Biometrics update state
class BiometricsUpdateSuccess extends SettingsState {
  /// Use biometrics
  final bool useBiometrics;
  
  /// Create biometrics update success state
  BiometricsUpdateSuccess({
    required this.useBiometrics,
  });
  
  @override
  List<Object?> get props => [useBiometrics];
}

/// Notifications update state
class NotificationsUpdateSuccess extends SettingsState {
  /// Enable notifications
  final bool enableNotifications;
  
  /// Create notifications update success state
  NotificationsUpdateSuccess({
    required this.enableNotifications,
  });
  
  @override
  List<Object?> get props => [enableNotifications];
}

/// Settings export state
class SettingsExporting extends SettingsState {}

/// Settings export success state
class SettingsExportSuccess extends SettingsState {
  /// JSON data
  final String jsonData;
  
  /// Create settings export success state
  SettingsExportSuccess({
    required this.jsonData,
  });
  
  @override
  List<Object?> get props => [jsonData];
}

/// Settings export error state
class SettingsExportError extends SettingsState {
  /// Error message
  final String message;
  
  /// Create settings export error state
  SettingsExportError({
    required this.message,
  });
  
  @override
  List<Object?> get props => [message];
}

/// Settings import state
class SettingsImporting extends SettingsState {}

/// Settings import success state
class SettingsImportSuccess extends SettingsState {}

/// Settings import error state
class SettingsImportError extends SettingsState {
  /// Error message
  final String message;
  
  /// Create settings import error state
  SettingsImportError({
    required this.message,
  });
  
  @override
  List<Object?> get props => [message];
}

/// Settings reset state
class SettingsResetting extends SettingsState {}

/// Settings reset success state
class SettingsResetSuccess extends SettingsState {
  /// Reset preferences
  final UserPreferences preferences;
  
  /// Reset app settings
  final AppSettings appSettings;
  
  /// Create settings reset success state
  SettingsResetSuccess({
    required this.preferences,
    required this.appSettings,
  });
  
  @override
  List<Object?> get props => [preferences, appSettings];
}

/// Settings reset error state
class SettingsResetError extends SettingsState {
  /// Error message
  final String message;
  
  /// Create settings reset error state
  SettingsResetError({
    required this.message,
  });
  
  @override
  List<Object?> get props => [message];
}