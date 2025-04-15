import 'package:flutter/material.dart';
import '../../models/onboarding_model.dart';
import '../../providers/onboarding_provider.dart';

/// Abstract class for onboarding step widgets
abstract class OnboardingStepWidget extends StatelessWidget {
  /// Creates an onboarding step widget
  const OnboardingStepWidget({Key? key}) : super(key: key);
  
  /// Get the onboarding step this widget represents
  OnboardingStep get step;
  
  /// Get the title of this step
  String getTitle(BuildContext context);
  
  /// Get the subtitle of this step
  String getSubtitle(BuildContext context);
  
  /// Check if the user can proceed to the next step
  bool canProceed(OnboardingProvider provider) {
    return true; // Default to allowing progression
  }
  
  /// Build the content of this step
  Widget buildStepContent(BuildContext context, OnboardingProvider provider);
}