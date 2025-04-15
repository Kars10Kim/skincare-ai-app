import 'package:flutter/material.dart';
import 'dart:ui';

/// Card widget for onboarding screens with glassmorphism effect
class OnboardingCard extends StatelessWidget {
  /// Child widget
  final Widget child;
  
  /// Card width
  final double? width;
  
  /// Card height
  final double? height;
  
  /// Background color
  final Color? backgroundColor;
  
  /// Border color
  final Color? borderColor;
  
  /// Creates an onboarding card
  const OnboardingCard({
    Key? key,
    required this.child,
    this.width,
    this.height,
    this.backgroundColor,
    this.borderColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: borderColor ?? Colors.grey.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Animated card for interactive onboarding elements
class AnimatedOnboardingCard extends StatefulWidget {
  /// Child widget
  final Widget child;
  
  /// Card width
  final double? width;
  
  /// Card height
  final double? height;
  
  /// Background color
  final Color? backgroundColor;
  
  /// Border color
  final Color? borderColor;
  
  /// On tap callback
  final VoidCallback? onTap;
  
  /// Creates an animated onboarding card
  const AnimatedOnboardingCard({
    Key? key,
    required this.child,
    this.width,
    this.height,
    this.backgroundColor,
    this.borderColor,
    this.onTap,
  }) : super(key: key);

  @override
  State<AnimatedOnboardingCard> createState() => _AnimatedOnboardingCardState();
}

class _AnimatedOnboardingCardState extends State<AnimatedOnboardingCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: widget.width,
              height: widget.height,
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: widget.backgroundColor ?? Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: widget.borderColor ?? Colors.grey.withOpacity(0.2),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: widget.child,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}