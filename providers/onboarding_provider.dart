import 'package:flutter/material.dart';
import '../models/onboarding_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider for onboarding state
class OnboardingProvider extends ChangeNotifier {
  /// Current onboarding status
  OnboardingStatus _status = OnboardingStatus.notStarted;
  
  /// Current onboarding step
  OnboardingStep _currentStep = OnboardingStep.welcome;
  
  /// Onboarding data
  OnboardingData _data = OnboardingData();
  
  /// Get the current onboarding status
  OnboardingStatus get status => _status;
  
  /// Get the current onboarding step
  OnboardingStep get currentStep => _currentStep;
  
  /// Get onboarding data
  OnboardingData get data => _data;
  
  /// Initialize the provider
  Future<void> initialize() async {
    try {
      await _loadOnboardingState();
    } catch (e) {
      _status = OnboardingStatus.notStarted;
    }
    notifyListeners();
  }
  
  /// Load onboarding state from persistent storage
  Future<void> _loadOnboardingState() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Check if onboarding is completed
    final completed = prefs.getBool('onboarding_completed') ?? false;
    
    if (completed) {
      _status = OnboardingStatus.success;
      
      // Load saved preferences
      final skinTypeIndex = prefs.getInt('skin_type');
      final skinType = skinTypeIndex != null
          ? SkinType.values[skinTypeIndex]
          : null;
      
      final concernIndices = prefs.getStringList('selected_concerns') ?? [];
      final concerns = concernIndices
          .map((index) => SkinConcern.values[int.parse(index)])
          .toList();
      
      final allergens = prefs.getStringList('selected_allergens') ?? [];
      
      _data = OnboardingData(
        skinType: skinType,
        selectedConcerns: concerns,
        selectedAllergens: allergens,
      );
    } else {
      _status = OnboardingStatus.notStarted;
      _currentStep = OnboardingStep.welcome;
      _data = OnboardingData();
    }
  }
  
  /// Save onboarding state to persistent storage
  Future<void> _saveOnboardingState() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Save completion status
    await prefs.setBool('onboarding_completed', _status == OnboardingStatus.success);
    
    // Save skin type
    if (_data.skinType != null) {
      await prefs.setInt('skin_type', _data.skinType!.index);
    }
    
    // Save selected concerns
    final concernIndices = _data.selectedConcerns
        .map((concern) => concern.index.toString())
        .toList();
    await prefs.setStringList('selected_concerns', concernIndices);
    
    // Save selected allergens
    await prefs.setStringList('selected_allergens', _data.selectedAllergens);
  }
  
  /// Go to the next step
  void nextStep() {
    final steps = OnboardingStep.values;
    final currentIndex = steps.indexOf(_currentStep);
    
    if (currentIndex < steps.length - 1) {
      _currentStep = steps[currentIndex + 1];
      _status = OnboardingStatus.inProgress;
    } else {
      // Complete onboarding
      completeOnboarding();
    }
    
    notifyListeners();
  }
  
  /// Go to the previous step
  void previousStep() {
    final steps = OnboardingStep.values;
    final currentIndex = steps.indexOf(_currentStep);
    
    if (currentIndex > 0) {
      _currentStep = steps[currentIndex - 1];
    }
    
    notifyListeners();
  }
  
  /// Go to a specific step
  void goToStep(OnboardingStep step) {
    _currentStep = step;
    notifyListeners();
  }
  
  /// Set the skin type
  void setSkinType(SkinType type) {
    _data = _data.copyWith(skinType: type);
    notifyListeners();
  }
  
  /// Toggle a skin concern
  void toggleConcern(SkinConcern concern) {
    final concerns = List<SkinConcern>.from(_data.selectedConcerns);
    
    if (concerns.contains(concern)) {
      concerns.remove(concern);
    } else {
      concerns.add(concern);
    }
    
    _data = _data.copyWith(selectedConcerns: concerns);
    notifyListeners();
  }
  
  /// Check if a concern is selected
  bool isConcernSelected(SkinConcern concern) {
    return _data.selectedConcerns.contains(concern);
  }
  
  /// Toggle an allergen
  void toggleAllergen(String allergenId) {
    final allergens = List<String>.from(_data.selectedAllergens);
    
    if (allergens.contains(allergenId)) {
      allergens.remove(allergenId);
    } else {
      allergens.add(allergenId);
    }
    
    _data = _data.copyWith(selectedAllergens: allergens);
    notifyListeners();
  }
  
  /// Check if an allergen is selected
  bool isAllergenSelected(String allergenId) {
    return _data.selectedAllergens.contains(allergenId);
  }
  
  /// Complete the onboarding process
  Future<void> completeOnboarding() async {
    _status = OnboardingStatus.success;
    await _saveOnboardingState();
    notifyListeners();
  }
  
  /// Reset the onboarding process
  Future<void> resetOnboarding() async {
    _status = OnboardingStatus.notStarted;
    _currentStep = OnboardingStep.welcome;
    _data = OnboardingData();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', false);
    
    notifyListeners();
  }
}