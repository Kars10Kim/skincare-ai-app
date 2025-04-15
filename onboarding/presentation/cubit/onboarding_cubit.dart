import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/survey_config.dart';
import '../../domain/entities/survey_step.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../utils/error_handling.dart';
import 'onboarding_state.dart';

/// Cubit for managing onboarding state
class OnboardingCubit extends Cubit<OnboardingState> {
  /// Repository for profile data
  final ProfileRepository repository;
  
  /// Create an onboarding cubit
  OnboardingCubit({
    required this.repository,
  }) : super(OnboardingState.initial()) {
    // Load survey steps
    _loadSurvey();
  }
  
  /// Load survey steps
  Future<void> _loadSurvey() async {
    emit(state.copyWith(status: SurveyStatus.loading));
    
    try {
      // Add a small delay for smoother transition
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Try to load from local cache first
      final cachedSteps = await _loadSurveyFromCache();
      if (cachedSteps.isNotEmpty) {
        emit(state.copyWith(
          steps: cachedSteps,
          currentStepIndex: 0,
          status: SurveyStatus.ready,
        ));
        return;
      }
      
      // If no cached steps, load from repository
      final steps = await repository.getSurveyConfig();
      emit(state.copyWith(
        steps: steps,
        currentStepIndex: 0,
        status: SurveyStatus.ready,
      ));
      
      // Cache the steps for future use
      await _cacheSurveySteps(steps);
    } catch (e) {
      // Handle specific error types
      OnboardingError error;
      
      if (e.toString().contains('network') || e.toString().contains('connectivity')) {
        error = OnboardingError.network('Failed to connect to server: ${e.toString()}');
      } else if (e.toString().contains('storage') || e.toString().contains('permission')) {
        error = OnboardingError.storage('Cannot access storage: ${e.toString()}');
      } else if (e.toString().contains('timeout')) {
        error = OnboardingError.timeout();
      } else if (e.toString().contains('server') || e.toString().contains('500')) {
        error = OnboardingError.server('Server error: ${e.toString()}');
      } else {
        error = OnboardingError.unknown(e);
      }
      
      emit(state.copyWith(
        status: SurveyStatus.failure,
        error: error,
      ));
    }
  }
  
  /// Load survey steps from cache
  Future<List<SurveyStep>> _loadSurveyFromCache() async {
    try {
      return await repository.getCachedSurveyConfig();
    } catch (e) {
      // If there's an error loading from cache, return empty list
      return [];
    }
  }
  
  /// Cache survey steps for future use
  Future<void> _cacheSurveySteps(List<SurveyStep> steps) async {
    try {
      await repository.cacheSurveyConfig(steps);
    } catch (e) {
      // If caching fails, just log it and continue
      print('Failed to cache survey steps: $e');
    }
  }
  
  /// Move to the next step
  void nextStep() {
    if (!state.canGoNext) return;
    
    // Special handling for specific steps if needed
    final currentStep = state.currentStep;
    if (currentStep != null) {
      // Example: If we're moving from a specific step type, 
      // we could add special handling here
    }
    
    emit(state.copyWith(
      currentStepIndex: state.currentStepIndex + 1,
      status: SurveyStatus.ready,
    ));
  }
  
  /// Move to the previous step
  void previousStep() {
    if (!state.canGoPrevious) return;
    
    emit(state.copyWith(
      currentStepIndex: state.currentStepIndex - 1,
      status: SurveyStatus.ready,
    ));
  }
  
  /// Update the current step's answer
  void updateAnswer(dynamic answer) {
    emit(state.updateCurrentStepAnswer(answer));
    
    // Save the current progress to allow resuming later
    _saveProgress();
  }
  
  /// Save current progress
  Future<void> _saveProgress() async {
    try {
      await repository.cacheOnboardingProgress(state);
    } catch (e) {
      // If saving progress fails, just log it and continue
      print('Failed to save onboarding progress: $e');
    }
  }
  
  /// Skip to specific step
  void skipToStep(String stepId) {
    final stepIndex = state.steps.indexWhere((step) => step.id == stepId);
    if (stepIndex != -1) {
      emit(state.copyWith(
        currentStepIndex: stepIndex,
        status: SurveyStatus.ready,
      ));
    }
  }
  
  /// Submit the survey
  Future<void> submitSurvey() async {
    if (!state.isComplete) return;
    
    emit(state.copyWith(status: SurveyStatus.submitting));
    
    try {
      // Get profile from answers
      final profile = state.toProfile();
      
      // Save profile
      await repository.saveSkinProfile(profile);
      
      // Mark onboarding as complete
      await repository.setOnboardingComplete(true);
      
      // Clear onboarding progress
      await repository.clearOnboardingProgress();
      
      emit(state.copyWith(status: SurveyStatus.success));
    } catch (e) {
      // Handle specific submission errors
      OnboardingError error;
      
      if (e.toString().contains('network') || e.toString().contains('connectivity')) {
        error = OnboardingError.network('Failed to save profile: ${e.toString()}');
      } else if (e.toString().contains('storage') || e.toString().contains('permission')) {
        error = OnboardingError.storage('Cannot access storage to save profile: ${e.toString()}');
      } else if (e.toString().contains('timeout')) {
        error = OnboardingError.timeout();
      } else if (e.toString().contains('server') || e.toString().contains('500')) {
        error = OnboardingError.server('Server error while saving profile: ${e.toString()}');
      } else if (e.toString().contains('validation')) {
        error = OnboardingError.validation('Invalid profile data: ${e.toString()}');
      } else {
        error = OnboardingError.unknown(e);
      }
      
      emit(state.copyWith(
        status: SurveyStatus.failure,
        error: error,
      ));
    }
  }
  
  /// Reset the survey
  Future<void> resetSurvey() async {
    emit(state.copyWith(status: SurveyStatus.loading));
    
    try {
      // Clear cached data
      await repository.clearOnboardingProgress();
      
      // Reset the state and reload
      _loadSurvey();
    } catch (e) {
      emit(state.copyWith(
        status: SurveyStatus.failure,
        error: OnboardingError.unknown(e),
      ));
    }
  }
  
  /// Retry after an error
  void retry() {
    final currentStatus = state.status;
    
    emit(state.clearError());
    
    if (currentStatus == SurveyStatus.failure) {
      // If we failed while loading, try loading again
      _loadSurvey();
    } else if (currentStatus == SurveyStatus.submitting) {
      // If we failed while submitting, try submitting again
      submitSurvey();
    }
  }
}