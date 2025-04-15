import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../localization/app_localizations.dart';
import '../../utils/accessibility.dart';

/// Types of loading states
enum LoadingStateType {
  /// Spinner (default)
  spinner,
  
  /// Shimmer effect
  shimmer,
  
  /// Progress indicator
  progress,
  
  /// Skeleton screen
  skeleton,
}

/// LoadingStateWidget displays different types of loading indicators
/// based on the loading state type and accessibility settings.
class LoadingStateWidget extends StatelessWidget {
  /// Whether the component is in a loading state
  final bool isLoading;
  
  /// Type of loading state to display
  final LoadingStateType type;
  
  /// Color to use for the loading indicator
  final Color? color;
  
  /// Message to display below the loading indicator
  final String? message;
  
  /// Child widget to display when not loading
  final Widget? child;
  
  /// Progress value for progress indicator (0.0 to 1.0)
  final double? progress;
  
  /// Skeleton layout to use when type is skeleton
  final SkeletonLayout skeletonLayout;
  
  /// Background color for the loading indicator
  final Color? backgroundColor;
  
  /// Whether to show a transparent background
  final bool transparentBackground;
  
  /// Create loading state widget
  const LoadingStateWidget({
    Key? key,
    required this.isLoading,
    this.type = LoadingStateType.spinner,
    this.color,
    this.message,
    this.child,
    this.progress,
    this.skeletonLayout = SkeletonLayout.list,
    this.backgroundColor,
    this.transparentBackground = false,
  }) : super(key: key);
  
  /// Create a simple loading state with just a message
  const LoadingStateWidget.message({
    Key? key,
    required this.message,
    this.color,
    this.backgroundColor,
  }) : isLoading = true,
       type = LoadingStateType.spinner,
       child = null,
       progress = null,
       skeletonLayout = SkeletonLayout.list,
       transparentBackground = false,
       super(key: key);
       
  /// Create a shimmer loading state with skeleton layout
  const LoadingStateWidget.shimmer({
    Key? key,
    required this.isLoading,
    required this.skeletonLayout,
    required this.child,
    this.message,
    this.color,
    this.backgroundColor,
  }) : type = LoadingStateType.shimmer,
       progress = null,
       transparentBackground = false,
       super(key: key);
       
  /// Create a progress indicator loading state
  const LoadingStateWidget.progress({
    Key? key,
    required this.isLoading,
    required this.progress,
    this.message,
    this.color,
    this.child,
    this.backgroundColor,
  }) : type = LoadingStateType.progress,
       skeletonLayout = SkeletonLayout.list,
       transparentBackground = false,
       super(key: key);
  
  /// Create a skeleton screen loading state with customized layout
  const LoadingStateWidget.skeleton({
    Key? key,
    required this.isLoading,
    required this.skeletonLayout,
    required this.child,
    this.message,
    this.color,
    this.backgroundColor,
    this.transparentBackground = false,
  }) : type = LoadingStateType.skeleton,
       progress = null,
       super(key: key);
  
  @override
  Widget build(BuildContext context) {
    // Get theme data
    final theme = Theme.of(context);
    final loadingColor = color ?? theme.colorScheme.primary;
    
    // Get accessibility settings
    final accessibilitySettings = context.accessibilitySettings;
    
    // If using reduced motion or high contrast, always use spinner
    final effectiveType = (accessibilitySettings.reducedMotion || 
                          accessibilitySettings.highContrast) && 
                          type == LoadingStateType.shimmer
        ? LoadingStateType.spinner
        : type;
    
    // Use AnimatedSwitcher for smooth transitions
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      switchInCurve: Curves.easeIn,
      switchOutCurve: Curves.easeOut,
      child: isLoading
          ? _buildLoadingIndicator(
              context, 
              effectiveType, 
              loadingColor,
              accessibilitySettings,
            )
          : child ?? const SizedBox.shrink(),
    );
  }
  
  /// Build the appropriate loading indicator
  Widget _buildLoadingIndicator(
    BuildContext context,
    LoadingStateType effectiveType,
    Color loadingColor,
    AccessibilitySettings accessibilitySettings,
  ) {
    final localizations = AppLocalizations.of(context);
    
    // Container for loading indicator
    Widget content;
    
    switch (effectiveType) {
      case LoadingStateType.spinner:
        content = _buildSpinner(loadingColor);
        break;
      case LoadingStateType.shimmer:
        content = _buildShimmer(context, loadingColor);
        break;
      case LoadingStateType.progress:
        content = _buildProgressIndicator(loadingColor);
        break;
      case LoadingStateType.skeleton:
        content = _buildSkeleton(context, loadingColor, accessibilitySettings);
        break;
    }
    
    // Add message if provided
    if (message != null && message!.isNotEmpty) {
      content = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          content,
          const SizedBox(height: 16),
          Text(
            message!,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      );
    }
    
    // Create container with appropriate background
    return Container(
      color: transparentBackground
          ? Colors.transparent
          : backgroundColor ?? Colors.white.withOpacity(0.8),
      child: Center(
        child: Semantics(
          label: message ?? localizations.loading,
          value: effectiveType == LoadingStateType.progress && progress != null
              ? '${(progress! * 100).round()}%'
              : null,
          child: content,
        ),
      ),
    );
  }
  
  /// Build spinner loading indicator
  Widget _buildSpinner(Color color) {
    return SizedBox(
      width: 48,
      height: 48,
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(color),
        strokeWidth: 4,
      ),
    );
  }
  
  /// Build shimmer loading effect
  Widget _buildShimmer(BuildContext context, Color color) {
    return SizedBox(
      width: 200,
      height: 100,
      child: Shimmer.fromColors(
        baseColor: color.withOpacity(0.3),
        highlightColor: color.withOpacity(0.6),
        child: Column(
          children: [
            Container(
              width: 180,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: 140,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: 160,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Build progress indicator
  Widget _buildProgressIndicator(Color color) {
    return SizedBox(
      width: 100,
      height: 100,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 80,
            height: 80,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(color),
              strokeWidth: 6,
              value: progress,
            ),
          ),
          if (progress != null)
            Text(
              '${(progress! * 100).round()}%',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
        ],
      ),
    );
  }
  
  /// Build skeleton loading screen
  Widget _buildSkeleton(
    BuildContext context, 
    Color color,
    AccessibilitySettings accessibilitySettings,
  ) {
    // Skeleton container builder
    Widget skeletonContainer({
      required double width,
      required double height,
      EdgeInsetsGeometry? margin,
    }) {
      final container = Container(
        width: width,
        height: height,
        margin: margin,
        decoration: BoxDecoration(
          color: accessibilitySettings.highContrast 
              ? color.withOpacity(0.5)
              : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(4),
        ),
      );
      
      // If reduced motion, don't use shimmer
      if (accessibilitySettings.reducedMotion) {
        return container;
      }
      
      // Use shimmer for skeleton
      return Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: container,
      );
    }
    
    // Build different skeleton layouts
    switch (skeletonLayout) {
      case SkeletonLayout.list:
        return SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(
              5,
              (index) => Row(
                children: [
                  skeletonContainer(
                    width: 60,
                    height: 60,
                    margin: const EdgeInsets.all(8),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        skeletonContainer(
                          width: double.infinity,
                          height: 16,
                          margin: const EdgeInsets.only(
                            right: 8,
                            top: 8,
                            bottom: 4,
                          ),
                        ),
                        skeletonContainer(
                          width: 100,
                          height: 12,
                          margin: const EdgeInsets.only(
                            right: 8,
                            top: 4,
                            bottom: 8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      case SkeletonLayout.card:
        return SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              3,
              (index) => Container(
                margin: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 16,
                ),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    skeletonContainer(
                      width: double.infinity,
                      height: 24,
                      margin: const EdgeInsets.only(bottom: 12),
                    ),
                    skeletonContainer(
                      width: double.infinity,
                      height: 16,
                      margin: const EdgeInsets.only(bottom: 8),
                    ),
                    skeletonContainer(
                      width: 200,
                      height: 16,
                      margin: const EdgeInsets.only(bottom: 16),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        skeletonContainer(
                          width: 80,
                          height: 32,
                          margin: EdgeInsets.zero,
                        ),
                        skeletonContainer(
                          width: 80,
                          height: 32,
                          margin: EdgeInsets.zero,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      case SkeletonLayout.profile:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            skeletonContainer(
              width: 100,
              height: 100,
              margin: const EdgeInsets.only(bottom: 16),
            ),
            skeletonContainer(
              width: 150,
              height: 24,
              margin: const EdgeInsets.only(bottom: 32),
            ),
            ...List.generate(
              4,
              (index) => skeletonContainer(
                width: 240,
                height: 20,
                margin: const EdgeInsets.only(bottom: 16),
              ),
            ),
          ],
        );
      case SkeletonLayout.detail:
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            skeletonContainer(
              width: double.infinity,
              height: 200,
              margin: const EdgeInsets.only(bottom: 16),
            ),
            skeletonContainer(
              width: 250,
              height: 32,
              margin: const EdgeInsets.only(bottom: 12),
            ),
            skeletonContainer(
              width: 150,
              height: 20,
              margin: const EdgeInsets.only(bottom: 24),
            ),
            ...List.generate(
              6,
              (index) => skeletonContainer(
                width: double.infinity,
                height: 16,
                margin: const EdgeInsets.only(bottom: 12),
              ),
            ),
          ],
        );
    }
  }
}

/// Skeleton layout types
enum SkeletonLayout {
  /// List layout with items
  list,
  
  /// Card layout with multiple cards
  card,
  
  /// Profile layout with avatar and details
  profile,
  
  /// Detail view layout
  detail,
}