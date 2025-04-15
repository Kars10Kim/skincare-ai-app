import 'dart:convert';
import 'dart:io';

import '../../../../core/error/exceptions.dart';
import '../../../../core/network/network_client.dart';
import '../models/user_profile_model.dart';

/// Remote data source constants
class ProfileApiEndpoints {
  /// Get user profile
  static const String getProfile = '/api/user/profile';
  
  /// Update user profile
  static const String updateProfile = '/api/user/profile';
  
  /// Update profile image
  static const String updateProfileImage = '/api/user/profile/image';
  
  /// Delete profile image
  static const String deleteProfileImage = '/api/user/profile/image';
  
  /// Delete user account
  static const String deleteAccount = '/api/user/account';
  
  /// Request account deletion verification
  static const String requestDeletionVerification = '/api/user/account/delete-verification';
  
  /// Cancel account deletion
  static const String cancelAccountDeletion = '/api/user/account/delete-cancel';
  
  /// Verify credentials
  static const String verifyCredentials = '/api/user/verify-credentials';
}

/// Profile remote data source interface
abstract class ProfileRemoteDataSource {
  /// Get user profile from server
  Future<UserProfileModel> getProfile(String userId, String authToken);
  
  /// Update user profile on server
  Future<UserProfileModel> updateProfile(UserProfileModel profile, String authToken);
  
  /// Upload profile image to server
  Future<String> updateProfileImage(String userId, File imageFile, String authToken);
  
  /// Delete profile image from server
  Future<void> deleteProfileImage(String userId, String authToken);
  
  /// Delete user account on server
  Future<void> deleteAccount(String userId, String confirmationPhrase, String authToken);
  
  /// Request account deletion verification
  Future<void> requestAccountDeletionVerification(String userId, String authToken);
  
  /// Cancel account deletion request
  Future<void> cancelAccountDeletion(String userId, String authToken);
  
  /// Verify user credentials
  Future<bool> verifyCredentials(String userId, String password, String authToken);
}

/// Profile remote data source implementation
class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  /// Network client
  final NetworkClient client;
  
  /// Create profile remote data source
  ProfileRemoteDataSourceImpl({
    required this.client,
  });
  
  @override
  Future<UserProfileModel> getProfile(String userId, String authToken) async {
    try {
      final endpoint = '${ProfileApiEndpoints.getProfile}/$userId';
      final response = await client.get(
        endpoint,
        requiresAuth: true,
        authToken: authToken,
      );
      
      return UserProfileModel.fromJson(response);
    } catch (e) {
      throw _handleException(e);
    }
  }
  
  @override
  Future<UserProfileModel> updateProfile(UserProfileModel profile, String authToken) async {
    try {
      final endpoint = '${ProfileApiEndpoints.updateProfile}/${profile.id}';
      final response = await client.put(
        endpoint,
        body: profile.toJson(),
        requiresAuth: true,
        authToken: authToken,
      );
      
      return UserProfileModel.fromJson(response);
    } catch (e) {
      throw _handleException(e);
    }
  }
  
  @override
  Future<String> updateProfileImage(String userId, File imageFile, String authToken) async {
    try {
      final endpoint = '${ProfileApiEndpoints.updateProfileImage}/$userId';
      final response = await client.multipart(
        endpoint,
        file: imageFile,
        fieldName: 'image',
        requiresAuth: true,
        authToken: authToken,
      );
      
      if (response is Map<String, dynamic> && response.containsKey('imagePath')) {
        return response['imagePath'];
      } else {
        throw const ServerException(
          message: 'Invalid response format for profile image upload',
        );
      }
    } catch (e) {
      throw _handleException(e);
    }
  }
  
  @override
  Future<void> deleteProfileImage(String userId, String authToken) async {
    try {
      final endpoint = '${ProfileApiEndpoints.deleteProfileImage}/$userId';
      await client.delete(
        endpoint,
        requiresAuth: true,
        authToken: authToken,
      );
    } catch (e) {
      throw _handleException(e);
    }
  }
  
  @override
  Future<void> deleteAccount(
    String userId,
    String confirmationPhrase,
    String authToken,
  ) async {
    try {
      final endpoint = '${ProfileApiEndpoints.deleteAccount}/$userId';
      await client.delete(
        endpoint,
        body: {
          'confirmationPhrase': confirmationPhrase,
        },
        requiresAuth: true,
        authToken: authToken,
      );
    } catch (e) {
      throw _handleException(e);
    }
  }
  
  @override
  Future<void> requestAccountDeletionVerification(
    String userId,
    String authToken,
  ) async {
    try {
      final endpoint = '${ProfileApiEndpoints.requestDeletionVerification}/$userId';
      await client.post(
        endpoint,
        requiresAuth: true,
        authToken: authToken,
      );
    } catch (e) {
      throw _handleException(e);
    }
  }
  
  @override
  Future<void> cancelAccountDeletion(String userId, String authToken) async {
    try {
      final endpoint = '${ProfileApiEndpoints.cancelAccountDeletion}/$userId';
      await client.post(
        endpoint,
        requiresAuth: true,
        authToken: authToken,
      );
    } catch (e) {
      throw _handleException(e);
    }
  }
  
  @override
  Future<bool> verifyCredentials(
    String userId,
    String password,
    String authToken,
  ) async {
    try {
      final endpoint = ProfileApiEndpoints.verifyCredentials;
      final response = await client.post(
        endpoint,
        body: {
          'userId': userId,
          'password': password,
        },
        requiresAuth: true,
        authToken: authToken,
      );
      
      if (response is Map<String, dynamic> && response.containsKey('valid')) {
        return response['valid'] == true;
      } else {
        return false;
      }
    } catch (e) {
      if (e is AuthException) {
        return false;
      }
      throw _handleException(e);
    }
  }
  
  /// Handle exceptions from API calls
  Exception _handleException(dynamic error) {
    if (error is ServerException ||
        error is NetworkException ||
        error is AuthException ||
        error is ValidationException) {
      return error;
    }
    
    if (error is SocketException) {
      return const NetworkException(
        message: 'No internet connection',
      );
    }
    
    return ServerException(
      message: error.toString(),
    );
  }
}