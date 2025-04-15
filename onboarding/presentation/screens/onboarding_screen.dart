import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:skincare_scanner/providers/user_provider.dart';

import '../../domain/entities/survey_config.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../utils/error_handling.dart';
import '../cubit/onboarding_cubit.dart';
import '../cubit/onboarding_state.dart';
import '../widgets/progress_indicator.dart';
import '../widgets/survey_card.dart';

/// Screen for the onboarding process
class OnboardingScreen extends StatefulWidget {
  /// Create an onboarding screen
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> with TickerProviderStateMixin {
  late AnimationController _backgroundController;
  late Animation<double> _backgroundAnimation;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize animation controller
    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    );
    
    _backgroundAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _backgroundController,
        curve: Curves.linear,
      ),
    );
    
    // Loop the animation
    _backgroundController.repeat(reverse: true);
  }
  
  @override
  void dispose() {
    _backgroundController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repository = context.read<ProfileRepository>();
    
    return BlocProvider(
      create: (context) => OnboardingCubit(repository: repository),
      child: Scaffold(
        body: BlocConsumer<OnboardingCubit, OnboardingState>(
          listenWhen: (previous, current) => 
              previous.status != current.status,
          listener: (context, state) {
            // Handle state changes
            if (state.status == SurveyStatus.success && state.isComplete) {
              // Update user provider with completed onboarding
              final userProvider = context.read<UserProvider>();
              
              if (userProvider.isAuthenticated) {
                userProvider.setSkinProfile(state.toProfile());
              }
              
              // Navigate to home screen
              Navigator.of(context).pushReplacementNamed('/home');
            } else if (state.status == SurveyStatus.failure && state.error != null) {
              // Show error recovery dialog
              state.error!.showRecoveryDialog(context).then((retry) {
                if (retry) {
                  context.read<OnboardingCubit>().retry();
                }
              });
            }
          },
          builder: (context, state) {
            // Show loading indicator
            if (state.status == SurveyStatus.loading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            
            return _buildOnboardingContent(context, state);
          },
        ),
      ),
    );
  }
  
  /// Build the onboarding content
  Widget _buildOnboardingContent(BuildContext context, OnboardingState state) {
    return Stack(
      children: [
        // Animated gradient background
        _buildAnimatedBackground(),
        
        // Onboarding content
        SafeArea(
          child: Column(
            children: [
              // Progress indicator
              Padding(
                padding: const EdgeInsets.only(top: 24),
                child: SurveyProgressIndicator(),
              ),
              
              // Survey card
              Expanded(
                child: SurveyCard(),
              ),
              
              // Navigation buttons
              _buildNavigationButtons(context, state),
            ],
          ),
        ),
      ],
    );
  }
  
  /// Build the animated background
  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _backgroundAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                HSLColor.fromAHSL(
                  1.0,
                  (_backgroundAnimation.value * 360) % 360,
                  0.6,
                  0.9,
                ).toColor(),
                HSLColor.fromAHSL(
                  1.0,
                  ((_backgroundAnimation.value * 360) + 60) % 360,
                  0.6,
                  0.9,
                ).toColor(),
              ],
              stops: const [0.0, 1.0],
              transform: GradientRotation(_backgroundAnimation.value * 3.14),
            ),
          ),
        );
      },
    );
  }
  
  /// Build the navigation buttons
  Widget _buildNavigationButtons(BuildContext context, OnboardingState state) {
    final cubit = context.read<OnboardingCubit>();
    final currentStep = state.currentStep;
    
    // Don't show buttons for initial or completion steps
    if (currentStep?.id == 'welcome') {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () => cubit.nextStep(),
            child: const Text('Get Started'),
          ),
        ),
      );
    }
    
    if (currentStep?.id == 'completion') {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () => cubit.submitSurvey(),
            child: state.status == SurveyStatus.submitting
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('Complete'),
          ),
        ),
      );
    }
    
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button
          OutlinedButton(
            onPressed: state.canGoPrevious ? () => cubit.previousStep() : null,
            child: const Text('Back'),
          ),
          
          // Next button
          FilledButton(
            onPressed: state.canGoNext ? () => cubit.nextStep() : null,
            child: const Text('Next'),
          ),
        ],
      ),
    );
  }
}