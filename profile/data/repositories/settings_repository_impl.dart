import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/entities/user_preferences.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_local_datasource.dart';
import '../datasources/settings_remote_datasource.dart';
import '../models/app_settings_model.dart';
import '../models/user_preferences_model.dart';

/// Settings repository implementation
class SettingsRepositoryImpl implements SettingsRepository {
  /// Network info
  final NetworkInfo networkInfo;
  
  /// Local data source
  final SettingsLocalDataSource localDataSource;
  
  /// Remote data source
  final SettingsRemoteDataSource remoteDataSource;
  
  /// Auth token provider
  final Future<String?> Function() getAuthToken;
  
  /// Create settings repository
  SettingsRepositoryImpl({
    required this.networkInfo,
    required this.localDataSource,
    required this.remoteDataSource,
    required this.getAuthToken,
  });
  
  @override
  Future<Either<Failure, UserPreferences>> getUserPreferences(String userId) async {
    final token = await getAuthToken();
    
    if (token == null) {
      return Left(AuthFailure(message: 'Not authenticated'));
    }
    
    if (await networkInfo.isConnected) {
      try {
        final remotePreferences = await remoteDataSource.getUserPreferences(userId, token);
        
        // Cache preferences locally
        await localDataSource.saveUserPreferences(remotePreferences);
        
        return Right(remotePreferences.toEntity());
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
      return getCachedUserPreferences(userId);
    }
  }
  
  @override
  Future<Either<Failure, UserPreferences>> getCachedUserPreferences(String userId) async {
    try {
      final localPreferences = await localDataSource.getUserPreferences(userId);
      return Right(localPreferences.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, UserPreferences>> updateUserPreferences(
    String userId,
    UserPreferences preferences,
  ) async {
    final token = await getAuthToken();
    
    if (token == null) {
      return Left(AuthFailure(message: 'Not authenticated'));
    }
    
    final preferencesModel = UserPreferencesModel.fromEntity(preferences);
    
    // Always update the local cache first
    try {
      await localDataSource.saveUserPreferences(preferencesModel);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message, code: e.code));
    }
    
    // Then try to update on the server if connected
    if (await networkInfo.isConnected) {
      try {
        final updatedPreferences = await remoteDataSource.updateUserPreferences(
          userId, 
          preferencesModel, 
          token,
        );
        
        // Update cache with server response
        await localDataSource.saveUserPreferences(updatedPreferences);
        
        return Right(updatedPreferences.toEntity());
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
      // Return the locally updated preferences
      return Right(preferences);
    }
  }
  
  @override
  Future<Either<Failure, UserPreferences>> resetUserPreferences(String userId) async {
    final token = await getAuthToken();
    
    if (token == null) {
      return Left(AuthFailure(message: 'Not authenticated'));
    }
    
    // Reset preferences locally first
    try {
      final defaultPreferences = await localDataSource.resetUserPreferences(userId);
      
      // Then try to reset on the server if connected
      if (await networkInfo.isConnected) {
        try {
          final resetPreferences = await remoteDataSource.resetUserPreferences(userId, token);
          
          // Update cache with server response
          await localDataSource.saveUserPreferences(resetPreferences);
          
          return Right(resetPreferences.toEntity());
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
        // Return the locally reset preferences
        return Right(defaultPreferences.toEntity());
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, AppSettings>> getAppSettings() async {
    final token = await getAuthToken();
    
    if (token == null) {
      return Left(AuthFailure(message: 'Not authenticated'));
    }
    
    if (await networkInfo.isConnected) {
      try {
        final remoteSettings = await remoteDataSource.getAppSettings(token);
        
        // Cache settings locally
        await localDataSource.saveAppSettings(remoteSettings);
        
        return Right(remoteSettings.toEntity());
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
      return getCachedAppSettings();
    }
  }
  
  @override
  Future<Either<Failure, AppSettings>> getCachedAppSettings() async {
    try {
      final localSettings = await localDataSource.getAppSettings();
      return Right(localSettings.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, AppSettings>> updateAppSettings(AppSettings settings) async {
    final token = await getAuthToken();
    
    if (token == null) {
      return Left(AuthFailure(message: 'Not authenticated'));
    }
    
    final settingsModel = AppSettingsModel.fromEntity(settings);
    
    // Always update the local cache first
    try {
      await localDataSource.saveAppSettings(settingsModel);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message, code: e.code));
    }
    
    // Then try to update on the server if connected
    if (await networkInfo.isConnected) {
      try {
        final updatedSettings = await remoteDataSource.updateAppSettings(
          settingsModel, 
          token,
        );
        
        // Update cache with server response
        await localDataSource.saveAppSettings(updatedSettings);
        
        return Right(updatedSettings.toEntity());
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
      // Return the locally updated settings
      return Right(settings);
    }
  }
  
  @override
  Future<Either<Failure, AppSettings>> resetAppSettings() async {
    final token = await getAuthToken();
    
    if (token == null) {
      return Left(AuthFailure(message: 'Not authenticated'));
    }
    
    // Reset settings locally first
    try {
      final defaultSettings = await localDataSource.resetAppSettings();
      
      // Then try to reset on the server if connected
      if (await networkInfo.isConnected) {
        try {
          final resetSettings = await remoteDataSource.resetAppSettings(token);
          
          // Update cache with server response
          await localDataSource.saveAppSettings(resetSettings);
          
          return Right(resetSettings.toEntity());
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
        // Return the locally reset settings
        return Right(defaultSettings.toEntity());
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, UserPreferences>> toggleThemeMode(
    String userId,
    bool useDarkTheme,
    bool useSystemTheme,
  ) async {
    final token = await getAuthToken();
    
    if (token == null) {
      return Left(AuthFailure(message: 'Not authenticated'));
    }
    
    // Toggle theme mode locally first
    try {
      final updatedPreferences = await localDataSource.toggleThemeMode(
        userId, 
        useDarkTheme, 
        useSystemTheme,
      );
      
      // Then try to update on the server if connected
      if (await networkInfo.isConnected) {
        try {
          final remotePreferences = await remoteDataSource.toggleThemeMode(
            userId, 
            useDarkTheme, 
            useSystemTheme, 
            token,
          );
          
          // Update cache with server response
          await localDataSource.saveUserPreferences(remotePreferences);
          
          return Right(remotePreferences.toEntity());
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
        // Return the locally updated preferences
        return Right(updatedPreferences.toEntity());
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, UserPreferences>> toggleBiometrics(
    String userId,
    bool useBiometrics,
  ) async {
    final token = await getAuthToken();
    
    if (token == null) {
      return Left(AuthFailure(message: 'Not authenticated'));
    }
    
    // Toggle biometrics locally first
    try {
      final updatedPreferences = await localDataSource.toggleBiometrics(
        userId, 
        useBiometrics,
      );
      
      // Then try to update on the server if connected
      if (await networkInfo.isConnected) {
        try {
          final remotePreferences = await remoteDataSource.toggleBiometrics(
            userId, 
            useBiometrics, 
            token,
          );
          
          // Update cache with server response
          await localDataSource.saveUserPreferences(remotePreferences);
          
          return Right(remotePreferences.toEntity());
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
        // Return the locally updated preferences
        return Right(updatedPreferences.toEntity());
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, UserPreferences>> toggleNotifications(
    String userId,
    bool enableNotifications,
  ) async {
    final token = await getAuthToken();
    
    if (token == null) {
      return Left(AuthFailure(message: 'Not authenticated'));
    }
    
    // Toggle notifications locally first
    try {
      final updatedPreferences = await localDataSource.toggleNotifications(
        userId, 
        enableNotifications,
      );
      
      // Then try to update on the server if connected
      if (await networkInfo.isConnected) {
        try {
          final remotePreferences = await remoteDataSource.toggleNotifications(
            userId, 
            enableNotifications, 
            token,
          );
          
          // Update cache with server response
          await localDataSource.saveUserPreferences(remotePreferences);
          
          return Right(remotePreferences.toEntity());
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
        // Return the locally updated preferences
        return Right(updatedPreferences.toEntity());
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, String>> exportUserData(String userId) async {
    try {
      final jsonData = await localDataSource.exportUserPreferences(userId);
      return Right(jsonData);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, Unit>> importUserData(String userId, String jsonData) async {
    try {
      await localDataSource.importUserPreferences(userId, jsonData);
      
      // Sync with server if connected
      if (await networkInfo.isConnected) {
        final token = await getAuthToken();
        if (token != null) {
          try {
            final preferences = await localDataSource.getUserPreferences(userId);
            await remoteDataSource.updateUserPreferences(userId, preferences, token);
          } catch (e) {
            // Ignore server errors during import, local import succeeded
          }
        }
      }
      
      return const Right(unit);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(
        message: e.message, 
        field: e.field, 
        code: e.code,
      ));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, Unit>> clearLocalData(String userId) async {
    try {
      await localDataSource.clearAllData();
      return const Right(unit);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }
  
  @override
  Future<void> dispose() async {
    // No resources to dispose
  }
}