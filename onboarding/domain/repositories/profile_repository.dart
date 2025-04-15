import '../entities/skin_profile.dart';
import '../entities/survey_step.dart';
import '../../presentation/cubit/onboarding_state.dart';

/// Exception thrown when loading a profile fails
class ProfileLoadException implements Exception {
  /// Error message
  final String message;
  
  /// Create a profile load exception
  ProfileLoadException(this.message);
  
  @override
  String toString() => 'ProfileLoadException: $message';
}

/// Exception thrown when saving a profile fails
class ProfileSaveException implements Exception {
  /// Error message
  final String message;
  
  /// Create a profile save exception
  ProfileSaveException(this.message);
  
  @override
  String toString() => 'ProfileSaveException: $message';
}

/// Exception thrown when cache operations fail
class CacheException implements Exception {
  /// Error message
  final String message;
  
  /// Create a cache exception
  CacheException(this.message);
  
  @override
  String toString() => 'CacheException: $message';
}

/// Repository for managing user profiles
abstract class ProfileRepository {
  /// Get a user's skin profile
  Future<SkinProfile?> getSkinProfile();
  
  /// Save a user's skin profile
  Future<void> saveSkinProfile(SkinProfile profile);
  
  /// Get the configured survey steps
  Future<List<SurveyStep>> getSurveyConfig();
  
  /// Get cached survey configuration steps
  Future<List<SurveyStep>> getCachedSurveyConfig();
  
  /// Cache survey configuration steps
  Future<void> cacheSurveyConfig(List<SurveyStep> steps);
  
  /// Cache onboarding progress for resuming later
  Future<void> cacheOnboardingProgress(OnboardingState state);
  
  /// Get cached onboarding progress
  Future<OnboardingState?> getCachedOnboardingProgress();
  
  /// Clear cached onboarding progress
  Future<void> clearOnboardingProgress();
  
  /// Check if the user has completed the onboarding process
  Future<bool> hasCompletedOnboarding();
  
  /// Mark the onboarding process as completed
  Future<void> setOnboardingComplete(bool completed);
  
  /// Dispose of any resources
  void dispose();
}