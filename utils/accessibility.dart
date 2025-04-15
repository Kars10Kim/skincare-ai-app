import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';

/// Accessibility settings model
class AccessibilitySettings {
  /// Whether high contrast mode is enabled
  final bool highContrast;
  
  /// Whether reduced motion is enabled
  final bool reducedMotion;
  
  /// Whether the screen reader is active
  final bool screenReaderActive;
  
  /// Whether large text is enabled
  final bool largeText;
  
  /// Create accessibility settings
  const AccessibilitySettings({
    this.highContrast = false,
    this.reducedMotion = false,
    this.screenReaderActive = false,
    this.largeText = false,
  });
  
  /// Create a copy with updated values
  AccessibilitySettings copyWith({
    bool? highContrast,
    bool? reducedMotion,
    bool? screenReaderActive,
    bool? largeText,
  }) {
    return AccessibilitySettings(
      highContrast: highContrast ?? this.highContrast,
      reducedMotion: reducedMotion ?? this.reducedMotion,
      screenReaderActive: screenReaderActive ?? this.screenReaderActive,
      largeText: largeText ?? this.largeText,
    );
  }
}

/// Extension for accessing accessibility settings from a build context
extension AccessibilitySettingsExtension on BuildContext {
  /// Get the current accessibility settings
  AccessibilitySettings get accessibilitySettings {
    final mediaQueryData = MediaQuery.of(this);
    final platform = Theme.of(this).platform;
    
    return AccessibilitySettings(
      highContrast: mediaQueryData.highContrast,
      reducedMotion: mediaQueryData.disableAnimations || platform == TargetPlatform.android && mediaQueryData.platformBrightness == Brightness.dark,
      screenReaderActive: SemanticsBinding.instance.semanticsEnabled,
      largeText: mediaQueryData.textScaleFactor > 1.3,
    );
  }
}

/// Mixin for providing accessibility support to widgets
mixin AccessibilitySupport<T extends StatefulWidget> on State<T> {
  /// Accessibility settings
  late AccessibilitySettings accessibilitySettings;
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    accessibilitySettings = context.accessibilitySettings;
  }
  
  /// Perform haptic feedback
  Future<void> performHapticFeedback(HapticFeedbackType type) async {
    switch (type) {
      case HapticFeedbackType.light:
        await HapticFeedback.lightImpact();
        break;
      case HapticFeedbackType.medium:
        await HapticFeedback.mediumImpact();
        break;
      case HapticFeedbackType.heavy:
        await HapticFeedback.heavyImpact();
        break;
      case HapticFeedbackType.selection:
        await HapticFeedback.selectionClick();
        break;
    }
  }
}

/// Types of haptic feedback
enum HapticFeedbackType {
  /// Light impact
  light,
  
  /// Medium impact
  medium,
  
  /// Heavy impact
  heavy,
  
  /// Selection click
  selection,
}

/// Widget that applies fade transition only if animations are enabled
class AccessibleFadeTransition extends StatelessWidget {
  /// The animation that controls the opacity of the child
  final Animation<double> opacity;
  
  /// The widget below this widget in the tree
  final Widget child;
  
  /// Duration of the fade if animations are disabled
  final Duration instantDuration;
  
  /// Create an accessible fade transition
  const AccessibleFadeTransition({
    Key? key,
    required this.opacity,
    required this.child,
    this.instantDuration = const Duration(milliseconds: 50),
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final accessibilitySettings = context.accessibilitySettings;
    
    // If reduced motion is enabled, don't animate
    if (accessibilitySettings.reducedMotion) {
      return Opacity(
        opacity: opacity.isCompleted ? 1.0 : 0.0,
        child: child,
      );
    }
    
    // Otherwise use normal fade transition
    return FadeTransition(
      opacity: opacity,
      child: child,
    );
  }
}