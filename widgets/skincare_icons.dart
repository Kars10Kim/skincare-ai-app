import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Icons for skin types, concerns, and ingredients
class SkincareIcons {
  /// Icons for skin types
  static const Map<String, IconData> skinTypeIcons = {
    'normal': Icons.water_drop_outlined,
    'oily': Icons.opacity,
    'dry': Icons.grain,
    'combination': Icons.water_drop_outlined,
    'sensitive': Icons.ac_unit,
  };

  /// Icons for skin concerns
  static const Map<String, IconData> skinConcernIcons = {
    'acne': Icons.coronavirus_outlined,
    'wrinkles': Icons.line_style,
    'darkSpots': Icons.circle,
    'dryness': Icons.waves_outlined,
    'redness': Icons.local_fire_department_outlined,
    'sensitivity': Icons.health_and_safety_outlined,
  };

  /// Animated icon for the welcome screen
  static Widget buildWelcomeAnimation(BuildContext context, Color color) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(
          Icons.face_retouching_natural,
          size: 80,
          color: color,
        ),
      ),
    );
  }

  /// Build icon for skin type
  static Widget buildSkinTypeIcon(String type, Color color, double size) {
    final IconData iconData = skinTypeIcons[type] ?? Icons.question_mark;
    
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(
          iconData,
          size: size * 0.6,
          color: color,
        ),
      ),
    );
  }

  /// Build icon for skin concern with animation
  static Widget buildSkinConcernIcon(
    String concern, 
    Color color, 
    double size,
    bool isSelected,
  ) {
    final IconData iconData = skinConcernIcons[concern] ?? Icons.question_mark;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isSelected ? color.withOpacity(0.2) : color.withOpacity(0.05),
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? color : color.withOpacity(0.2),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Center(
        child: Icon(
          iconData,
          size: size * 0.5,
          color: isSelected ? color : color.withOpacity(0.6),
        ),
      ),
    );
  }

  /// Build ingredient icon with animation
  static Widget buildIngredientIcon(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(
          Icons.science_outlined,
          size: size * 0.6,
          color: color,
        ),
      ),
    );
  }

  /// Build animated splash effect
  static Widget buildSplashAnimation(Color color) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(seconds: 2),
      builder: (context, value, child) {
        return Container(
          width: 200 * value,
          height: 200 * value,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1 * (1 - value)),
            shape: BoxShape.circle,
          ),
          child: child,
        );
      },
      child: Icon(
        Icons.water_drop,
        size: 80,
        color: color.withOpacity(0.7),
      ),
    );
  }
}