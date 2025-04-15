import 'dart:convert';
import '../../domain/entities/skin_profile.dart';
import '../../domain/entities/survey_step.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../presentation/cubit/onboarding_state.dart';
import '../datasources/local_storage_datasource.dart';
import '../datasources/remote_profile_datasource.dart';

/// Implementation of profile repository
class ProfileRepositoryImpl implements ProfileRepository {
  /// Local data source
  final LocalStorageDataSource localDataSource;
  
  /// Remote data source
  final RemoteProfileDataSource remoteDataSource;
  
  /// Cache keys
  static const String _surveyConfigCacheKey = 'survey_config_cache';
  static const String _onboardingProgressCacheKey = 'onboarding_progress_cache';
  
  /// Create a profile repository
  ProfileRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });
  
  @override
  Future<SkinProfile?> getSkinProfile() async {
    try {
      // Try to load from local storage first
      final localProfile = await localDataSource.getSkinProfile();
      if (localProfile != null) {
        return localProfile;
      }
      
      // If not found locally, try remote
      return await remoteDataSource.getSkinProfile();
    } catch (e) {
      throw ProfileLoadException('Failed to load skin profile: $e');
    }
  }
  
  @override
  Future<void> saveSkinProfile(SkinProfile profile) async {
    try {
      // Save locally
      await localDataSource.saveSkinProfile(profile);
      
      // Save remotely
      await remoteDataSource.saveSkinProfile(profile);
    } catch (e) {
      throw ProfileSaveException('Failed to save skin profile: $e');
    }
  }
  
  @override
  Future<List<SurveyStep>> getSurveyConfig() async {
    try {
      // Try to get remote survey config first
      try {
        final steps = await remoteDataSource.getSurveyConfig();
        if (steps.isNotEmpty) {
          // Cache the steps for future use
          await cacheSurveyConfig(steps);
          return steps;
        }
      } catch (e) {
        // Silently handle remote error and fall back to local
      }
      
      // Fall back to local config
      return await localDataSource.getSurveyConfig();
    } catch (e) {
      throw ProfileLoadException('Failed to load survey config: $e');
    }
  }
  
  @override
  Future<List<SurveyStep>> getCachedSurveyConfig() async {
    try {
      final cachedData = await localDataSource.getCachedData(_surveyConfigCacheKey);
      if (cachedData == null) {
        return [];
      }
      
      // Parse cached steps
      final List<dynamic> stepsJson = jsonDecode(cachedData);
      return stepsJson
          .map((stepJson) => SurveyStep.fromJson(stepJson))
          .toList();
    } catch (e) {
      throw CacheException('Failed to load cached survey config: $e');
    }
  }
  
  @override
  Future<void> cacheSurveyConfig(List<SurveyStep> steps) async {
    try {
      // Convert steps to JSON
      final stepsJson = steps.map((step) => step.toJson()).toList();
      final jsonString = jsonEncode(stepsJson);
      
      // Cache the JSON string
      await localDataSource.cacheData(_surveyConfigCacheKey, jsonString);
    } catch (e) {
      throw CacheException('Failed to cache survey config: $e');
    }
  }
  
  @override
  Future<void> cacheOnboardingProgress(OnboardingState state) async {
    try {
      // Convert state to a map for serialization
      final stateMap = {
        'currentStepIndex': state.currentStepIndex,
        'steps': state.steps.map((step) => step.toJson()).toList(),
      };
      
      // Cache the state
      await localDataSource.cacheData(
        _onboardingProgressCacheKey, 
        jsonEncode(stateMap),
      );
    } catch (e) {
      throw CacheException('Failed to cache onboarding progress: $e');
    }
  }
  
  @override
  Future<OnboardingState?> getCachedOnboardingProgress() async {
    try {
      final cachedData = await localDataSource.getCachedData(_onboardingProgressCacheKey);
      if (cachedData == null) {
        return null;
      }
      
      // Parse cached state
      final stateMap = jsonDecode(cachedData);
      final steps = (stateMap['steps'] as List)
          .map((stepJson) => SurveyStep.fromJson(stepJson))
          .toList();
          
      return OnboardingState(
        currentStepIndex: stateMap['currentStepIndex'],
        steps: steps,
        status: SurveyStatus.ready,
      );
    } catch (e) {
      throw CacheException('Failed to load cached onboarding progress: $e');
    }
  }
  
  @override
  Future<void> clearOnboardingProgress() async {
    try {
      await localDataSource.clearCachedData(_onboardingProgressCacheKey);
    } catch (e) {
      throw CacheException('Failed to clear onboarding progress: $e');
    }
  }
  
  @override
  Future<bool> hasCompletedOnboarding() async {
    try {
      // Check local storage first
      final localCompleted = await localDataSource.hasCompletedOnboarding();
      if (localCompleted) {
        return true;
      }
      
      // If not completed locally, check remote
      return await remoteDataSource.hasCompletedOnboarding();
    } catch (e) {
      // Default to not completed if there's an error
      return false;
    }
  }
  
  @override
  Future<void> setOnboardingComplete(bool completed) async {
    try {
      // Set locally
      await localDataSource.setOnboardingComplete(completed);
      
      // Set remotely
      await remoteDataSource.setOnboardingComplete(completed);
    } catch (e) {
      throw ProfileSaveException('Failed to save onboarding status: $e');
    }
  }
  
  @override
  void dispose() {
    // Dispose of any resources
    localDataSource.dispose();
    remoteDataSource.dispose();
  }
}