import 'dart:io';

import 'package:dartz/dartz.dart';

import '../entities/user_profile.dart';
import '../../../../core/error/failures.dart';

/// Repository for profile operations
abstract class ProfileRepository {
  /// Get user profile
  Future<Either<Failure, UserProfile>> getProfile(String userId);
  
  /// Get cached profile (for offline use)
  Future<Either<Failure, UserProfile>> getCachedProfile(String userId);
  
  /// Update user profile
  Future<Either<Failure, UserProfile>> updateProfile(UserProfile profile);
  
  /// Update profile image
  Future<Either<Failure, String>> updateProfileImage(String userId, File imageFile);
  
  /// Delete profile image
  Future<Either<Failure, Unit>> deleteProfileImage(String userId);
  
  /// Delete user account
  /// 
  /// Returns success or specific failure reason
  /// Account deletion is a staged process that may not be immediate
  Future<Either<Failure, Unit>> deleteAccount(
    String userId, 
    String confirmationPhrase,
  );
  
  /// Request account deletion verification
  Future<Either<Failure, Unit>> requestAccountDeletionVerification(String userId);
  
  /// Cancel account deletion
  Future<Either<Failure, Unit>> cancelAccountDeletion(String userId);
  
  /// Check if current credentials are valid 
  /// 
  /// Used for confirming identity before sensitive operations
  Future<Either<Failure, bool>> verifyCredentials(
    String userId, 
    String password,
  );
  
  /// Create a new profile
  Future<Either<Failure, UserProfile>> createProfile(UserProfile profile);
  
  /// Dispose any resources
  Future<void> dispose();
}