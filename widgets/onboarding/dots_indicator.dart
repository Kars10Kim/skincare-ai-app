import 'package:flutter/material.dart';

/// Indicator dots for onboarding steps
class DotsIndicator extends StatelessWidget {
  /// Current step index (0-based)
  final int currentStep;
  
  /// Total number of steps
  final int totalSteps;
  
  /// Dot size
  final double dotSize;
  
  /// Spacing between dots
  final double spacing;
  
  /// Active dot color
  final Color? activeColor;
  
  /// Inactive dot color
  final Color? inactiveColor;
  
  /// Creates a dots indicator
  const DotsIndicator({
    Key? key,
    required this.currentStep,
    required this.totalSteps,
    this.dotSize = 8.0,
    this.spacing = 8.0,
    this.activeColor,
    this.inactiveColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalSteps, (index) {
        final isActive = index == currentStep;
        
        return Container(
          width: dotSize,
          height: dotSize,
          margin: EdgeInsets.symmetric(horizontal: spacing / 2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive
                ? activeColor ?? theme.colorScheme.primary
                : inactiveColor ?? Colors.grey[300],
          ),
        );
      }),
    );
  }
}

/// Animated version of dots indicator
class AnimatedDotsIndicator extends StatelessWidget {
  /// Current step index (0-based)
  final int currentStep;
  
  /// Total number of steps
  final int totalSteps;
  
  /// Dot size
  final double dotSize;
  
  /// Spacing between dots
  final double spacing;
  
  /// Active dot color
  final Color? activeColor;
  
  /// Inactive dot color
  final Color? inactiveColor;
  
  /// Animation duration
  final Duration duration;
  
  /// Creates an animated dots indicator
  const AnimatedDotsIndicator({
    Key? key,
    required this.currentStep,
    required this.totalSteps,
    this.dotSize = 8.0,
    this.spacing = 8.0,
    this.activeColor,
    this.inactiveColor,
    this.duration = const Duration(milliseconds: 300),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalSteps, (index) {
        final isActive = index == currentStep;
        
        return AnimatedContainer(
          duration: duration,
          width: isActive ? dotSize * 2 : dotSize,
          height: dotSize,
          margin: EdgeInsets.symmetric(horizontal: spacing / 2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(dotSize / 2),
            color: isActive
                ? activeColor ?? theme.colorScheme.primary
                : inactiveColor ?? Colors.grey[300],
          ),
        );
      }),
    );
  }
}