import 'package:equatable/equatable.dart';

/// Application scan mode settings
enum ScanMode {
  /// Scan with barcode first
  barcodeFirst,
  
  /// Scan with camera/text recognition first
  cameraFirst,
  
  /// Ask user each time which mode to use
  askEachTime,
}

/// Conflict display options
enum ConflictDisplayMode {
  /// Show all conflicts
  showAll,
  
  /// Show only user-relevant conflicts (based on user skin type, concerns)
  showUserRelevant,
  
  /// Group conflicts by category
  groupByCategory,
}

/// Theme mode
enum ThemeMode {
  /// Light theme
  light,
  
  /// Dark theme
  dark,
  
  /// Use system theme
  system,
}

/// Application settings
class AppSettings extends Equatable {
  /// Theme mode
  final ThemeMode themeMode;
  
  /// Font scale factor (1.0 is normal)
  final double fontScale;
  
  /// Screen brightness override (-1 means use system)
  final double brightnessOverride;
  
  /// Enable analytics
  final bool enableAnalytics;
  
  /// Enable crash reporting
  final bool enableCrashReporting;
  
  /// Preferred scan mode
  final ScanMode preferredScanMode;
  
  /// Conflict display mode
  final ConflictDisplayMode conflictDisplayMode;
  
  /// Max ingredients to show in detail view
  final int maxIngredientsInDetail;
  
  /// Enable offline mode
  final bool enableOfflineMode;
  
  /// Last settings update
  final DateTime? lastUpdated;
  
  /// Create app settings
  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.fontScale = 1.0,
    this.brightnessOverride = -1.0,
    this.enableAnalytics = true,
    this.enableCrashReporting = true,
    this.preferredScanMode = ScanMode.cameraFirst,
    this.conflictDisplayMode = ConflictDisplayMode.showUserRelevant,
    this.maxIngredientsInDetail = 15,
    this.enableOfflineMode = false,
    this.lastUpdated,
  });
  
  /// Create copy of app settings with modified fields
  AppSettings copyWith({
    ThemeMode? themeMode,
    double? fontScale,
    double? brightnessOverride,
    bool? enableAnalytics,
    bool? enableCrashReporting,
    ScanMode? preferredScanMode,
    ConflictDisplayMode? conflictDisplayMode,
    int? maxIngredientsInDetail,
    bool? enableOfflineMode,
    DateTime? lastUpdated,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      fontScale: fontScale ?? this.fontScale,
      brightnessOverride: brightnessOverride ?? this.brightnessOverride,
      enableAnalytics: enableAnalytics ?? this.enableAnalytics,
      enableCrashReporting: enableCrashReporting ?? this.enableCrashReporting,
      preferredScanMode: preferredScanMode ?? this.preferredScanMode,
      conflictDisplayMode: conflictDisplayMode ?? this.conflictDisplayMode,
      maxIngredientsInDetail: maxIngredientsInDetail ?? this.maxIngredientsInDetail,
      enableOfflineMode: enableOfflineMode ?? this.enableOfflineMode,
      lastUpdated: lastUpdated ?? DateTime.now(),
    );
  }
  
  /// Convert to map for storage
  Map<String, dynamic> toMap() {
    return {
      'themeMode': themeMode.index,
      'fontScale': fontScale,
      'brightnessOverride': brightnessOverride,
      'enableAnalytics': enableAnalytics,
      'enableCrashReporting': enableCrashReporting,
      'preferredScanMode': preferredScanMode.index,
      'conflictDisplayMode': conflictDisplayMode.index,
      'maxIngredientsInDetail': maxIngredientsInDetail,
      'enableOfflineMode': enableOfflineMode,
      'lastUpdated': lastUpdated?.toIso8601String(),
    };
  }
  
  /// Create from map
  factory AppSettings.fromMap(Map<String, dynamic> map) {
    return AppSettings(
      themeMode: ThemeMode.values[map['themeMode'] ?? 2], // Default to system
      fontScale: (map['fontScale'] as num?)?.toDouble() ?? 1.0,
      brightnessOverride: (map['brightnessOverride'] as num?)?.toDouble() ?? -1.0,
      enableAnalytics: map['enableAnalytics'] ?? true,
      enableCrashReporting: map['enableCrashReporting'] ?? true,
      preferredScanMode: ScanMode.values[map['preferredScanMode'] ?? 1], // Default to cameraFirst
      conflictDisplayMode: ConflictDisplayMode.values[map['conflictDisplayMode'] ?? 1], // Default to showUserRelevant
      maxIngredientsInDetail: map['maxIngredientsInDetail'] ?? 15,
      enableOfflineMode: map['enableOfflineMode'] ?? false,
      lastUpdated: map['lastUpdated'] != null ? DateTime.parse(map['lastUpdated']) : null,
    );
  }
  
  /// Default settings
  factory AppSettings.defaults() {
    return AppSettings(
      lastUpdated: DateTime.now(),
    );
  }
  
  @override
  List<Object?> get props => [
    themeMode,
    fontScale,
    brightnessOverride,
    enableAnalytics,
    enableCrashReporting,
    preferredScanMode,
    conflictDisplayMode,
    maxIngredientsInDetail,
    enableOfflineMode,
    lastUpdated,
  ];
}