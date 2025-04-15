import 'dart:io';

import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_local_datasource.dart';
import '../datasources/profile_remote_datasource.dart';
import '../models/user_profile_model.dart';

/// Profile repository implementation
class ProfileRepositoryImpl implements ProfileRepository {
  /// Network info
  final NetworkInfo networkInfo;
  
  /// Local data source
  final ProfileLocalDataSource localDataSource;
  
  /// Remote data source
  final ProfileRemoteDataSource remoteDataSource;
  
  /// Auth token provider
  final Future<String?> Function() getAuthToken;
  
  /// Create profile repository
  ProfileRepositoryImpl({
    required this.networkInfo,
    required this.localDataSource,
    required this.remoteDataSource,
    required this.getAuthToken,
  });
  
  @override
  Future<Either<Failure, UserProfile>> getProfile(String userId) async {
    final token = await getAuthToken();
    
    if (token == null) {
      return Left(AuthFailure(message: 'Not authenticated'));
    }
    
    if (await networkInfo.isConnected) {
      try {
        final remoteProfile = await remoteDataSource.getProfile(userId, token);
        
        // Cache the profile locally
        await localDataSource.saveProfile(remoteProfile);
        
        return Right(remoteProfile.toEntity());
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message, code: e.code));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(message: e.message, code: e.code));
      } on AuthException catch (e) {
        return Left(AuthFailure(message: e.message, code: e.code));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      // No internet connection, try to get from cache
      return getCachedProfile(userId);
    }
  }
  
  @override
  Future<Either<Failure, UserProfile>> getCachedProfile(String userId) async {
    try {
      final localProfile = await localDataSource.getProfile(userId);
      return Right(localProfile.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, UserProfile>> updateProfile(UserProfile profile) async {
    final token = await getAuthToken();
    
    if (token == null) {
      return Left(AuthFailure(message: 'Not authenticated'));
    }
    
    final profileModel = UserProfileModel.fromEntity(profile);
    
    // Always update the local cache first
    try {
      await localDataSource.saveProfile(profileModel);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message, code: e.code));
    }
    
    // Then try to update on the server if connected
    if (await networkInfo.isConnected) {
      try {
        final updatedProfile = await remoteDataSource.updateProfile(profileModel, token);
        
        // Update cache with server response
        await localDataSource.saveProfile(updatedProfile);
        
        return Right(updatedProfile.toEntity());
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message, code: e.code));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(message: e.message, code: e.code));
      } on AuthException catch (e) {
        return Left(AuthFailure(message: e.message, code: e.code));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      // Return the locally updated profile
      return Right(profile);
    }
  }
  
  @override
  Future<Either<Failure, String>> updateProfileImage(String userId, File imageFile) async {
    final token = await getAuthToken();
    
    if (token == null) {
      return Left(AuthFailure(message: 'Not authenticated'));
    }
    
    // First save the image locally
    try {
      final localImagePath = await localDataSource.saveProfileImage(userId, imageFile);
      
      // Then try to upload to the server if connected
      if (await networkInfo.isConnected) {
        try {
          final remoteImagePath = await remoteDataSource.updateProfileImage(
            userId, 
            imageFile, 
            token,
          );
          
          // Get the current profile
          final profileResult = await getProfile(userId);
          
          if (profileResult.isRight()) {
            final profile = profileResult.getOrElse(() => UserProfile.empty(userId));
            
            // Update the profile with the new image path
            final updatedProfile = profile.copyWith(
              profileImagePath: remoteImagePath,
            );
            
            // Save the updated profile
            await updateProfile(updatedProfile);
          }
          
          return Right(remoteImagePath);
        } on ServerException catch (e) {
          return Left(ServerFailure(message: e.message, code: e.code));
        } on NetworkException catch (e) {
          return Left(NetworkFailure(message: e.message, code: e.code));
        } on AuthException catch (e) {
          return Left(AuthFailure(message: e.message, code: e.code));
        } catch (e) {
          return Left(ServerFailure(message: e.toString()));
        }
      } else {
        // Return the local image path
        return Right(localImagePath);
      }
    } on StorageException catch (e) {
      return Left(StorageFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(StorageFailure(message: e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, Unit>> deleteProfileImage(String userId) async {
    final token = await getAuthToken();
    
    if (token == null) {
      return Left(AuthFailure(message: 'Not authenticated'));
    }
    
    // Delete the image locally
    try {
      await localDataSource.deleteProfileImage(userId);
      
      // Get the current profile
      final profileResult = await getProfile(userId);
      
      if (profileResult.isRight()) {
        final profile = profileResult.getOrElse(() => UserProfile.empty(userId));
        
        // Update the profile with null image path
        final updatedProfile = profile.copyWith(
          profileImagePath: null,
        );
        
        // Save the updated profile
        await updateProfile(updatedProfile);
      }
      
      // Then try to delete on the server if connected
      if (await networkInfo.isConnected) {
        try {
          await remoteDataSource.deleteProfileImage(userId, token);
          return const Right(unit);
        } on ServerException catch (e) {
          return Left(ServerFailure(message: e.message, code: e.code));
        } on NetworkException catch (e) {
          return Left(NetworkFailure(message: e.message, code: e.code));
        } on AuthException catch (e) {
          return Left(AuthFailure(message: e.message, code: e.code));
        } catch (e) {
          return Left(ServerFailure(message: e.toString()));
        }
      } else {
        // Return success for local deletion
        return const Right(unit);
      }
    } catch (e) {
      return Left(StorageFailure(message: e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, Unit>> deleteAccount(
    String userId,
    String confirmationPhrase,
  ) async {
    final token = await getAuthToken();
    
    if (token == null) {
      return Left(AuthFailure(message: 'Not authenticated'));
    }
    
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.deleteAccount(userId, confirmationPhrase, token);
        
        // Delete local data
        await localDataSource.deleteProfile(userId);
        
        return const Right(unit);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message, code: e.code));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(message: e.message, code: e.code));
      } on AuthException catch (e) {
        return Left(AuthFailure(message: e.message, code: e.code));
      } on AccountDeletionException catch (e) {
        return Left(AccountDeletionFailure(
          message: e.message,
          reason: e.reason,
          code: e.code,
        ));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return Left(NetworkFailure(
        message: 'Internet connection required to delete account',
      ));
    }
  }
  
  @override
  Future<Either<Failure, Unit>> requestAccountDeletionVerification(String userId) async {
    final token = await getAuthToken();
    
    if (token == null) {
      return Left(AuthFailure(message: 'Not authenticated'));
    }
    
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.requestAccountDeletionVerification(userId, token);
        return const Right(unit);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message, code: e.code));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(message: e.message, code: e.code));
      } on AuthException catch (e) {
        return Left(AuthFailure(message: e.message, code: e.code));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return Left(NetworkFailure(
        message: 'Internet connection required to request verification',
      ));
    }
  }
  
  @override
  Future<Either<Failure, Unit>> cancelAccountDeletion(String userId) async {
    final token = await getAuthToken();
    
    if (token == null) {
      return Left(AuthFailure(message: 'Not authenticated'));
    }
    
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.cancelAccountDeletion(userId, token);
        return const Right(unit);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message, code: e.code));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(message: e.message, code: e.code));
      } on AuthException catch (e) {
        return Left(AuthFailure(message: e.message, code: e.code));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return Left(NetworkFailure(
        message: 'Internet connection required to cancel account deletion',
      ));
    }
  }
  
  @override
  Future<Either<Failure, bool>> verifyCredentials(
    String userId,
    String password,
  ) async {
    final token = await getAuthToken();
    
    if (token == null) {
      return Left(AuthFailure(message: 'Not authenticated'));
    }
    
    if (await networkInfo.isConnected) {
      try {
        final isValid = await remoteDataSource.verifyCredentials(
          userId,
          password,
          token,
        );
        return Right(isValid);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message, code: e.code));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(message: e.message, code: e.code));
      } on AuthException catch (e) {
        return Left(AuthFailure(message: e.message, code: e.code));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return Left(NetworkFailure(
        message: 'Internet connection required to verify credentials',
      ));
    }
  }
  
  @override
  Future<Either<Failure, UserProfile>> createProfile(UserProfile profile) async {
    final token = await getAuthToken();
    
    if (token == null) {
      return Left(AuthFailure(message: 'Not authenticated'));
    }
    
    final profileModel = UserProfileModel.fromEntity(profile);
    
    // Always save locally first
    try {
      await localDataSource.saveProfile(profileModel);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message, code: e.code));
    }
    
    // Then try to create on the server if connected
    if (await networkInfo.isConnected) {
      try {
        final createdProfile = await remoteDataSource.updateProfile(profileModel, token);
        
        // Update cache with server response
        await localDataSource.saveProfile(createdProfile);
        
        return Right(createdProfile.toEntity());
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message, code: e.code));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(message: e.message, code: e.code));
      } on AuthException catch (e) {
        return Left(AuthFailure(message: e.message, code: e.code));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      // Return the locally created profile
      return Right(profile);
    }
  }
  
  @override
  Future<void> dispose() async {
    // No resources to dispose
  }
}