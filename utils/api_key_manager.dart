import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/vision_service.dart';

/// Manager for API keys
class ApiKeyManager {
  /// Secure storage instance
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  /// Key for Google Vision API
  static const String _googleVisionKey = 'google_vision_api_key';

  /// Get the Google Vision API key
  static Future<String?> getGoogleVisionApiKey() async {
    try {
      return await _secureStorage.read(key: _googleVisionKey);
    } catch (e) {
      debugPrint('Error reading Google Vision API key: $e');
      return null;
    }
  }

  /// Save the Google Vision API key
  static Future<bool> saveGoogleVisionApiKey(String apiKey) async {
    try {
      await _secureStorage.write(key: _googleVisionKey, value: apiKey);
      return true;
    } catch (e) {
      debugPrint('Error saving Google Vision API key: $e');
      return false;
    }
  }

  /// Initialize API keys
  static Future<void> initializeApiKeys() async {
    try {
      // Initialize Google Vision API
      final visionApiKey = await getGoogleVisionApiKey();
      if (visionApiKey != null && visionApiKey.isNotEmpty) {
        VisionService.initialize(visionApiKey);
        debugPrint('Google Vision API key initialized');
      } else {
        debugPrint('Google Vision API key not found');
      }
    } catch (e) {
      debugPrint('Error initializing API keys: $e');
    }
  }

  /// Check if Google Vision API key is set
  static Future<bool> hasGoogleVisionApiKey() async {
    final key = await getGoogleVisionApiKey();
    return key != null && key.isNotEmpty;
  }

  /// Clear all API keys (for logout or reset)
  static Future<void> clearAllApiKeys() async {
    try {
      await _secureStorage.deleteAll();
      debugPrint('All API keys cleared');
    } catch (e) {
      debugPrint('Error clearing API keys: $e');
    }
  }
}