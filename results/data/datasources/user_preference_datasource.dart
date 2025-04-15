import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import '../../../profile/domain/entities/user_profile.dart';

/// Data source for user preferences
class UserPreferenceDataSource {
  /// Box name for user preferences
  static const String _userPreferencesBox = 'user_preferences';
  
  /// Box for user preferences
  final Box _box;
  
  /// Create user preference data source
  UserPreferenceDataSource({
    Box? box,
  }) : _box = box ?? Hive.box(_userPreferencesBox);
  
  /// Initialize the data source
  static Future<void> initialize() async {
    try {
      await Hive.openBox(_userPreferencesBox);
    } catch (e) {
      debugPrint('Error initializing user preference data source: $e');
      rethrow;
    }
  }
  
  /// Get user profile
  Future<UserProfile?> getUserProfile() async {
    try {
      final data = _box.get('user_profile');
      
      if (data == null) {
        return null;
      }
      
      return UserProfile(
        id: data['id'],
        name: data['name'],
        email: data['email'],
        skinType: _parseSkinType(data['skinType']),
        skinConcerns: data['skinConcerns'] != null 
            ? List<String>.from(data['skinConcerns']) 
            : [],
        allergies: data['allergies'] != null 
            ? List<String>.from(data['allergies']) 
            : [],
        preferredIngredients: data['preferredIngredients'] != null 
            ? List<String>.from(data['preferredIngredients']) 
            : [],
        avoidedIngredients: data['avoidedIngredients'] != null 
            ? List<String>.from(data['avoidedIngredients']) 
            : [],
      );
    } catch (e) {
      debugPrint('Error getting user profile: $e');
      return null;
    }
  }
  
  /// Save user profile
  Future<void> saveUserProfile(UserProfile profile) async {
    try {
      await _box.put('user_profile', {
        'id': profile.id,
        'name': profile.name,
        'email': profile.email,
        'skinType': _skinTypeToString(profile.skinType),
        'skinConcerns': profile.skinConcerns,
        'allergies': profile.allergies,
        'preferredIngredients': profile.preferredIngredients,
        'avoidedIngredients': profile.avoidedIngredients,
      });
    } catch (e) {
      debugPrint('Error saving user profile: $e');
      rethrow;
    }
  }
  
  /// Parse skin type from string
  SkinType _parseSkinType(String? typeString) {
    switch (typeString?.toLowerCase()) {
      case 'dry':
        return SkinType.dry;
      case 'oily':
        return SkinType.oily;
      case 'combination':
        return SkinType.combination;
      case 'sensitive':
        return SkinType.sensitive;
      case 'normal':
      default:
        return SkinType.normal;
    }
  }
  
  /// Convert skin type to string
  String _skinTypeToString(SkinType type) {
    switch (type) {
      case SkinType.dry:
        return 'dry';
      case SkinType.oily:
        return 'oily';
      case SkinType.combination:
        return 'combination';
      case SkinType.sensitive:
        return 'sensitive';
      case SkinType.normal:
        return 'normal';
    }
  }
}