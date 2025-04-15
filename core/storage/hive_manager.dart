import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

import '../../features/recognition/data/models/scan_history_model.dart';
import '../../features/recognition/data/models/ingredient_conflict_model.dart';
import '../../features/profile/data/models/user_profile_model.dart';
import '../../features/profile/data/models/user_preferences_model.dart';
import '../../features/profile/data/models/app_settings_model.dart';

/// Hive box names
class HiveBoxes {
  /// Scan history box
  static const String scanHistory = 'scan_history';
  
  /// Ingredient conflicts box
  static const String ingredientConflicts = 'ingredient_conflicts';
  
  /// User preferences box
  static const String userPreferences = 'user_preferences';
  
  /// App settings box
  static const String appSettings = 'app_settings';
  
  /// User profiles box
  static const String userProfiles = 'user_profiles';
  
  /// Cache box
  static const String cache = 'cache';
  
  /// Secure storage box (encrypted)
  static const String secureStorage = 'secure_storage';
}

/// Hive storage manager
class HiveManager {
  /// Singleton instance
  static final HiveManager _instance = HiveManager._internal();
  
  /// Get singleton instance
  factory HiveManager() => _instance;
  
  /// Internal constructor
  HiveManager._internal();
  
  /// Is initialized
  bool _isInitialized = false;
  
  /// Get scan history box
  Box<ScanHistoryModel> get scanHistoryBox => 
      Hive.box<ScanHistoryModel>(HiveBoxes.scanHistory);
  
  /// Get ingredient conflicts box
  Box<IngredientConflictModel> get ingredientConflictsBox => 
      Hive.box<IngredientConflictModel>(HiveBoxes.ingredientConflicts);
  
  /// Get user preferences box
  Box<UserPreferencesModel> get userPreferencesBox => 
      Hive.box<UserPreferencesModel>(HiveBoxes.userPreferences);
  
  /// Get app settings box
  Box<AppSettingsModel> get appSettingsBox => 
      Hive.box<AppSettingsModel>(HiveBoxes.appSettings);
  
  /// Get user profiles box
  Box<UserProfileModel> get userProfilesBox => 
      Hive.box<UserProfileModel>(HiveBoxes.userProfiles);
  
  /// Get cache box
  Box get cacheBox => Hive.box(HiveBoxes.cache);
  
  /// Get secure storage box
  Box get secureStorageBox => Hive.box(HiveBoxes.secureStorage);
  
  /// Initialize Hive
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Initialize Hive
      await Hive.initFlutter();
      
      // Register adapters
      Hive.registerAdapter(ScanHistoryModelAdapter());
      Hive.registerAdapter(HiveScanTypeAdapter());
      Hive.registerAdapter(IngredientConflictModelAdapter());
      Hive.registerAdapter(ConflictSeverityAdapter());
      
      // Register profile adapters
      Hive.registerAdapter(UserProfileModelAdapter());
      Hive.registerAdapter(SkinTypeAdapter());
      Hive.registerAdapter(AccountStatusAdapter());
      Hive.registerAdapter(UserPreferencesModelAdapter());
      Hive.registerAdapter(NotificationTypeAdapter());
      Hive.registerAdapter(LanguagePreferenceAdapter());
      Hive.registerAdapter(AppSettingsModelAdapter());
      Hive.registerAdapter(ThemeModeAdapter());
      Hive.registerAdapter(ScanModeAdapter());
      Hive.registerAdapter(ConflictDisplayModeAdapter());
      
      // Open boxes
      await Hive.openBox<ScanHistoryModel>(HiveBoxes.scanHistory);
      await Hive.openBox<IngredientConflictModel>(HiveBoxes.ingredientConflicts);
      await Hive.openBox<UserPreferencesModel>(HiveBoxes.userPreferences);
      await Hive.openBox<AppSettingsModel>(HiveBoxes.appSettings);
      await Hive.openBox<UserProfileModel>(HiveBoxes.userProfiles);
      await Hive.openBox(HiveBoxes.cache);
      
      // Open encrypted box for sensitive data
      await Hive.openBox(HiveBoxes.secureStorage, 
          encryptionCipher: HiveAesCipher(_getEncryptionKey()));
      
      _isInitialized = true;
      debugPrint('Hive initialized successfully');
    } catch (e) {
      debugPrint('Error initializing Hive: $e');
      rethrow;
    }
  }
  
  /// Get encryption key for secure storage
  /// In a real app, this would use a secure key storage solution
  List<int> _getEncryptionKey() {
    // This is a placeholder implementation
    // In production, use a proper key management system
    return List<int>.generate(32, (i) => i * i % 255);
  }
  
  /// Clear all data
  Future<void> clearAll() async {
    await scanHistoryBox.clear();
    await ingredientConflictsBox.clear();
    await userPreferencesBox.clear();
    await appSettingsBox.clear();
    await userProfilesBox.clear();
    await cacheBox.clear();
    await secureStorageBox.clear();
  }
  
  /// Close all boxes
  Future<void> closeAll() async {
    await Hive.close();
    _isInitialized = false;
  }
}