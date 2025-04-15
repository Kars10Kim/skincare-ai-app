
import 'package:flutter/material.dart';
import '../../../models/onboarding_model.dart';
import '../../../providers/onboarding_provider.dart';
import '../../../utils/constants.dart';
import '../../../utils/animations.dart';
import '../../../widgets/onboarding/onboarding_card.dart';
import '../../../widgets/onboarding/onboarding_step_widget.dart';

class WelcomeStep extends OnboardingStepWidget {
  const WelcomeStep({Key? key}) : super(key: key);

  @override
  OnboardingStep get step => OnboardingStep.welcome;

  @override
  String getTitle(BuildContext context) => 'Welcome!';

  @override
  String getSubtitle(BuildContext context) => 'Let\'s create your personalized skincare profile';

  @override
  Widget build(BuildContext context) {
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
                AppColors.primaryColor.withOpacity(0.1),
                Colors.white.withOpacity(0.95),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              
              // Animated app icon
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 800),
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Container(
                      width: isTablet ? 180 : 140,
                      height: isTablet ? 180 : 140,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(40),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryColor.withOpacity(0.2),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.spa_outlined,
                        color: AppColors.primaryColor,
                        size: 80,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 40),
              
              // Title with fade animation
              FadeTransition(
                opacity: _getDelayedAnimation(context, 0.3),
                child: Text(
                  'Skincare Scanner',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Welcome card with features
              SlideTransition(
                position: _getSlideAnimation(context),
                child: OnboardingCard(
                  width: isTablet ? 500 : null,
                  child: Column(
                    children: [
                      Text(
                        'Your Personal Skincare Assistant',
                        style: Theme.of(context).textTheme.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'We\'ll help you analyze product ingredients, detect conflicts, and recommend products that work best for your unique skin.',
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildFeatureItem(
                            icon: Icons.document_scanner_outlined,
                            label: 'Scan Products',
                            delay: 0.4,
                          ),
                          _buildFeatureItem(
                            icon: Icons.warning_amber_outlined,
                            label: 'Detect Conflicts',
                            delay: 0.6,
                          ),
                          _buildFeatureItem(
                            icon: Icons.recommend_outlined,
                            label: 'Get Recommendations',
                            delay: 0.8,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              const Spacer(flex: 2),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String label,
    required double delay,
  }) {
    return FadeTransition(
      opacity: _getDelayedAnimation(context, delay),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primaryColor.withOpacity(0.2),
                width: 2,
              ),
            ),
            child: Icon(
              icon,
              color: AppColors.primaryColor,
              size: 32,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Animation<double> _getDelayedAnimation(BuildContext context, double delay) {
    return CurvedAnimation(
      parent: ModalRoute.of(context)!.animation!,
      curve: Interval(delay, 1.0, curve: Curves.easeOut),
    );
  }

  Animation<Offset> _getSlideAnimation(BuildContext context) {
    return Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: ModalRoute.of(context)!.animation!,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
      ),
    );
  }
}
