import 'dart:convert';
import 'package:drift/drift.dart';
import '../database/app_database.dart';
import '../models/onboarding_model.dart';
import '../services/sync_service.dart';

/// Repository for user preferences
class UserPreferencesRepository {
  /// Database instance
  final AppDatabase _database;
  
  /// Sync service
  final SyncService _syncService;
  
  /// Creates a user preferences repository
  UserPreferencesRepository(this._database, this._syncService);
  
  /// Get user preferences
  Future<OnboardingData?> getUserPreferences(String userId) async {
    final prefs = await _database.getUserPreferences(userId);
    if (prefs == null) {
      return null;
    }
    
    return _mapToOnboardingData(prefs);
  }
  
  /// Save user preferences
  Future<void> saveUserPreferences(
    String userId,
    OnboardingData preferences,
  ) async {
    final preferencesCompanion = UserPreferencesCompanion(
      userId: Value(userId),
      skinType: Value(preferences.skinType?.index),
      skinConcerns: Value(_encodeConcerns(preferences.selectedConcerns)),
      allergens: Value(jsonEncode(preferences.selectedAllergens)),
      updatedAt: Value(DateTime.now()),
    );
    
    await _database.saveUserPreferences(preferencesCompanion);
    
    // Queue for synchronization
    await _syncService.queueUserPreferenceSync(
      userId,
      _createPreferencesSyncData(userId, preferences),
    );
  }
  
  /// Encode skin concerns list
  String _encodeConcerns(List<SkinConcern> concerns) {
    final indices = concerns.map((c) => c.index).toList();
    return jsonEncode(indices);
  }
  
  /// Decode skin concerns list
  List<SkinConcern> _decodeConcerns(String encoded) {
    final indices = List<int>.from(jsonDecode(encoded));
    return indices.map((i) => SkinConcern.values[i]).toList();
  }
  
  /// Map database model to domain model
  OnboardingData _mapToOnboardingData(UserPreference prefs) {
    return OnboardingData(
      skinType: prefs.skinType != null
          ? SkinType.values[prefs.skinType!]
          : null,
      selectedConcerns: _decodeConcerns(prefs.skinConcerns),
      selectedAllergens: List<String>.from(jsonDecode(prefs.allergens)),
    );
  }
  
  /// Create preferences sync data
  Map<String, dynamic> _createPreferencesSyncData(
    String userId,
    OnboardingData preferences,
  ) {
    return {
      'user_id': userId,
      'skin_type': preferences.skinType?.index,
      'skin_concerns': preferences.selectedConcerns.map((c) => c.index).toList(),
      'allergens': preferences.selectedAllergens,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }
}