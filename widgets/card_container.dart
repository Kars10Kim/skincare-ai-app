import 'package:flutter/material.dart';
import 'dart:ui';

/// A container with card-like styling, optionally with glassmorphism effect
class CardContainer extends StatelessWidget {
  /// Child widget
  final Widget child;
  
  /// Whether to use glassmorphism effect
  final bool useGlassmorphism;
  
  /// Border radius
  final double borderRadius;
  
  /// Background color
  final Color? backgroundColor;
  
  /// Border color
  final Color? borderColor;
  
  /// Elevation (shadow)
  final double elevation;
  
  /// Creates a card container
  const CardContainer({
    Key? key,
    required this.child,
    this.useGlassmorphism = false,
    this.borderRadius = 16.0,
    this.backgroundColor,
    this.borderColor,
    this.elevation = 2.0,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = backgroundColor ?? theme.cardTheme.color ?? theme.cardColor;
    
    if (useGlassmorphism) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: Container(
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(borderRadius),
              border: borderColor != null 
                  ? Border.all(color: borderColor!) 
                  : Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1.0,
                    ),
              boxShadow: [
                if (elevation > 0)
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: elevation * 3,
                    offset: Offset(0, elevation),
                  ),
              ],
            ),
            child: child,
          ),
        ),
      );
    } else {
      return Card(
        elevation: elevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          side: borderColor != null 
              ? BorderSide(color: borderColor!) 
              : BorderSide.none,
        ),
        color: bgColor,
        child: child,
      );
    }
  }
}