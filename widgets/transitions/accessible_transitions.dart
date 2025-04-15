import 'package:flutter/material.dart';
import '../../utils/accessibility.dart';

/// Fade transition that respects accessibility settings
class AccessibleFadeTransition extends StatelessWidget {
  /// Child widget to render
  final Widget child;
  
  /// Animation controller (either direct or from animation object)
  final Animation<double> opacity;
  
  /// Duration for the transition, only used if disabling animations
  final Duration duration;
  
  /// Creates an accessible fade transition
  const AccessibleFadeTransition({
    Key? key,
    required this.opacity,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final accessibilitySettings = context.accessibilitySettings;
    
    // If reduced motion is enabled, don't animate
    if (accessibilitySettings.reducedMotion) {
      return child;
    }
    
    // Otherwise use normal fade transition
    return FadeTransition(
      opacity: opacity,
      child: child,
    );
  }
}

/// Slide transition that respects accessibility settings
class AccessibleSlideTransition extends StatelessWidget {
  /// Child widget to render
  final Widget child;
  
  /// Animation controller
  final Animation<Offset> position;
  
  /// Duration for the transition, only used if disabling animations
  final Duration duration;
  
  /// Creates an accessible slide transition
  const AccessibleSlideTransition({
    Key? key,
    required this.position,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final accessibilitySettings = context.accessibilitySettings;
    
    // If reduced motion is enabled, don't animate
    if (accessibilitySettings.reducedMotion) {
      return child;
    }
    
    // Otherwise use normal slide transition
    return SlideTransition(
      position: position,
      child: child,
    );
  }
}

/// Fade-in slide transition that respects accessibility settings
class FadeSlideTransition extends StatefulWidget {
  /// Child widget to render
  final Widget child;
  
  /// Whether the widget should start visible
  final bool startVisible;
  
  /// Direction of the slide
  final SlideDirection direction;
  
  /// Offset distance for slide (as fraction of widget size)
  final double slideOffset;
  
  /// Duration for the transition
  final Duration duration;
  
  /// Optional delay before animation starts
  final Duration delay;
  
  /// Creates a fade-slide transition
  const FadeSlideTransition({
    Key? key,
    required this.child,
    this.startVisible = false,
    this.direction = SlideDirection.bottomToTop,
    this.slideOffset = 0.2,
    this.duration = const Duration(milliseconds: 400),
    this.delay = Duration.zero,
  }) : super(key: key);
  
  @override
  State<FadeSlideTransition> createState() => _FadeSlideTransitionState();
}

class _FadeSlideTransitionState extends State<FadeSlideTransition>
    with SingleTickerProviderStateMixin {
  /// Animation controller
  late final AnimationController _controller;
  
  /// Fade animation
  late final Animation<double> _fadeAnimation;
  
  /// Slide animation
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    // Set up animations
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
      value: widget.startVisible ? 1.0 : 0.0,
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    
    // Determine slide direction
    final Offset beginOffset;
    switch (widget.direction) {
      case SlideDirection.bottomToTop:
        beginOffset = Offset(0, widget.slideOffset);
        break;
      case SlideDirection.topToBottom:
        beginOffset = Offset(0, -widget.slideOffset);
        break;
      case SlideDirection.rightToLeft:
        beginOffset = Offset(widget.slideOffset, 0);
        break;
      case SlideDirection.leftToRight:
        beginOffset = Offset(-widget.slideOffset, 0);
        break;
    }
    
    _slideAnimation = Tween<Offset>(
      begin: beginOffset,
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );
    
    // Start animation after delay if not starting visible
    if (!widget.startVisible && widget.delay > Duration.zero) {
      Future.delayed(widget.delay, () {
        if (mounted) {
          _controller.forward();
        }
      });
    } else if (!widget.startVisible) {
      _controller.forward();
    }
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final accessibilitySettings = context.accessibilitySettings;
    
    // If reduced motion is enabled, don't animate
    if (accessibilitySettings.reducedMotion) {
      return widget.child;
    }
    
    // Otherwise use combined animations
    return AccessibleFadeTransition(
      opacity: _fadeAnimation,
      child: AccessibleSlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}

/// Direction for the slide transition
enum SlideDirection {
  /// Slide from bottom to top
  bottomToTop,
  
  /// Slide from top to bottom
  topToBottom,
  
  /// Slide from right to left
  rightToLeft,
  
  /// Slide from left to right
  leftToRight,
}