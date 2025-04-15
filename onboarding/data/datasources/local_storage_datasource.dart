import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/skin_profile.dart';
import '../../domain/entities/survey_step.dart';
import '../models/default_survey_config.dart';

/// Abstract local storage data source
abstract class LocalStorageDataSource {
  /// Get user's skin profile
  Future<SkinProfile?> getSkinProfile();
  
  /// Save user's skin profile
  Future<void> saveSkinProfile(SkinProfile profile);
  
  /// Get default survey config
  Future<List<SurveyStep>> getSurveyConfig();
  
  /// Check if user has completed onboarding
  Future<bool> hasCompletedOnboarding();
  
  /// Set onboarding completion status
  Future<void> setOnboardingComplete(bool completed);
  
  /// Cache arbitrary data with a key
  Future<void> cacheData(String key, String data);
  
  /// Get cached data by key
  Future<String?> getCachedData(String key);
  
  /// Clear cached data for a key
  Future<void> clearCachedData(String key);
  
  /// Dispose of any resources
  void dispose();
}

/// Implementation using Hive for storage
class HiveProfileStorage implements LocalStorageDataSource {
  /// Box name for skin profile
  static const String _profileBoxName = 'skin_profile';
  
  /// Box name for cache
  static const String _cacheBoxName = 'cache_data';
  
  /// Key for skin profile
  static const String _profileKey = 'profile';
  
  /// Key for onboarding completion
  static const String _onboardingCompleteKey = 'onboarding_complete';
  
  /// Initialize Hive
  static Future<void> initialize() async {
    await Hive.initFlutter();
    await Hive.openBox<String>(_profileBoxName);
    await Hive.openBox<String>(_cacheBoxName);
  }
  
  @override
  Future<SkinProfile?> getSkinProfile() async {
    final box = Hive.box<String>(_profileBoxName);
    final profileJson = box.get(_profileKey);
    
    if (profileJson == null) {
      return null;
    }
    
    try {
      return SkinProfile.fromJson(
        Map<String, dynamic>.from(json.decode(profileJson)),
      );
    } catch (e) {
      // Handle deserialization error
      return null;
    }
  }
  
  @override
  Future<void> saveSkinProfile(SkinProfile profile) async {
    final box = Hive.box<String>(_profileBoxName);
    await box.put(_profileKey, json.encode(profile.toJson()));
  }
  
  @override
  Future<List<SurveyStep>> getSurveyConfig() async {
    // Return default config
    return DefaultSurveyConfig.getSteps();
  }
  
  @override
  Future<bool> hasCompletedOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingCompleteKey) ?? false;
  }
  
  @override
  Future<void> setOnboardingComplete(bool completed) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingCompleteKey, completed);
  }
  
  @override
  Future<void> cacheData(String key, String data) async {
    final box = Hive.box<String>(_cacheBoxName);
    await box.put(key, data);
  }
  
  @override
  Future<String?> getCachedData(String key) async {
    final box = Hive.box<String>(_cacheBoxName);
    return box.get(key);
  }
  
  @override
  Future<void> clearCachedData(String key) async {
    final box = Hive.box<String>(_cacheBoxName);
    await box.delete(key);
  }
  
  @override
  void dispose() {
    // No need to dispose anything for Hive
  }
}