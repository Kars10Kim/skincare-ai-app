import 'package:flutter/material.dart';
import '../../../utils/constants.dart';

/// Overlay to display camera errors
class ErrorOverlay extends StatelessWidget {
  /// Error message to display
  final String error;
  
  /// Callback for retry button
  final VoidCallback onRetry;
  
  /// Creates an error overlay
  const ErrorOverlay({
    Key? key,
    required this.error,
    required this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Map common error messages to user-friendly versions
    String userMessage = _getUserFriendlyErrorMessage(error);
    
    return Container(
      color: Colors.black87,
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              color: AppColors.errorColor,
              size: 64,
            ),
            const SizedBox(height: 24),
            Text(
              'Camera Error',
              style: AppTextStyles.heading2.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              userMessage,
              style: AppTextStyles.body.copyWith(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Converts technical error messages to user-friendly versions
  String _getUserFriendlyErrorMessage(String error) {
    final String lowerError = error.toLowerCase();
    
    if (lowerError.contains('permission') || lowerError.contains('denied')) {
      return 'Camera permission denied. Please enable camera access in your device settings.';
    } else if (lowerError.contains('unavailable') || lowerError.contains('not available')) {
      return 'Camera is currently unavailable. Please try again later.';
    } else if (lowerError.contains('timeout')) {
      return 'Operation timed out. Please check your network connection and try again.';
    } else if (lowerError.contains('light') || lowerError.contains('dark')) {
      return 'Poor lighting conditions detected. Please move to a brighter area and try again.';
    } else if (lowerError.contains('quota') || lowerError.contains('limit')) {
      return 'Service temporarily limited. Please try again later.';
    } else if (lowerError.contains('focus') || lowerError.contains('blurry')) {
      return 'Image is too blurry. Please hold your device steady and try again.';
    } else if (lowerError.contains('network') || lowerError.contains('internet')) {
      return 'Network connection error. Please check your internet connection and try again.';
    } else if (lowerError.contains('initialize')) {
      return 'Failed to initialize camera. Please restart the app and try again.';
    }
    
    // Default message for unknown errors
    return 'An unexpected error occurred. Please try again.';
  }
}