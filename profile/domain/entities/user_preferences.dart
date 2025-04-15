import 'package:equatable/equatable.dart';

/// Language preference
enum LanguagePreference {
  /// System default language
  systemDefault,
  
  /// English language
  english,
  
  /// Spanish language
  spanish,
  
  /// French language
  french,
  
  /// German language
  german,
  
  /// Japanese language
  japanese,
  
  /// Korean language
  korean,
  
  /// Chinese (Simplified) language
  chineseSimplified,
}

/// Notification type preference
enum NotificationType {
  /// All notifications
  all,
  
  /// Only important notifications
  important,
  
  /// Only product updates
  productUpdates,
  
  /// No notifications
  none,
}

/// User preferences for app settings
class UserPreferences extends Equatable {
  /// User ID
  final String? userId;
  
  /// Use system theme
  final bool useSystemTheme;
  
  /// Use dark theme
  final bool useDarkTheme;
  
  /// Enable biometric authentication
  final bool useBiometrics;
  
  /// Enable notifications
  final bool enableNotifications;
  
  /// Enable reminders
  final bool enableReminders;
  
  /// Enable product updates
  final bool enableProductUpdates;
  
  /// Notification type
  final NotificationType notificationType;
  
  /// Language preference
  final LanguagePreference languagePreference;
  
  /// Auto-save scan results
  final bool autoSaveScanResults;
  
  /// Sync data when on Wi-Fi only
  final bool syncOnWifiOnly;
  
  /// Auto-delete scan history after days (0 means never)
  final int autoDeleteScansAfterDays;
  
  /// Show scientific references
  final bool showScientificReferences;
  
  /// Last preferences update
  final DateTime? lastUpdated;
  
  /// Create user preferences
  const UserPreferences({
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
  
  /// Create copy of user preferences with modified fields
  UserPreferences copyWith({
    String? userId,
    bool? useSystemTheme,
    bool? useDarkTheme,
    bool? useBiometrics,
    bool? enableNotifications,
    bool? enableReminders,
    bool? enableProductUpdates,
    NotificationType? notificationType,
    LanguagePreference? languagePreference,
    bool? autoSaveScanResults,
    bool? syncOnWifiOnly,
    int? autoDeleteScansAfterDays,
    bool? showScientificReferences,
    DateTime? lastUpdated,
  }) {
    return UserPreferences(
      userId: userId ?? this.userId,
      useSystemTheme: useSystemTheme ?? this.useSystemTheme,
      useDarkTheme: useDarkTheme ?? this.useDarkTheme,
      useBiometrics: useBiometrics ?? this.useBiometrics,
      enableNotifications: enableNotifications ?? this.enableNotifications,
      enableReminders: enableReminders ?? this.enableReminders,
      enableProductUpdates: enableProductUpdates ?? this.enableProductUpdates,
      notificationType: notificationType ?? this.notificationType,
      languagePreference: languagePreference ?? this.languagePreference,
      autoSaveScanResults: autoSaveScanResults ?? this.autoSaveScanResults,
      syncOnWifiOnly: syncOnWifiOnly ?? this.syncOnWifiOnly,
      autoDeleteScansAfterDays: autoDeleteScansAfterDays ?? this.autoDeleteScansAfterDays,
      showScientificReferences: showScientificReferences ?? this.showScientificReferences,
      lastUpdated: lastUpdated ?? DateTime.now(),
    );
  }
  
  /// Convert to map for storage
  Map<String, dynamic> toMap() {
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
  
  /// Create from map
  factory UserPreferences.fromMap(Map<String, dynamic> map) {
    return UserPreferences(
      userId: map['userId'],
      useSystemTheme: map['useSystemTheme'] ?? true,
      useDarkTheme: map['useDarkTheme'] ?? false,
      useBiometrics: map['useBiometrics'] ?? false,
      enableNotifications: map['enableNotifications'] ?? true,
      enableReminders: map['enableReminders'] ?? true,
      enableProductUpdates: map['enableProductUpdates'] ?? true,
      notificationType: NotificationType.values[map['notificationType'] ?? 1], // Default to important
      languagePreference: LanguagePreference.values[map['languagePreference'] ?? 0], // Default to systemDefault
      autoSaveScanResults: map['autoSaveScanResults'] ?? true,
      syncOnWifiOnly: map['syncOnWifiOnly'] ?? true,
      autoDeleteScansAfterDays: map['autoDeleteScansAfterDays'] ?? 0,
      showScientificReferences: map['showScientificReferences'] ?? true,
      lastUpdated: map['lastUpdated'] != null ? DateTime.parse(map['lastUpdated']) : null,
    );
  }
  
  /// Default preferences for a user
  factory UserPreferences.defaults(String userId) {
    return UserPreferences(
      userId: userId,
      lastUpdated: DateTime.now(),
    );
  }
  
  @override
  List<Object?> get props => [
    userId,
    useSystemTheme,
    useDarkTheme,
    useBiometrics,
    enableNotifications,
    enableReminders,
    enableProductUpdates,
    notificationType,
    languagePreference,
    autoSaveScanResults,
    syncOnWifiOnly,
    autoDeleteScansAfterDays,
    showScientificReferences,
    lastUpdated,
  ];
}