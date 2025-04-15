import 'package:equatable/equatable.dart';

import '../../domain/entities/skin_profile.dart';
import '../../domain/entities/survey_config.dart';
import '../../domain/entities/survey_step.dart';
import '../../utils/error_handling.dart';

/// Onboarding state
class OnboardingState extends Equatable {
  /// Current status of the survey
  final SurveyStatus status;
  
  /// Steps in the survey
  final List<SurveyStep> steps;
  
  /// Index of the current step
  final int currentStepIndex;
  
  /// Error that occurred
  final OnboardingError? error;
  
  /// Create an onboarding state
  const OnboardingState({
    this.status = SurveyStatus.initial,
    this.steps = const [],
    this.currentStepIndex = 0,
    this.error,
  });
  
  /// Create initial state
  factory OnboardingState.initial() {
    return const OnboardingState();
  }
  
  /// Get the current step
  SurveyStep? get currentStep => 
      steps.isNotEmpty && currentStepIndex < steps.length
          ? steps[currentStepIndex]
          : null;
  
  /// Check if can go to previous step
  bool get canGoPrevious => currentStepIndex > 0;
  
  /// Check if can go to next step
  bool get canGoNext {
    if (currentStepIndex >= steps.length - 1) return false;
    
    final step = currentStep;
    // Allow going to next step if current step is not required
    // or has been answered
    if (step == null) return false;
    
    return !step.isRequired || step.isAnswered;
  }
  
  /// Check if all required steps are answered
  bool get isComplete {
    return steps.every((step) => !step.isRequired || step.isAnswered);
  }
  
  /// Get the completion percentage
  double get completionPercentage {
    if (steps.isEmpty) return 0.0;
    
    // Skip welcome and completion steps for percentage calculation
    final relevantSteps = steps.where((step) => 
        step.id != 'welcome' && step.id != 'completion' && step.isRequired).toList();
        
    if (relevantSteps.isEmpty) return 0.0;
    
    final completedSteps = relevantSteps.where((step) => step.isAnswered).length;
    return completedSteps / relevantSteps.length;
  }
  
  /// Create a copy with new values
  OnboardingState copyWith({
    SurveyStatus? status,
    List<SurveyStep>? steps,
    int? currentStepIndex,
    OnboardingError? error,
  }) {
    return OnboardingState(
      status: status ?? this.status,
      steps: steps ?? this.steps,
      currentStepIndex: currentStepIndex ?? this.currentStepIndex,
      error: error ?? this.error,
    );
  }
  
  /// Clear error
  OnboardingState clearError() {
    return copyWith(error: null);
  }
  
  /// Update current step with an answer
  OnboardingState updateCurrentStepAnswer(dynamic answer) {
    if (currentStep == null) return this;
    
    final updatedSteps = List<SurveyStep>.from(steps);
    updatedSteps[currentStepIndex] = currentStep!.withAnswer(answer);
    
    return copyWith(
      steps: updatedSteps,
      status: SurveyStatus.ready,
    );
  }
  
  /// Convert survey answers to a skin profile
  SkinProfile toProfile() {
    // Find answers for each step
    final skinTypeStep = steps.firstWhere(
      (step) => step.id == 'skin_type',
      orElse: () => const SurveyStep(
        id: 'skin_type',
        title: '',
        description: '',
        answerType: AnswerType.singleChoice,
      ),
    );
    
    final sensitivityStep = steps.firstWhere(
      (step) => step.id == 'sensitivity',
      orElse: () => const SurveyStep(
        id: 'sensitivity',
        title: '',
        description: '',
        answerType: AnswerType.singleChoice,
      ),
    );
    
    final climateStep = steps.firstWhere(
      (step) => step.id == 'climate',
      orElse: () => const SurveyStep(
        id: 'climate',
        title: '',
        description: '',
        answerType: AnswerType.singleChoice,
      ),
    );
    
    final concernsStep = steps.firstWhere(
      (step) => step.id == 'concerns',
      orElse: () => const SurveyStep(
        id: 'concerns',
        title: '',
        description: '',
        answerType: AnswerType.multipleChoice,
      ),
    );
    
    final allergiesStep = steps.firstWhere(
      (step) => step.id == 'allergies',
      orElse: () => const SurveyStep(
        id: 'allergies',
        title: '',
        description: '',
        answerType: AnswerType.multipleChoice,
      ),
    );
    
    final notesStep = steps.firstWhere(
      (step) => step.id == 'notes',
      orElse: () => const SurveyStep(
        id: 'notes',
        title: '',
        description: '',
        answerType: AnswerType.text,
      ),
    );
    
    // Map answers to profile
    final skinType = skinTypeStep.answer != null
        ? SkinType.fromString(skinTypeStep.answer)
        : SkinType.normal;
        
    final sensitivityLevel = sensitivityStep.answer != null
        ? SensitivityLevel.fromString(sensitivityStep.answer)
        : SensitivityLevel.none;
        
    final climate = climateStep.answer != null
        ? Climate.fromString(climateStep.answer)
        : Climate.temperate;
        
    final concerns = concernsStep.answer is List
        ? (concernsStep.answer as List)
            .map((concern) => SkinConcern.fromString(concern))
            .toList()
        : <SkinConcern>[];
            
    final allergies = allergiesStep.answer is List
        ? (allergiesStep.answer as List)
            .map((allergy) => KnownAllergy.fromString(allergy))
            .toList()
        : <KnownAllergy>[];
            
    final notes = notesStep.answer is String
        ? notesStep.answer
        : null;
    
    return SkinProfile(
      skinType: skinType,
      sensitivityLevel: sensitivityLevel,
      climate: climate,
      concerns: concerns,
      allergies: allergies,
      notes: notes,
    );
  }
  
  @override
  List<Object?> get props => [
    status,
    steps,
    currentStepIndex,
    error,
  ];
}