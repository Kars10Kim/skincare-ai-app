import 'package:equatable/equatable.dart';
import 'survey_step.dart';

/// Status of the survey
enum SurveyStatus {
  /// Initial state
  initial,
  
  /// Loading survey data
  loading,
  
  /// Survey loaded and ready
  ready,
  
  /// Submitting survey answers
  submitting,
  
  /// Survey completed successfully
  success,
  
  /// Survey failed to load or submit
  failure,
}

/// Configuration for the survey
class SurveyConfig extends Equatable {
  /// Survey ID
  final String id;
  
  /// Survey title
  final String title;
  
  /// Survey description
  final String description;
  
  /// Steps in the survey
  final List<SurveyStep> steps;
  
  /// Create a survey config
  const SurveyConfig({
    required this.id,
    required this.title,
    required this.description,
    required this.steps,
  });
  
  /// Create a copy with new values
  SurveyConfig copyWith({
    String? id,
    String? title,
    String? description,
    List<SurveyStep>? steps,
  }) {
    return SurveyConfig(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      steps: steps ?? this.steps,
    );
  }
  
  /// Update a step in the survey
  SurveyConfig updateStep(SurveyStep step) {
    final index = steps.indexWhere((s) => s.id == step.id);
    if (index == -1) return this;
    
    final newSteps = List<SurveyStep>.from(steps);
    newSteps[index] = step;
    
    return copyWith(steps: newSteps);
  }
  
  /// Check if the survey is complete
  bool get isComplete {
    return steps.every((step) => !step.isRequired || step.isAnswered);
  }
  
  /// Get the completion percentage
  double get completionPercentage {
    if (steps.isEmpty) return 0.0;
    
    final requiredSteps = steps.where((step) => step.isRequired).length;
    final completedSteps = steps.where((step) => 
        step.isRequired && step.isAnswered).length;
    
    if (requiredSteps == 0) return 1.0;
    return completedSteps / requiredSteps;
  }
  
  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'steps': steps.map((step) => step.toJson()).toList(),
    };
  }
  
  /// Create from JSON
  factory SurveyConfig.fromJson(Map<String, dynamic> json) {
    return SurveyConfig(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      steps: (json['steps'] as List<dynamic>)
          .map((step) => SurveyStep.fromJson(Map<String, dynamic>.from(step)))
          .toList(),
    );
  }
  
  @override
  List<Object?> get props => [id, title, description, steps];
}