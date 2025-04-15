import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/encryption_service.dart';

/// Secure storage wrapper for handling secure preferences
class SecurePreferences {
  /// Flutter secure storage instance for secure data
  final FlutterSecureStorage _secureStorage;
  
  /// Shared preferences for non-sensitive data or web platform
  SharedPreferences? _sharedPreferences;
  
  /// Encryption service
  final EncryptionService _encryptionService;
  
  /// Creates a new secure preferences instance
  SecurePreferences({
    required EncryptionService encryptionService,
    FlutterSecureStorage? secureStorage,
  }) : 
    _secureStorage = secureStorage ?? const FlutterSecureStorage(),
    _encryptionService = encryptionService;
  
  /// Initialize shared preferences
  Future<void> _initSharedPreferences() async {
    _sharedPreferences ??= await SharedPreferences.getInstance();
  }
  
  /// Store a string value securely
  Future<void> setString(String key, String value) async {
    if (kIsWeb) {
      // On web platform, encrypt and use shared preferences
      await _initSharedPreferences();
      final encryptedValue = await _encryptionService.encrypt(value);
      await _sharedPreferences!.setString(key, encryptedValue);
    } else {
      // On mobile platforms, use secure storage
      await _secureStorage.write(key: key, value: value);
    }
  }
  
  /// Get a string value from secure storage
  Future<String?> getString(String key) async {
    if (kIsWeb) {
      // On web platform, get from shared preferences and decrypt
      await _initSharedPreferences();
      final encryptedValue = _sharedPreferences!.getString(key);
      if (encryptedValue == null) return null;
      return await _encryptionService.decrypt(encryptedValue);
    } else {
      // On mobile platforms, get from secure storage
      return await _secureStorage.read(key: key);
    }
  }
  
  /// Remove a value from secure storage
  Future<void> remove(String key) async {
    if (kIsWeb) {
      await _initSharedPreferences();
      await _sharedPreferences!.remove(key);
    } else {
      await _secureStorage.delete(key: key);
    }
  }
  
  /// Clear all values from secure storage
  Future<void> clear() async {
    if (kIsWeb) {
      await _initSharedPreferences();
      
      // Only clear keys managed by this app
      final allKeys = _sharedPreferences!.getKeys();
      for (final key in allKeys) {
        if (key.startsWith('skincare_')) {
          await _sharedPreferences!.remove(key);
        }
      }
    } else {
      await _secureStorage.deleteAll();
    }
  }
  
  /// Store complex object securely
  Future<void> setObject(String key, Map<String, dynamic> value) async {
    final stringValue = jsonEncode(value);
    await setString(key, stringValue);
  }
  
  /// Get complex object from secure storage
  Future<Map<String, dynamic>?> getObject(String key) async {
    final stringValue = await getString(key);
    if (stringValue == null) return null;
    
    try {
      return jsonDecode(stringValue) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Error decoding secure object: $e');
      return null;
    }
  }
}