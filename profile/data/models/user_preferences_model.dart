import 'package:hive/hive.dart';

import '../../domain/entities/user_preferences.dart';

part 'user_preferences_model.g.dart';

/// User preferences model for Hive storage
@HiveType(typeId: 7)
class UserPreferencesModel extends HiveObject {
  /// User ID
  @HiveField(0)
  final String? userId;
  
  /// Use system theme
  @HiveField(1)
  final bool useSystemTheme;
  
  /// Use dark theme
  @HiveField(2)
  final bool useDarkTheme;
  
  /// Enable biometric authentication
  @HiveField(3)
  final bool useBiometrics;
  
  /// Enable notifications
  @HiveField(4)
  final bool enableNotifications;
  
  /// Enable reminders
  @HiveField(5)
  final bool enableReminders;
  
  /// Enable product updates
  @HiveField(6)
  final bool enableProductUpdates;
  
  /// Notification type
  @HiveField(7)
  final NotificationType notificationType;
  
  /// Language preference
  @HiveField(8)
  final LanguagePreference languagePreference;
  
  /// Auto-save scan results
  @HiveField(9)
  final bool autoSaveScanResults;
  
  /// Sync data when on Wi-Fi only
  @HiveField(10)
  final bool syncOnWifiOnly;
  
  /// Auto-delete scan history after days (0 means never)
  @HiveField(11)
  final int autoDeleteScansAfterDays;
  
  /// Show scientific references
  @HiveField(12)
  final bool showScientificReferences;
  
  /// Last preferences update
  @HiveField(13)
  final DateTime? lastUpdated;
  
  /// Create user preferences model
  UserPreferencesModel({
    this.userId,
    this.useSystemTheme = true,
    this.useDarkTheme = false,
    this.useBiometrics = false,
    this.enableNotifications = true,
    this.enableReminders = true,
    this.enableProductUpdates = true,
    this.notificationType = NotificationType.important,
    this.languagePreference = LanguagePreference.systemDefault,
    this.autoSaveScanResults = true,
    this.syncOnWifiOnly = true,
    this.autoDeleteScansAfterDays = 0,
    this.showScientificReferences = true,
    this.lastUpdated,
  });
  
  /// Create model from entity
  factory UserPreferencesModel.fromEntity(UserPreferences preferences) {
    return UserPreferencesModel(
      userId: preferences.userId,
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
      lastUpdated: preferences.lastUpdated,
    );
  }
  
  /// Convert to entity
  UserPreferences toEntity() {
    return UserPreferences(
      userId: userId,
      useSystemTheme: useSystemTheme,
      useDarkTheme: useDarkTheme,
      useBiometrics: useBiometrics,
      enableNotifications: enableNotifications,
      enableReminders: enableReminders,
      enableProductUpdates: enableProductUpdates,
      notificationType: notificationType,
      languagePreference: languagePreference,
      autoSaveScanResults: autoSaveScanResults,
      syncOnWifiOnly: syncOnWifiOnly,
      autoDeleteScansAfterDays: autoDeleteScansAfterDays,
      showScientificReferences: showScientificReferences,
      lastUpdated: lastUpdated,
    );
  }
  
  /// Create from JSON map
  factory UserPreferencesModel.fromJson(Map<String, dynamic> json) {
    return UserPreferencesModel(
      userId: json['userId'],
      useSystemTheme: json['useSystemTheme'] ?? true,
      useDarkTheme: json['useDarkTheme'] ?? false,
      useBiometrics: json['useBiometrics'] ?? false,
      enableNotifications: json['enableNotifications'] ?? true,
      enableReminders: json['enableReminders'] ?? true,
      enableProductUpdates: json['enableProductUpdates'] ?? true,
      notificationType: NotificationType.values[json['notificationType'] ?? 1],
      languagePreference: LanguagePreference.values[json['languagePreference'] ?? 0],
      autoSaveScanResults: json['autoSaveScanResults'] ?? true,
      syncOnWifiOnly: json['syncOnWifiOnly'] ?? true,
      autoDeleteScansAfterDays: json['autoDeleteScansAfterDays'] ?? 0,
      showScientificReferences: json['showScientificReferences'] ?? true,
      lastUpdated: json['lastUpdated'] != null ? DateTime.parse(json['lastUpdated']) : null,
    );
  }
  
  /// Convert to JSON map
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'useSystemTheme': useSystemTheme,
      'useDarkTheme': useDarkTheme,
      'useBiometrics': useBiometrics,
      'enableNotifications': enableNotifications,
      'enableReminders': enableReminders,
      'enableProductUpdates': enableProductUpdates,
      'notificationType': notificationType.index,
      'languagePreference': languagePreference.index,
      'autoSaveScanResults': autoSaveScanResults,
      'syncOnWifiOnly': syncOnWifiOnly,
      'autoDeleteScansAfterDays': autoDeleteScansAfterDays,
      'showScientificReferences': showScientificReferences,
      'lastUpdated': lastUpdated?.toIso8601String(),
    };
  }
}

/// NotificationType adapter for Hive
@HiveType(typeId: 8)
enum NotificationType {
  @HiveField(0)
  all,
  
  @HiveField(1)
  important,
  
  @HiveField(2)
  productUpdates,
  
  @HiveField(3)
  none,
}

/// LanguagePreference adapter for Hive
@HiveType(typeId: 9)
enum LanguagePreference {
  @HiveField(0)
  systemDefault,
  
  @HiveField(1)
  english,
  
  @HiveField(2)
  spanish,
  
  @HiveField(3)
  french,
  
  @HiveField(4)
  german,
  
  @HiveField(5)
  japanese,
  
  @HiveField(6)
  korean,
  
  @HiveField(7)
  chineseSimplified,
}