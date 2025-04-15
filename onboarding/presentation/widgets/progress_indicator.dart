import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/onboarding_cubit.dart';
import '../cubit/onboarding_state.dart';

/// Progress indicator for a survey
class SurveyProgressIndicator extends StatelessWidget {
  /// Create a survey progress indicator
  const SurveyProgressIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnboardingCubit, OnboardingState>(
      builder: (context, state) {
        // Skip welcome and completion steps
        final step = state.currentStep;
        if (step == null || step.id == 'welcome' || step.id == 'completion') {
          return const SizedBox.shrink();
        }
        
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              // Progress indicator
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: state.completionPercentage,
                  minHeight: 8,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              
              // Step counter
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Question ${_getCurrentStepNumber(state)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                    Text(
                      'of ${_getTotalStepCount(state)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  /// Get the current step number (excluding welcome and completion)
  int _getCurrentStepNumber(OnboardingState state) {
    if (state.steps.isEmpty) return 0;
    
    // Count how many steps before the current step are not welcome or completion
    int count = 0;
    for (int i = 0; i < state.currentStepIndex; i++) {
      final step = state.steps[i];
      if (step.id != 'welcome' && step.id != 'completion') {
        count++;
      }
    }
    
    // Add 1 if the current step is not welcome or completion
    final currentStep = state.currentStep;
    if (currentStep != null && 
        currentStep.id != 'welcome' && 
        currentStep.id != 'completion') {
      count++;
    }
    
    return count;
  }
  
  /// Get the total step count (excluding welcome and completion)
  int _getTotalStepCount(OnboardingState state) {
    return state.steps.where((step) => 
        step.id != 'welcome' && step.id != 'completion').length;
  }
}