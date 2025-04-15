import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/onboarding_model.dart';
import '../../../providers/onboarding_provider.dart';
import '../../../utils/constants.dart';
import '../../../widgets/onboarding/onboarding_card.dart';
import '../../../widgets/onboarding/onboarding_step_widget.dart';

/// Authentication prompt step in the onboarding process
class AuthPromptStep extends OnboardingStepWidget {
  /// Creates an authentication prompt step
  const AuthPromptStep({Key? key}) : super(key: key);

  @override
  OnboardingStep get step => OnboardingStep.authPrompt;

  @override
  String getTitle(BuildContext context) => 'Create an account';

  @override
  String getSubtitle(BuildContext context) => 'Save your profile and scan history';

  @override
  bool canProceed(OnboardingProvider provider) {
    // Auth is optional
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return buildStepContent(
      context,
      Provider.of<OnboardingProvider>(context),
    );
  }

  @override
  Widget buildStepContent(BuildContext context, OnboardingProvider provider) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth > 600;
        
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white,
                AppColors.accentColor.withOpacity(0.1),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Header
              Text(
                getTitle(context),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                getSubtitle(context),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textSecondaryColor,
                ),
              ),
              const SizedBox(height: 40),
              
              // Benefits card
              OnboardingCard(
                width: isTablet ? 500 : null,
                child: Column(
                  children: [
                    Text(
                      'Why create an account?',
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    const _BenefitItem(
                      icon: Icons.history,
                      title: 'Save Scan History',
                      description: 'Access your previous scans from any device',
                    ),
                    const SizedBox(height: 16),
                    const _BenefitItem(
                      icon: Icons.recommend,
                      title: 'Personalized Recommendations',
                      description: 'Get product suggestions tailored to your skin profile',
                    ),
                    const SizedBox(height: 16),
                    const _BenefitItem(
                      icon: Icons.notifications_active,
                      title: 'Ingredient Alerts',
                      description: 'Receive notifications about new ingredient findings',
                    ),
                    const SizedBox(height: 32),
                    
                    // Auth buttons
                    ElevatedButton(
                      onPressed: () => _navigateToSignUp(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Create Account',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => _navigateToSignIn(context),
                      child: const Text('I already have an account'),
                    ),
                  ],
                ),
              ),
              
              // Skip notice
              const SizedBox(height: 40),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.arrow_forward),
                label: const Text(
                  'Continue without an account',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  /// Navigate to sign up screen
  void _navigateToSignUp(BuildContext context) {
    // In a real app, this would navigate to the sign-up screen
    // For now, just show a dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Account'),
        content: const Text('This would normally navigate to account creation.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
  
  /// Navigate to sign in screen
  void _navigateToSignIn(BuildContext context) {
    // In a real app, this would navigate to the sign-in screen
    // For now, just show a dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign In'),
        content: const Text('This would normally navigate to sign-in.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

/// Benefit item for auth prompt
class _BenefitItem extends StatelessWidget {
  /// Icon for the benefit
  final IconData icon;
  
  /// Benefit title
  final String title;
  
  /// Benefit description
  final String description;
  
  /// Creates a benefit item
  const _BenefitItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: AppColors.primaryColor,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  color: AppColors.textSecondaryColor,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}