import 'package:flutter/material.dart';

import '../../utils/animations.dart';
import '../../utils/accessibility.dart';

/// Widget to display content with standardized page transitions
class PageTransition extends StatelessWidget {
  /// Child to animate
  final Widget child;
  
  /// Animation type
  final PageTransitionType type;
  
  /// Animation duration
  final Duration? duration;
  
  /// Animation curve
  final Curve? curve;
  
  /// Whether the animation is reversed
  final bool reverse;
  
  /// Create a page transition
  const PageTransition({
    Key? key,
    required this.child,
    this.type = PageTransitionType.fade,
    this.duration,
    this.curve,
    this.reverse = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Check if reduced motion is enabled through the accessibility manager
    final accessibilityManager = AccessibilityManager();
    final Duration animDuration = accessibilityManager.getAnimationDuration(
      duration ?? AppAnimations.pageTransitionDuration,
    );
    
    // If reduced motion enabled and duration is now zero, just return the child
    if (animDuration == Duration.zero) {
      return child;
    }
    
    // Apply the appropriate transition
    switch (type) {
      case PageTransitionType.fade:
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: const AlwaysStoppedAnimation(1.0),
            curve: curve ?? AppAnimations.standardCurve,
          ),
          child: child,
        );
      
      case PageTransitionType.rightToLeft:
        return SlideTransition(
          position: Tween<Offset>(
            begin: Offset(reverse ? -1.0 : 1.0, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: const AlwaysStoppedAnimation(1.0),
            curve: curve ?? AppAnimations.standardCurve,
          )),
          child: child,
        );
      
      case PageTransitionType.leftToRight:
        return SlideTransition(
          position: Tween<Offset>(
            begin: Offset(reverse ? 1.0 : -1.0, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: const AlwaysStoppedAnimation(1.0),
            curve: curve ?? AppAnimations.standardCurve,
          )),
          child: child,
        );
      
      case PageTransitionType.topToBottom:
        return SlideTransition(
          position: Tween<Offset>(
            begin: Offset(0.0, reverse ? 1.0 : -1.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: const AlwaysStoppedAnimation(1.0),
            curve: curve ?? AppAnimations.standardCurve,
          )),
          child: child,
        );
      
      case PageTransitionType.bottomToTop:
        return SlideTransition(
          position: Tween<Offset>(
            begin: Offset(0.0, reverse ? -1.0 : 1.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: const AlwaysStoppedAnimation(1.0),
            curve: curve ?? AppAnimations.standardCurve,
          )),
          child: child,
        );
      
      case PageTransitionType.scale:
        return ScaleTransition(
          scale: Tween<double>(
            begin: reverse ? 1.1 : 0.9,
            end: 1.0,
          ).animate(CurvedAnimation(
            parent: const AlwaysStoppedAnimation(1.0),
            curve: curve ?? AppAnimations.standardCurve,
          )),
          child: child,
        );
      
      case PageTransitionType.rotate:
        return AnimatedBuilder(
          animation: const AlwaysStoppedAnimation(1.0),
          builder: (context, child) {
            return Transform.rotate(
              angle: 0.0, // No rotation in static builds
              child: child,
            );
          },
          child: child,
        );
      
      case PageTransitionType.size:
        return AnimatedBuilder(
          animation: const AlwaysStoppedAnimation(1.0),
          builder: (context, child) {
            return ClipRect(
              child: Align(
                alignment: Alignment.center,
                heightFactor: 1.0,
                widthFactor: 1.0,
                child: child,
              ),
            );
          },
          child: child,
        );
    }
  }
}

/// Static route generator with standardized transitions
class AppPageRoute<T> extends PageRouteBuilder<T> {
  /// Create a page route with standardized transitions
  AppPageRoute({
    required Widget page,
    required RouteSettings settings,
    PageTransitionType transitionType = PageTransitionType.fade,
    Duration? duration,
    Curve? curve,
    bool fullscreenDialog = false,
  }) : super(
          settings: settings,
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: 
              AccessibilityManager().getAnimationDuration(
                duration ?? AppAnimations.pageTransitionDuration,
              ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: curve ?? AppAnimations.standardCurve,
            );
            
            switch (transitionType) {
              case PageTransitionType.fade:
                return FadeTransition(
                  opacity: curvedAnimation,
                  child: child,
                );
              
              case PageTransitionType.rightToLeft:
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(1.0, 0.0),
                    end: Offset.zero,
                  ).animate(curvedAnimation),
                  child: child,
                );
              
              case PageTransitionType.leftToRight:
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(-1.0, 0.0),
                    end: Offset.zero,
                  ).animate(curvedAnimation),
                  child: child,
                );
              
              case PageTransitionType.topToBottom:
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.0, -1.0),
                    end: Offset.zero,
                  ).animate(curvedAnimation),
                  child: child,
                );
              
              case PageTransitionType.bottomToTop:
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.0, 1.0),
                    end: Offset.zero,
                  ).animate(curvedAnimation),
                  child: child,
                );
              
              case PageTransitionType.scale:
                return ScaleTransition(
                  scale: Tween<double>(
                    begin: 0.9,
                    end: 1.0,
                  ).animate(curvedAnimation),
                  child: child,
                );
              
              case PageTransitionType.rotate:
                return RotationTransition(
                  turns: Tween<double>(
                    begin: 0.1,
                    end: 0.0,
                  ).animate(curvedAnimation),
                  child: child,
                );
              
              case PageTransitionType.size:
                return SizeTransition(
                  sizeFactor: curvedAnimation,
                  child: child,
                );
            }
          },
          fullscreenDialog: fullscreenDialog,
        );
}

/// Types of page transitions
enum PageTransitionType {
  /// Fade transition
  fade,
  
  /// Slide from right to left
  rightToLeft,
  
  /// Slide from left to right
  leftToRight,
  
  /// Slide from top to bottom
  topToBottom,
  
  /// Slide from bottom to top
  bottomToTop,
  
  /// Scale transition
  scale,
  
  /// Rotate transition
  rotate,
  
  /// Size transition
  size,
}

/// Widget that animates its children with a staggered effect
class StaggeredAnimations extends StatefulWidget {
  /// Child widgets to animate
  final List<Widget> children;
  
  /// Delay between each animation
  final Duration delay;
  
  /// Duration of each animation
  final Duration duration;
  
  /// Animation curve
  final Curve curve;
  
  /// Whether to offset children
  final bool offset;
  
  /// Whether to fade in children
  final bool fadeIn;
  
  /// Whether to scale children
  final bool scale;
  
  /// Direction of entrance
  final SlideDirection direction;
  
  /// Create staggered animations
  const StaggeredAnimations({
    Key? key,
    required this.children,
    this.delay = const Duration(milliseconds: 50),
    this.duration = const Duration(milliseconds: 250),
    this.curve = Curves.easeOut,
    this.offset = true,
    this.fadeIn = true,
    this.scale = false,
    this.direction = SlideDirection.up,
  }) : super(key: key);

  @override
  State<StaggeredAnimations> createState() => _StaggeredAnimationsState();
}

class _StaggeredAnimationsState extends State<StaggeredAnimations>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  List<Animation<double>>? _animations;
  
  @override
  void initState() {
    super.initState();
    
    // Check if reduced motion is enabled
    final accessibilityManager = AccessibilityManager();
    final Duration animDuration = accessibilityManager.getAnimationDuration(
      widget.duration,
    );
    
    // Create controller
    _controller = AnimationController(
      vsync: this,
      duration: animDuration + (widget.delay * (widget.children.length - 1)),
    );
    
    // Create animations for each child
    _createAnimations();
    
    // Start animation
    _controller.forward();
  }
  
  @override
  void didUpdateWidget(StaggeredAnimations oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // If the number of children changed, recreate animations
    if (widget.children.length != oldWidget.children.length ||
        widget.delay != oldWidget.delay ||
        widget.duration != oldWidget.duration ||
        widget.curve != oldWidget.curve) {
      _createAnimations();
      _controller.forward(from: 0.0);
    }
  }
  
  void _createAnimations() {
    // Create animations for each child
    _animations = List.generate(widget.children.length, (index) {
      final double startTime = index * widget.delay.inMilliseconds /
          (_controller.duration?.inMilliseconds ?? 1);
      final double endTime = startTime +
          widget.duration.inMilliseconds /
              (_controller.duration?.inMilliseconds ?? 1);
      
      return Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: _controller,
        curve: Interval(
          startTime.clamp(0.0, 1.0),
          endTime.clamp(0.0, 1.0),
          curve: widget.curve,
        ),
      ));
    });
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Check if reduced motion is enabled
    final accessibilityManager = AccessibilityManager();
    final reduceMotion = accessibilityManager.reducedMotionEnabled;
    
    // If reduced motion is enabled, just return the children
    if (reduceMotion) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: widget.children,
      );
    }
    
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: List.generate(widget.children.length, (index) {
            final animation = _animations?[index] ?? const AlwaysStoppedAnimation(1.0);
            
            return _buildAnimatedChild(
              child: widget.children[index],
              animation: animation,
            );
          }),
        );
      },
    );
  }
  
  Widget _buildAnimatedChild({
    required Widget child,
    required Animation<double> animation,
  }) {
    // Apply animations according to settings
    Widget animatedChild = child;
    
    if (widget.fadeIn) {
      animatedChild = Opacity(
        opacity: animation.value,
        child: animatedChild,
      );
    }
    
    if (widget.scale) {
      animatedChild = Transform.scale(
        scale: Tween<double>(begin: 0.8, end: 1.0).evaluate(animation),
        child: animatedChild,
      );
    }
    
    if (widget.offset) {
      double dx = 0.0;
      double dy = 0.0;
      
      switch (widget.direction) {
        case SlideDirection.right:
          dx = Tween<double>(begin: -20.0, end: 0.0).evaluate(animation);
          break;
        case SlideDirection.left:
          dx = Tween<double>(begin: 20.0, end: 0.0).evaluate(animation);
          break;
        case SlideDirection.up:
          dy = Tween<double>(begin: 20.0, end: 0.0).evaluate(animation);
          break;
        case SlideDirection.down:
          dy = Tween<double>(begin: -20.0, end: 0.0).evaluate(animation);
          break;
      }
      
      animatedChild = Transform.translate(
        offset: Offset(dx, dy),
        child: animatedChild,
      );
    }
    
    return animatedChild;
  }
}

/// Widget to show/hide content with animated transitions
class AnimatedVisibility extends StatefulWidget {
  /// Whether the child is visible
  final bool visible;
  
  /// Child widget
  final Widget child;
  
  /// Duration of the animation
  final Duration? duration;
  
  /// Animation curve
  final Curve? curve;
  
  /// How to maintain the state of the child
  final AnimatedVisibilityMode mode;
  
  /// Create animated visibility
  const AnimatedVisibility({
    Key? key,
    required this.visible,
    required this.child,
    this.duration,
    this.curve,
    this.mode = AnimatedVisibilityMode.fade,
  }) : super(key: key);

  @override
  State<AnimatedVisibility> createState() => _AnimatedVisibilityState();
}

class _AnimatedVisibilityState extends State<AnimatedVisibility>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  
  @override
  void initState() {
    super.initState();
    
    // Check if reduced motion is enabled
    final accessibilityManager = AccessibilityManager();
    final Duration animDuration = accessibilityManager.getAnimationDuration(
      widget.duration ?? AppAnimations.contentTransitionDuration,
    );
    
    _controller = AnimationController(
      vsync: this,
      duration: animDuration,
      value: widget.visible ? 1.0 : 0.0,
    );
    
    _animation = CurvedAnimation(
      parent: _controller,
      curve: widget.curve ?? AppAnimations.standardCurve,
    );
    
    // Update animation if the visibility changes
    if (widget.visible) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }
  
  @override
  void didUpdateWidget(AnimatedVisibility oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Update animation if the visibility changes
    if (widget.visible != oldWidget.visible) {
      if (widget.visible) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // If reduced motion is enabled, just show/hide immediately
    final accessibilityManager = AccessibilityManager();
    final reduceMotion = accessibilityManager.reducedMotionEnabled;
    
    if (reduceMotion) {
      return widget.visible ? widget.child : const SizedBox.shrink();
    }
    
    switch (widget.mode) {
      case AnimatedVisibilityMode.fade:
        return FadeTransition(
          opacity: _animation,
          child: widget.child,
        );
      
      case AnimatedVisibilityMode.size:
        return SizeTransition(
          sizeFactor: _animation,
          child: widget.child,
        );
      
      case AnimatedVisibilityMode.scale:
        return ScaleTransition(
          scale: _animation,
          child: widget.child,
        );
      
      case AnimatedVisibilityMode.slide:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, 1.0),
            end: Offset.zero,
          ).animate(_animation),
          child: FadeTransition(
            opacity: _animation,
            child: widget.child,
          ),
        );
      
      case AnimatedVisibilityMode.combined:
        return FadeTransition(
          opacity: _animation,
          child: SizeTransition(
            sizeFactor: _animation,
            child: widget.child,
          ),
        );
    }
  }
}

/// Modes for animated visibility
enum AnimatedVisibilityMode {
  /// Fade in/out
  fade,
  
  /// Size in/out
  size,
  
  /// Scale in/out
  scale,
  
  /// Slide in/out
  slide,
  
  /// Combined fade and size
  combined,
}