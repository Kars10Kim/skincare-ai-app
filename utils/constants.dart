import 'package:flutter/material.dart';

/// Constant values used throughout the app
class AppConstants {
  /// Base API URL
  static const String apiBaseUrl = 'http://localhost:5000/api';
  
  /// App version
  static const String appVersion = '1.0.0';
  
  /// Default animation duration
  static const Duration animationDuration = Duration(milliseconds: 300);
  
  /// Min password length
  static const int minPasswordLength = 8;
}

/// App color palette
class AppColors {
  /// Primary color
  static const Color primaryColor = Color(0xFF6750A4);
  
  /// Primary light variant
  static const Color primaryLightColor = Color(0xFFEADDFF);
  
  /// Secondary color
  static const Color secondaryColor = Color(0xFF625B71);
  
  /// Secondary light variant
  static const Color secondaryLightColor = Color(0xFFE8DEF8);
  
  /// Success color
  static const Color successColor = Color(0xFF4CAF50);
  
  /// Warning color
  static const Color warningColor = Color(0xFFFFC107);
  
  /// Error color
  static const Color errorColor = Color(0xFFF44336);
  
  /// Info color
  static const Color infoColor = Color(0xFF2196F3);
  
  /// Background color (light)
  static const Color backgroundLight = Color(0xFFF6F6F6);
  
  /// Background color (dark)
  static const Color backgroundDark = Color(0xFF121212);
  
  /// Text primary color (light)
  static const Color textPrimaryColor = Color(0xFF1D1B20);
  
  /// Text secondary color (light)
  static const Color textSecondaryColor = Color(0xFF49454F);
  
  /// Text primary color (dark)
  static const Color textPrimaryDarkColor = Color(0xFFE6E1E5);
  
  /// Text secondary color (dark)
  static const Color textSecondaryDarkColor = Color(0xFFCAC4D0);
  
  /// Conflict severity - Low
  static const Color conflictLow = Color(0xFFFFE082);
  
  /// Conflict severity - Medium
  static const Color conflictMedium = Color(0xFFFFB74D);
  
  /// Conflict severity - High
  static const Color conflictHigh = Color(0xFFFF8A65);
  
  /// Conflict severity - Severe
  static const Color conflictSevere = Color(0xFFE57373);
}

/// Text styles used throughout the app
class AppTextStyles {
  /// Heading 1 
  static const TextStyle heading1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
  );
  
  /// Heading 2
  static const TextStyle heading2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
  );
  
  /// Heading 3
  static const TextStyle heading3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );
  
  /// Subtitle 1
  static const TextStyle subtitle1 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );
  
  /// Subtitle 2
  static const TextStyle subtitle2 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );
  
  /// Body 1
  static const TextStyle body1 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
  );
  
  /// Body 2
  static const TextStyle body2 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
  );
  
  /// Caption
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
  );
  
  /// Button
  static const TextStyle button = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );
}

/// App dimensions
class AppDimensions {
  /// Screen padding
  static const double screenPadding = 16.0;
  
  /// Screen padding - medium
  static const double screenPaddingMedium = 24.0;
  
  /// Screen padding - large
  static const double screenPaddingLarge = 32.0;
  
  /// Widget spacing - extra small
  static const double spacingXs = 4.0;
  
  /// Widget spacing - small
  static const double spacingS = 8.0;
  
  /// Widget spacing - medium
  static const double spacingM = 16.0;
  
  /// Widget spacing - large
  static const double spacingL = 24.0;
  
  /// Widget spacing - extra large
  static const double spacingXl = 32.0;
  
  /// Border radius - small
  static const double borderRadiusSmall = 4.0;
  
  /// Border radius - medium
  static const double borderRadiusMedium = 8.0;
  
  /// Border radius - large
  static const double borderRadiusLarge = 16.0;
  
  /// Avatar size - small
  static const double avatarSizeSmall = 32.0;
  
  /// Avatar size - medium
  static const double avatarSizeMedium = 48.0;
  
  /// Avatar size - large
  static const double avatarSizeLarge = 64.0;
  
  /// Button height - small
  static const double buttonHeightSmall = 36.0;
  
  /// Button height - medium
  static const double buttonHeightMedium = 44.0;
  
  /// Button height - large
  static const double buttonHeightLarge = 52.0;
  
  /// Input field height
  static const double inputFieldHeight = 56.0;
}

/// App assets
class AppAssets {
  /// Onboarding images
  static const String onboarding1 = 'assets/images/onboarding_1.svg';
  static const String onboarding2 = 'assets/images/onboarding_2.svg';
  static const String onboarding3 = 'assets/images/onboarding_3.svg';
  
  /// Profile placeholder
  static const String profilePlaceholder = 'assets/images/profile_placeholder.png';
  
  /// Product placeholder
  static const String productPlaceholder = 'assets/images/product_placeholder.png';
}