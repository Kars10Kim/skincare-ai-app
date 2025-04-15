import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/storage/hive_manager.dart';
import '../models/user_profile_model.dart';

/// Profile local data source interface
abstract class ProfileLocalDataSource {
  /// Get user profile from local storage
  Future<UserProfileModel> getProfile(String userId);
  
  /// Save user profile to local storage
  Future<void> saveProfile(UserProfileModel profile);
  
  /// Delete user profile from local storage
  Future<void> deleteProfile(String userId);
  
  /// Save profile image to local storage
  Future<String> saveProfileImage(String userId, File imageFile);
  
  /// Delete profile image from local storage
  Future<void> deleteProfileImage(String userId);
  
  /// Check if profile exists in local storage
  Future<bool> hasProfile(String userId);
  
  /// Export profile data to JSON string
  Future<String> exportProfileData(String userId);
  
  /// Clear all profile data
  Future<void> clearAllData();
}

/// Profile local data source implementation using Hive
class ProfileLocalDataSourceImpl implements ProfileLocalDataSource {
  /// Hive manager
  final HiveManager hiveManager;
  
  /// Create profile local data source
  ProfileLocalDataSourceImpl({
    required this.hiveManager,
  });
  
  @override
  Future<UserProfileModel> getProfile(String userId) async {
    try {
      final profileBox = hiveManager.userProfilesBox;
      final profile = profileBox.get(userId);
      
      if (profile == null) {
        throw const CacheException(message: 'Profile not found in cache');
      }
      
      return profile as UserProfileModel;
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException(message: e.toString());
    }
  }
  
  @override
  Future<void> saveProfile(UserProfileModel profile) async {
    try {
      final profileBox = hiveManager.userProfilesBox;
      await profileBox.put(profile.id, profile);
    } catch (e) {
      throw CacheException(message: e.toString());
    }
  }
  
  @override
  Future<void> deleteProfile(String userId) async {
    try {
      final profileBox = hiveManager.userProfilesBox;
      await profileBox.delete(userId);
      
      // Also delete profile image if it exists
      await deleteProfileImage(userId);
    } catch (e) {
      throw CacheException(message: e.toString());
    }
  }
  
  @override
  Future<String> saveProfileImage(String userId, File imageFile) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final profileImagesDir = await Directory('${directory.path}/profile_images')
          .create(recursive: true);
      
      final fileName = '$userId.jpg';
      final localImagePath = '${profileImagesDir.path}/$fileName';
      
      // Copy image file to local storage
      await imageFile.copy(localImagePath);
      
      return localImagePath;
    } catch (e) {
      throw StorageException(message: 'Failed to save profile image: ${e.toString()}');
    }
  }
  
  @override
  Future<void> deleteProfileImage(String userId) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final imagePath = '${directory.path}/profile_images/$userId.jpg';
      
      final imageFile = File(imagePath);
      if (await imageFile.exists()) {
        await imageFile.delete();
      }
    } catch (e) {
      // Ignore if file doesn't exist
      debugPrint('Error deleting profile image: $e');
    }
  }
  
  @override
  Future<bool> hasProfile(String userId) async {
    try {
      final profileBox = hiveManager.userProfilesBox;
      return profileBox.containsKey(userId);
    } catch (e) {
      return false;
    }
  }
  
  @override
  Future<String> exportProfileData(String userId) async {
    try {
      final profileBox = hiveManager.userProfilesBox;
      final profile = profileBox.get(userId);
      
      if (profile == null) {
        throw const CacheException(message: 'Profile not found for export');
      }
      
      final profileJson = (profile as UserProfileModel).toJson();
      return jsonEncode(profileJson);
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException(message: e.toString());
    }
  }
  
  @override
  Future<void> clearAllData() async {
    try {
      final profileBox = hiveManager.userProfilesBox;
      await profileBox.clear();
      
      // Also clear profile images directory
      final directory = await getApplicationDocumentsDirectory();
      final profileImagesDir = Directory('${directory.path}/profile_images');
      
      if (await profileImagesDir.exists()) {
        await profileImagesDir.delete(recursive: true);
      }
    } catch (e) {
      throw CacheException(message: e.toString());
    }
  }
}