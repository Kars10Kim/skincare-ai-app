import 'package:flutter/material.dart';

import 'accessibility.dart';

/// Animation durations
class AnimationDurations {
  /// Short animation duration
  static const Duration short = Duration(milliseconds: 150);
  
  /// Medium animation duration
  static const Duration medium = Duration(milliseconds: 300);
  
  /// Long animation duration
  static const Duration long = Duration(milliseconds: 500);
  
  /// Extra long animation duration
  static const Duration extraLong = Duration(milliseconds: 800);
  
  /// Get adjusted duration based on accessibility settings
  static Duration getAccessibleDuration(
    Duration duration,
    bool reducedMotion,
  ) {
    if (reducedMotion) {
      return const Duration(milliseconds: 0);
    }
    return duration;
  }
}

/// Animation curves
class AnimationCurves {
  /// Standard curve
  static const Curve standard = Curves.easeInOut;
  
  /// Emphasized curve
  static const Curve emphasized = Curves.easeInOutCubic;
  
  /// Decelerate curve
  static const Curve decelerate = Curves.decelerate;
  
  /// Accelerate curve
  static const Curve accelerate = Curves.ease;
  
  /// Get adjusted curve based on accessibility settings
  static Curve getAccessibleCurve(
    Curve curve,
    bool reducedMotion,
  ) {
    if (reducedMotion) {
      return Curves.linear;
    }
    return curve;
  }
}

/// Accessible animation widget
class AccessibleAnimatedWidget extends StatelessWidget {
  /// Builder for the animated widget
  final Widget Function(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) builder;
  
  /// Animation controller
  final AnimationController controller;
  
  /// Create accessible animated widget
  const AccessibleAnimatedWidget({
    Key? key,
    required this.builder,
    required this.controller,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    // Get accessibility settings
    final reducedMotion = context.reducedMotion;
    
    // If reduced motion is enabled, just show the final state
    if (reducedMotion) {
      return builder(
        context,
        _InstantAnimation(1.0),
        _InstantAnimation(0.0),
      );
    }
    
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return builder(
          context,
          controller,
          _InstantAnimation(0.0),
        );
      },
    );
  }
}

/// Fade transition with accessibility support
class AccessibleFadeTransition extends StatelessWidget {
  /// Child widget
  final Widget child;
  
  /// Opacity animation
  final Animation<double> opacity;
  
  /// Create accessible fade transition
  const AccessibleFadeTransition({
    Key? key,
    required this.child,
    required this.opacity,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    // Get accessibility settings
    final reducedMotion = context.reducedMotion;
    
    // If reduced motion is enabled, just show the child
    if (reducedMotion) {
      return Opacity(
        opacity: opacity.value,
        child: child,
      );
    }
    
    return FadeTransition(
      opacity: opacity,
      child: child,
    );
  }
}

/// Slide transition with accessibility support
class AccessibleSlideTransition extends StatelessWidget {
  /// Child widget
  final Widget child;
  
  /// Position animation
  final Animation<Offset> position;
  
  /// Create accessible slide transition
  const AccessibleSlideTransition({
    Key? key,
    required this.child,
    required this.position,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    // Get accessibility settings
    final reducedMotion = context.reducedMotion;
    
    // If reduced motion is enabled, just show the child
    if (reducedMotion) {
      return child;
    }
    
    return SlideTransition(
      position: position,
      child: child,
    );
  }
}

/// Scale transition with accessibility support
class AccessibleScaleTransition extends StatelessWidget {
  /// Child widget
  final Widget child;
  
  /// Scale animation
  final Animation<double> scale;
  
  /// Create accessible scale transition
  const AccessibleScaleTransition({
    Key? key,
    required this.child,
    required this.scale,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    // Get accessibility settings
    final reducedMotion = context.reducedMotion;
    
    // If reduced motion is enabled, just show the child
    if (reducedMotion) {
      return Transform.scale(
        scale: scale.value,
        child: child,
      );
    }
    
    return ScaleTransition(
      scale: scale,
      child: child,
    );
  }
}

/// Combination of multiple transitions with accessibility support
class AccessibleCombinedTransition extends StatelessWidget {
  /// Child widget
  final Widget child;
  
  /// Opacity animation
  final Animation<double>? opacity;
  
  /// Position animation
  final Animation<Offset>? position;
  
  /// Scale animation
  final Animation<double>? scale;
  
  /// Create accessible combined transition
  const AccessibleCombinedTransition({
    Key? key,
    required this.child,
    this.opacity,
    this.position,
    this.scale,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    // Get accessibility settings
    final reducedMotion = context.reducedMotion;
    
    Widget result = child;
    
    // Apply scale if provided
    if (scale != null) {
      if (reducedMotion) {
        result = Transform.scale(
          scale: scale!.value,
          child: result,
        );
      } else {
        result = ScaleTransition(
          scale: scale!,
          child: result,
        );
      }
    }
    
    // Apply position if provided
    if (position != null) {
      if (reducedMotion) {
        // Skip position animation in reduced motion mode
      } else {
        result = SlideTransition(
          position: position!,
          child: result,
        );
      }
    }
    
    // Apply opacity if provided
    if (opacity != null) {
      if (reducedMotion) {
        result = Opacity(
          opacity: opacity!.value,
          child: result,
        );
      } else {
        result = FadeTransition(
          opacity: opacity!,
          child: result,
        );
      }
    }
    
    return result;
  }
}

/// Page transition that respects accessibility settings
class AccessiblePageTransition extends PageRouteBuilder {
  /// Create accessible page transition
  AccessiblePageTransition({
    required Widget page,
    RouteSettings? settings,
    bool fullscreenDialog = false,
    Duration duration = const Duration(milliseconds: 300),
    Duration reverseDuration = const Duration(milliseconds: 300),
    bool fadeIn = true,
    bool slideIn = true,
    SlideDirection slideDirection = SlideDirection.fromRight,
  }) : super(
          settings: settings,
          fullscreenDialog: fullscreenDialog,
          transitionDuration: duration,
          reverseTransitionDuration: reverseDuration,
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // Get accessibility settings
            final reducedMotion = context.reducedMotion;
            
            // If reduced motion is enabled, just show the page
            if (reducedMotion) {
              return child;
            }
            
            // Create appropriate animations
            Animation<double>? opacityAnimation;
            Animation<Offset>? positionAnimation;
            
            // Opacity animation
            if (fadeIn) {
              opacityAnimation = animation.drive(
                Tween<double>(begin: 0.0, end: 1.0).chain(
                  CurveTween(curve: Curves.easeOut),
                ),
              );
            }
            
            // Position animation
            if (slideIn) {
              Offset beginOffset;
              
              switch (slideDirection) {
                case SlideDirection.fromRight:
                  beginOffset = const Offset(1.0, 0.0);
                  break;
                case SlideDirection.fromLeft:
                  beginOffset = const Offset(-1.0, 0.0);
                  break;
                case SlideDirection.fromBottom:
                  beginOffset = const Offset(0.0, 1.0);
                  break;
                case SlideDirection.fromTop:
                  beginOffset = const Offset(0.0, -1.0);
                  break;
              }
              
              positionAnimation = animation.drive(
                Tween<Offset>(begin: beginOffset, end: Offset.zero).chain(
                  CurveTween(curve: Curves.easeOut),
                ),
              );
            }
            
            return AccessibleCombinedTransition(
              opacity: opacityAnimation,
              position: positionAnimation,
              child: child,
            );
          },
        );
}

/// Slide direction
enum SlideDirection {
  /// Slide from right
  fromRight,
  
  /// Slide from left
  fromLeft,
  
  /// Slide from bottom
  fromBottom,
  
  /// Slide from top
  fromTop,
}
import 'package:flutter/material.dart';

class CustomPageTransition extends PageRouteBuilder {
  final Widget page;
  final TransitionDirection direction;

  CustomPageTransition({
    required this.page,
    this.direction = TransitionDirection.right,
  }) : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) {
            var begin = direction == TransitionDirection.right
                ? const Offset(1.0, 0.0)
                : const Offset(-1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOutCubic;

            var tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve),
            );

            return Stack(
              children: [
                SlideTransition(
                  position: animation.drive(tween),
                  child: child,
                ),
                FadeTransition(
                  opacity: animation.drive(
                    Tween(begin: 0.0, end: 1.0).chain(
                      CurveTween(curve: curve),
                    ),
                  ),
                  child: child,
                ),
              ],
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        );
}

enum TransitionDirection {
  left,
  right,
}
