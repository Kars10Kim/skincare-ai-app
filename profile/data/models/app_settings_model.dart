import 'package:hive/hive.dart';

import '../../domain/entities/app_settings.dart';

part 'app_settings_model.g.dart';

/// App settings model for Hive storage
@HiveType(typeId: 10)
class AppSettingsModel extends HiveObject {
  /// Theme mode
  @HiveField(0)
  final ThemeMode themeMode;
  
  /// Font scale factor (1.0 is normal)
  @HiveField(1)
  final double fontScale;
  
  /// Screen brightness override (-1 means use system)
  @HiveField(2)
  final double brightnessOverride;
  
  /// Enable analytics
  @HiveField(3)
  final bool enableAnalytics;
  
  /// Enable crash reporting
  @HiveField(4)
  final bool enableCrashReporting;
  
  /// Preferred scan mode
  @HiveField(5)
  final ScanMode preferredScanMode;
  
  /// Conflict display mode
  @HiveField(6)
  final ConflictDisplayMode conflictDisplayMode;
  
  /// Max ingredients to show in detail view
  @HiveField(7)
  final int maxIngredientsInDetail;
  
  /// Enable offline mode
  @HiveField(8)
  final bool enableOfflineMode;
  
  /// Last settings update
  @HiveField(9)
  final DateTime? lastUpdated;
  
  /// Create app settings model
  AppSettingsModel({
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
  
  /// Create model from entity
  factory AppSettingsModel.fromEntity(AppSettings settings) {
    return AppSettingsModel(
      themeMode: settings.themeMode,
      fontScale: settings.fontScale,
      brightnessOverride: settings.brightnessOverride,
      enableAnalytics: settings.enableAnalytics,
      enableCrashReporting: settings.enableCrashReporting,
      preferredScanMode: settings.preferredScanMode,
      conflictDisplayMode: settings.conflictDisplayMode,
      maxIngredientsInDetail: settings.maxIngredientsInDetail,
      enableOfflineMode: settings.enableOfflineMode,
      lastUpdated: settings.lastUpdated,
    );
  }
  
  /// Convert to entity
  AppSettings toEntity() {
    return AppSettings(
      themeMode: themeMode,
      fontScale: fontScale,
      brightnessOverride: brightnessOverride,
      enableAnalytics: enableAnalytics,
      enableCrashReporting: enableCrashReporting,
      preferredScanMode: preferredScanMode,
      conflictDisplayMode: conflictDisplayMode,
      maxIngredientsInDetail: maxIngredientsInDetail,
      enableOfflineMode: enableOfflineMode,
      lastUpdated: lastUpdated,
    );
  }
  
  /// Create from JSON map
  factory AppSettingsModel.fromJson(Map<String, dynamic> json) {
    return AppSettingsModel(
      themeMode: ThemeMode.values[json['themeMode'] ?? 2],
      fontScale: (json['fontScale'] as num?)?.toDouble() ?? 1.0,
      brightnessOverride: (json['brightnessOverride'] as num?)?.toDouble() ?? -1.0,
      enableAnalytics: json['enableAnalytics'] ?? true,
      enableCrashReporting: json['enableCrashReporting'] ?? true,
      preferredScanMode: ScanMode.values[json['preferredScanMode'] ?? 1],
      conflictDisplayMode: ConflictDisplayMode.values[json['conflictDisplayMode'] ?? 1],
      maxIngredientsInDetail: json['maxIngredientsInDetail'] ?? 15,
      enableOfflineMode: json['enableOfflineMode'] ?? false,
      lastUpdated: json['lastUpdated'] != null ? DateTime.parse(json['lastUpdated']) : null,
    );
  }
  
  /// Convert to JSON map
  Map<String, dynamic> toJson() {
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
}

/// ThemeMode adapter for Hive
@HiveType(typeId: 11)
enum ThemeMode {
  @HiveField(0)
  light,
  
  @HiveField(1)
  dark,
  
  @HiveField(2)
  system,
}

/// ScanMode adapter for Hive
@HiveType(typeId: 12)
enum ScanMode {
  @HiveField(0)
  barcodeFirst,
  
  @HiveField(1)
  cameraFirst,
  
  @HiveField(2)
  askEachTime,
}

/// ConflictDisplayMode adapter for Hive
@HiveType(typeId: 13)
enum ConflictDisplayMode {
  @HiveField(0)
  showAll,
  
  @HiveField(1)
  showUserRelevant,
  
  @HiveField(2)
  groupByCategory,
}