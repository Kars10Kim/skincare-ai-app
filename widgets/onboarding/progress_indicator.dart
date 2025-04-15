
import 'package:flutter/material.dart';

class OnboardingProgressIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final double height;
  final Color? activeColor;
  final Color? inactiveColor;
  
  const OnboardingProgressIndicator({
    Key? key,
    required this.currentStep,
    required this.totalSteps,
    this.height = 4.0,
    this.activeColor,
    this.inactiveColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: inactiveColor ?? Colors.grey.shade200,
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = constraints.maxWidth;
          final progress = (currentStep + 1) / totalSteps;
          
          return Stack(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                width: maxWidth * progress,
                decoration: BoxDecoration(
                  color: activeColor ?? theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(height / 2),
                  boxShadow: [
                    BoxShadow(
                      color: (activeColor ?? theme.colorScheme.primary).withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
