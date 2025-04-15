import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';

import '../../domain/entities/user_profile.dart';
import '../../domain/usecases/delete_account.dart';
import '../../domain/usecases/update_profile.dart';
import 'profile_state.dart';

/// Profile cubit for managing profile state
class ProfileCubit extends Cubit<ProfileState> {
  /// Update profile use case
  final UpdateProfile updateProfileUseCase;
  
  /// Delete account use case
  final DeleteAccount deleteAccountUseCase;
  
  /// Current profile
  UserProfile? _currentProfile;
  
  /// Get current profile
  UserProfile? get currentProfile => _currentProfile;
  
  /// Create profile cubit
  ProfileCubit({
    required this.updateProfileUseCase,
    required this.deleteAccountUseCase,
  }) : super(ProfileInitial());
  
  /// Load profile
  Future<void> loadProfile(UserProfile profile) async {
    emit(ProfileLoading());
    try {
      _currentProfile = profile;
      emit(ProfileLoaded(profile: profile));
    } catch (e) {
      emit(ProfileError(message: e.toString()));
    }
  }
  
  /// Update profile
  Future<void> updateProfile(UserProfile profile) async {
    if (state is ProfileLoaded) {
      final currentState = state as ProfileLoaded;
      emit(currentState.copyWith(isUpdating: true));
      
      final result = await updateProfileUseCase(profile);
      
      result.fold(
        (failure) => emit(ProfileError(
          message: failure.message,
          code: failure.code,
        )),
        (updatedProfile) {
          _currentProfile = updatedProfile;
          emit(ProfileLoaded(profile: updatedProfile));
        },
      );
    }
  }
  
  /// Update profile name
  Future<void> updateProfileName(String name) async {
    if (_currentProfile != null) {
      final updatedProfile = _currentProfile!.copyWith(name: name);
      await updateProfile(updatedProfile);
    }
  }
  
  /// Update profile email
  Future<void> updateProfileEmail(String email) async {
    if (_currentProfile != null) {
      final updatedProfile = _currentProfile!.copyWith(email: email);
      await updateProfile(updatedProfile);
    }
  }
  
  /// Update profile phone
  Future<void> updateProfilePhone(String phone) async {
    if (_currentProfile != null) {
      final updatedProfile = _currentProfile!.copyWith(phoneNumber: phone);
      await updateProfile(updatedProfile);
    }
  }
  
  /// Update skin type
  Future<void> updateSkinType(SkinType skinType) async {
    if (_currentProfile != null) {
      final updatedProfile = _currentProfile!.copyWith(skinType: skinType);
      await updateProfile(updatedProfile);
    }
  }
  
  /// Update age range
  Future<void> updateAgeRange(String ageRange) async {
    if (_currentProfile != null) {
      final updatedProfile = _currentProfile!.copyWith(ageRange: ageRange);
      await updateProfile(updatedProfile);
    }
  }
  
  /// Update gender
  Future<void> updateGender(String gender) async {
    if (_currentProfile != null) {
      final updatedProfile = _currentProfile!.copyWith(gender: gender);
      await updateProfile(updatedProfile);
    }
  }
  
  /// Update skin concerns
  Future<void> updateSkinConcerns(List<String> skinConcerns) async {
    if (_currentProfile != null) {
      final updatedProfile = _currentProfile!.copyWith(skinConcerns: skinConcerns);
      await updateProfile(updatedProfile);
    }
  }
  
  /// Add skin concern
  Future<void> addSkinConcern(String concern) async {
    if (_currentProfile != null) {
      final currentConcerns = List<String>.from(_currentProfile!.skinConcerns);
      if (!currentConcerns.contains(concern)) {
        currentConcerns.add(concern);
        final updatedProfile = _currentProfile!.copyWith(skinConcerns: currentConcerns);
        await updateProfile(updatedProfile);
      }
    }
  }
  
  /// Remove skin concern
  Future<void> removeSkinConcern(String concern) async {
    if (_currentProfile != null) {
      final currentConcerns = List<String>.from(_currentProfile!.skinConcerns);
      if (currentConcerns.contains(concern)) {
        currentConcerns.remove(concern);
        final updatedProfile = _currentProfile!.copyWith(skinConcerns: currentConcerns);
        await updateProfile(updatedProfile);
      }
    }
  }
  
  /// Update allergies
  Future<void> updateAllergies(List<String> allergies) async {
    if (_currentProfile != null) {
      final updatedProfile = _currentProfile!.copyWith(allergies: allergies);
      await updateProfile(updatedProfile);
    }
  }
  
  /// Add allergy
  Future<void> addAllergy(String allergy) async {
    if (_currentProfile != null) {
      final currentAllergies = List<String>.from(_currentProfile!.allergies);
      if (!currentAllergies.contains(allergy)) {
        currentAllergies.add(allergy);
        final updatedProfile = _currentProfile!.copyWith(allergies: currentAllergies);
        await updateProfile(updatedProfile);
      }
    }
  }
  
  /// Remove allergy
  Future<void> removeAllergy(String allergy) async {
    if (_currentProfile != null) {
      final currentAllergies = List<String>.from(_currentProfile!.allergies);
      if (currentAllergies.contains(allergy)) {
        currentAllergies.remove(allergy);
        final updatedProfile = _currentProfile!.copyWith(allergies: currentAllergies);
        await updateProfile(updatedProfile);
      }
    }
  }
  
  /// Update preferred ingredients
  Future<void> updatePreferredIngredients(List<String> ingredients) async {
    if (_currentProfile != null) {
      final updatedProfile = _currentProfile!.copyWith(preferredIngredients: ingredients);
      await updateProfile(updatedProfile);
    }
  }
  
  /// Add preferred ingredient
  Future<void> addPreferredIngredient(String ingredient) async {
    if (_currentProfile != null) {
      final currentIngredients = List<String>.from(_currentProfile!.preferredIngredients);
      if (!currentIngredients.contains(ingredient)) {
        currentIngredients.add(ingredient);
        final updatedProfile = _currentProfile!.copyWith(preferredIngredients: currentIngredients);
        await updateProfile(updatedProfile);
      }
    }
  }
  
  /// Remove preferred ingredient
  Future<void> removePreferredIngredient(String ingredient) async {
    if (_currentProfile != null) {
      final currentIngredients = List<String>.from(_currentProfile!.preferredIngredients);
      if (currentIngredients.contains(ingredient)) {
        currentIngredients.remove(ingredient);
        final updatedProfile = _currentProfile!.copyWith(preferredIngredients: currentIngredients);
        await updateProfile(updatedProfile);
      }
    }
  }
  
  /// Update avoided ingredients
  Future<void> updateAvoidedIngredients(List<String> ingredients) async {
    if (_currentProfile != null) {
      final updatedProfile = _currentProfile!.copyWith(avoidedIngredients: ingredients);
      await updateProfile(updatedProfile);
    }
  }
  
  /// Add avoided ingredient
  Future<void> addAvoidedIngredient(String ingredient) async {
    if (_currentProfile != null) {
      final currentIngredients = List<String>.from(_currentProfile!.avoidedIngredients);
      if (!currentIngredients.contains(ingredient)) {
        currentIngredients.add(ingredient);
        final updatedProfile = _currentProfile!.copyWith(avoidedIngredients: currentIngredients);
        await updateProfile(updatedProfile);
      }
    }
  }
  
  /// Remove avoided ingredient
  Future<void> removeAvoidedIngredient(String ingredient) async {
    if (_currentProfile != null) {
      final currentIngredients = List<String>.from(_currentProfile!.avoidedIngredients);
      if (currentIngredients.contains(ingredient)) {
        currentIngredients.remove(ingredient);
        final updatedProfile = _currentProfile!.copyWith(avoidedIngredients: currentIngredients);
        await updateProfile(updatedProfile);
      }
    }
  }
  
  /// Mark onboarding as completed
  Future<void> completeOnboarding() async {
    if (_currentProfile != null) {
      final updatedProfile = _currentProfile!.copyWith(hasCompletedOnboarding: true);
      await updateProfile(updatedProfile);
    }
  }
  
  /// Update profile image
  Future<void> updateProfileImage(File imageFile) async {
    try {
      emit(ProfileImageUploading());
      
      // Handle image upload
      // This would typically be done through a separate use case
      // For now, we'll just update the profile
      
      emit(ProfileImageUploadSuccess(imagePath: imageFile.path));
    } catch (e) {
      emit(ProfileImageUploadError(message: e.toString()));
    }
  }
  
  /// Delete account
  Future<void> deleteAccount({
    required String userId,
    required String confirmationPhrase,
    required String password,
  }) async {
    emit(AccountDeletionInProgress());
    
    final result = await deleteAccountUseCase(
      userId: userId,
      confirmationPhrase: confirmationPhrase,
      password: password,
    );
    
    result.fold(
      (failure) {
        if (failure is AccountDeletionFailure) {
          emit(AccountDeletionError(
            message: failure.message,
            reason: failure.reason,
          ));
        } else {
          emit(AccountDeletionError(
            message: failure.message,
            reason: 'unknown',
          ));
        }
      },
      (_) => emit(AccountDeletionSuccess()),
    );
  }
}