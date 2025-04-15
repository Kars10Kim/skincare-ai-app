import 'package:flutter/material.dart';

/// A card with an animated border and hover effect
class AnimatedSelectionCard extends StatefulWidget {
  /// Whether the card is selected
  final bool isSelected;
  
  /// The color of the card when selected
  final Color selectedColor;
  
  /// The color of the card when not selected
  final Color unselectedColor;
  
  /// Border radius
  final BorderRadius borderRadius;
  
  /// The child widget
  final Widget child;
  
  /// Callback when tapped
  final VoidCallback onTap;
  
  /// Animation duration
  final Duration duration;
  
  /// Create animated selection card
  const AnimatedSelectionCard({
    Key? key,
    required this.isSelected,
    required this.selectedColor,
    required this.unselectedColor,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    required this.child,
    required this.onTap,
    this.duration = const Duration(milliseconds: 200),
  }) : super(key: key);
  
  @override
  State<AnimatedSelectionCard> createState() => _AnimatedSelectionCardState();
}

class _AnimatedSelectionCardState extends State<AnimatedSelectionCard> {
  /// Whether the card is being hovered
  bool _isHovered = false;
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: widget.duration,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? widget.selectedColor.withOpacity(0.1)
                : (_isHovered ? widget.unselectedColor.withOpacity(0.05) : Colors.transparent),
            borderRadius: widget.borderRadius,
            border: Border.all(
              color: widget.isSelected
                  ? widget.selectedColor
                  : (_isHovered ? widget.unselectedColor.withOpacity(0.5) : widget.unselectedColor.withOpacity(0.2)),
              width: widget.isSelected ? 2 : 1,
            ),
            boxShadow: widget.isSelected || _isHovered
                ? [
                    BoxShadow(
                      color: widget.selectedColor.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

/// An animated checkbox with custom style
class AnimatedCheckbox extends StatelessWidget {
  /// Whether the checkbox is checked
  final bool isChecked;
  
  /// The color when checked
  final Color activeColor;
  
  /// The color when unchecked
  final Color inactiveColor;
  
  /// The size of the checkbox
  final double size;
  
  /// Callback when tapped
  final VoidCallback onTap;
  
  /// Animation duration
  final Duration duration;
  
  /// Create animated checkbox
  const AnimatedCheckbox({
    Key? key,
    required this.isChecked,
    required this.activeColor,
    required this.inactiveColor,
    this.size = 24,
    required this.onTap,
    this.duration = const Duration(milliseconds: 200),
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: duration,
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: isChecked ? activeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isChecked ? activeColor : inactiveColor,
            width: 2,
          ),
        ),
        child: Center(
          child: AnimatedOpacity(
            opacity: isChecked ? 1.0 : 0.0,
            duration: duration,
            child: Icon(
              Icons.check,
              color: Colors.white,
              size: size * 0.7,
            ),
          ),
        ),
      ),
    );
  }
}

/// An animated gradient progress bar
class AnimatedGradientProgressBar extends StatelessWidget {
  /// The value between 0.0 and 1.0
  final double value;
  
  /// Starting color for the gradient
  final Color startColor;
  
  /// Ending color for the gradient
  final Color endColor;
  
  /// Background color
  final Color backgroundColor;
  
  /// Height of the bar
  final double height;
  
  /// Width of the bar
  final double? width;
  
  /// Border radius
  final BorderRadius borderRadius;
  
  /// Animation duration
  final Duration duration;
  
  /// Create animated gradient progress bar
  const AnimatedGradientProgressBar({
    Key? key,
    required this.value,
    required this.startColor,
    required this.endColor,
    this.backgroundColor = Colors.black12,
    this.height = 8,
    this.width,
    this.borderRadius = const BorderRadius.all(Radius.circular(4)),
    this.duration = const Duration(milliseconds: 300),
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadius,
      ),
      child: Stack(
        children: [
          AnimatedContainer(
            duration: duration,
            width: (width ?? double.infinity) * value.clamp(0.0, 1.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [startColor, endColor],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: borderRadius,
            ),
          ),
        ],
      ),
    );
  }
}

/// An animated gradient background
class AnimatedGradientBackground extends StatelessWidget {
  /// First color of the gradient
  final Color color1;
  
  /// Second color of the gradient
  final Color color2;
  
  /// The child widget
  final Widget child;
  
  /// Animation duration
  final Duration duration;
  
  /// Create animated gradient background
  const AnimatedGradientBackground({
    Key? key,
    required this.color1,
    required this.color2,
    required this.child,
    this.duration = const Duration(seconds: 3),
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: duration,
      builder: (context, value, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.lerp(color1, color2, value)!,
                Color.lerp(color2, color1, value)!,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: child,
        );
      },
      child: child,
    );
  }
}

/// A shimmer effect for loading states
class ShimmerEffect extends StatelessWidget {
  /// The child widget
  final Widget child;
  
  /// Base color of the shimmer
  final Color baseColor;
  
  /// Highlight color of the shimmer
  final Color highlightColor;
  
  /// Create shimmer effect
  const ShimmerEffect({
    Key? key,
    required this.child,
    required this.baseColor,
    required this.highlightColor,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcATop,
      shaderCallback: (bounds) {
        return _shimmerGradient.createShader(bounds);
      },
      child: child,
    );
  }
  
  /// Create shimmer gradient
  LinearGradient get _shimmerGradient => LinearGradient(
        colors: [
          baseColor,
          highlightColor,
          baseColor,
        ],
        stops: const [0.1, 0.5, 0.9],
        begin: const Alignment(-1.0, -0.5),
        end: const Alignment(1.0, 0.5),
        tileMode: TileMode.clamp,
      );
}

/// A glassmorphism card
class GlassmorphicCard extends StatelessWidget {
  /// The child widget
  final Widget child;
  
  /// Background color
  final Color backgroundColor;
  
  /// Border color
  final Color borderColor;
  
  /// Border radius
  final BorderRadius borderRadius;
  
  /// Border width
  final double borderWidth;
  
  /// Blur intensity
  final double blur;
  
  /// Opacity of the background
  final double opacity;
  
  /// Create glassmorphic card
  const GlassmorphicCard({
    Key? key,
    required this.child,
    this.backgroundColor = Colors.white,
    this.borderColor = Colors.white,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
    this.borderWidth = 1.5,
    this.blur = 10,
    this.opacity = 0.2,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: blur > 0
            ? ColorFilter.mode(
                backgroundColor.withOpacity(0.1),
                BlendMode.screen,
              )
            : ColorFilter.mode(
                Colors.transparent,
                BlendMode.src,
              ),
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor.withOpacity(opacity),
            borderRadius: borderRadius,
            border: Border.all(
              color: borderColor.withOpacity(0.2),
              width: borderWidth,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// A fade slide transition for list items
class FadeSlideTransition extends StatefulWidget {
  /// The animation controller
  final AnimationController animation;
  
  /// Delay in seconds before starting animation
  final double delay;
  
  /// Slide direction
  final AxisDirection direction;
  
  /// Slide offset
  final double offset;
  
  /// The child widget
  final Widget child;
  
  /// Create fade slide transition
  const FadeSlideTransition({
    Key? key,
    required this.animation,
    this.delay = 0.0,
    this.direction = AxisDirection.up,
    this.offset = 50.0,
    required this.child,
  }) : super(key: key);
  
  @override
  State<FadeSlideTransition> createState() => _FadeSlideTransitionState();
}

class _FadeSlideTransitionState extends State<FadeSlideTransition> {
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  @override
  void initState() {
    super.initState();
    
    // Create a delayed animation curve
    final delayedCurve = Interval(
      widget.delay.clamp(0.0, 1.0),
      1.0,
      curve: Curves.easeOutCubic,
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: widget.animation,
      curve: delayedCurve,
    );
    
    // Create the slide offset based on direction
    Offset beginOffset;
    switch (widget.direction) {
      case AxisDirection.up:
        beginOffset = Offset(0.0, widget.offset / 100);
        break;
      case AxisDirection.down:
        beginOffset = Offset(0.0, -widget.offset / 100);
        break;
      case AxisDirection.right:
        beginOffset = Offset(-widget.offset / 100, 0.0);
        break;
      case AxisDirection.left:
        beginOffset = Offset(widget.offset / 100, 0.0);
        break;
    }
    
    _slideAnimation = Tween<Offset>(
      begin: beginOffset,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: widget.animation,
      curve: delayedCurve,
    ));
  }
  
  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}