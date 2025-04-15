import 'package:flutter/material.dart';

/// Represents an error that can occur during the onboarding process
class OnboardingError {
  /// Error code
  final String code;
  
  /// Error message
  final String message;
  
  /// Detailed description of the error
  final String details;
  
  /// Whether this error is recoverable
  final bool isRecoverable;
  
  /// Recovery hints
  final List<String> recoveryHints;
  
  /// Create an onboarding error
  const OnboardingError({
    required this.code,
    required this.message,
    this.details = '',
    this.isRecoverable = true,
    this.recoveryHints = const [],
  });
  
  /// Create a network error
  factory OnboardingError.network(String details) {
    return OnboardingError(
      code: 'NETWORK_ERROR',
      message: 'Network connection error',
      details: details,
      isRecoverable: true,
      recoveryHints: [
        'Check your internet connection',
        'Try connecting to a different network',
        'This may be a temporary issue - wait a moment and try again',
      ],
    );
  }
  
  /// Create a storage error
  factory OnboardingError.storage(String details) {
    return OnboardingError(
      code: 'STORAGE_ERROR',
      message: 'Storage error',
      details: details,
      isRecoverable: true,
      recoveryHints: [
        'Your device may be low on storage',
        'Try restarting the app',
        'If the problem persists, try clearing the app cache',
      ],
    );
  }
  
  /// Create a validation error
  factory OnboardingError.validation(String details) {
    return OnboardingError(
      code: 'VALIDATION_ERROR',
      message: 'Validation error',
      details: details,
      isRecoverable: true,
      recoveryHints: [
        'Check your entries for any mistakes',
        'Some questions require specific formats',
        'Try selecting a different option',
      ],
    );
  }
  
  /// Create a server error
  factory OnboardingError.server(String details) {
    return OnboardingError(
      code: 'SERVER_ERROR',
      message: 'Server error',
      details: details,
      isRecoverable: true,
      recoveryHints: [
        'Our servers might be experiencing issues',
        'This is a temporary problem - please try again later',
        'If the problem persists, contact support',
      ],
    );
  }
  
  /// Create a timeout error
  factory OnboardingError.timeout() {
    return const OnboardingError(
      code: 'TIMEOUT_ERROR',
      message: 'Request timed out',
      details: 'The operation took too long to complete.',
      isRecoverable: true,
      recoveryHints: [
        'Your internet connection may be slow',
        'The server might be busy - try again in a moment',
        'Try switching to a different network if available',
      ],
    );
  }
  
  /// Create a login error
  factory OnboardingError.authentication(String details) {
    return OnboardingError(
      code: 'AUTH_ERROR',
      message: 'Authentication error',
      details: details,
      isRecoverable: true,
      recoveryHints: [
        'Your session may have expired',
        'Try logging in again',
        'Check your username and password',
      ],
    );
  }
  
  /// Create a permissions error
  factory OnboardingError.permissions(String details) {
    return OnboardingError(
      code: 'PERMISSION_ERROR',
      message: 'Permission denied',
      details: details,
      isRecoverable: true,
      recoveryHints: [
        'This app needs certain permissions to function',
        'You can update permissions in your device settings',
        'Try granting the requested permissions and try again',
      ],
    );
  }
  
  /// Create an unknown error
  factory OnboardingError.unknown(dynamic error) {
    return OnboardingError(
      code: 'UNKNOWN_ERROR',
      message: 'An unknown error occurred',
      details: error.toString(),
      isRecoverable: false,
      recoveryHints: [
        'Try restarting the app',
        'This may be a temporary issue',
        'If the problem persists, try reinstalling the app',
      ],
    );
  }
  
  /// Show a recovery dialog to the user
  Future<bool> showRecoveryDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(message),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(details),
                if (recoveryHints.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Suggestions:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...recoveryHints.map((hint) => Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• '),
                        Expanded(child: Text(hint)),
                      ],
                    ),
                  )).toList(),
                ],
                const SizedBox(height: 16),
                Text(
                  isRecoverable
                      ? 'Would you like to try again?'
                      : 'Would you like to restart the onboarding process?',
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            FilledButton(
              child: Text(isRecoverable ? 'Retry' : 'Restart'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    ) ?? false;
  }
  
  /// Get a short display message
  String get displayMessage {
    switch (code) {
      case 'NETWORK_ERROR':
        return 'No internet connection. Please check your connection and try again.';
      case 'STORAGE_ERROR':
        return 'Unable to save your data. Please check your device storage.';
      case 'VALIDATION_ERROR':
        return 'Please check your information and try again.';
      case 'SERVER_ERROR':
        return 'Our servers are experiencing issues. Please try again later.';
      case 'TIMEOUT_ERROR':
        return 'Request took too long to complete. Please try again.';
      case 'AUTH_ERROR':
        return 'Your session has expired. Please log in again.';
      case 'PERMISSION_ERROR':
        return 'Required permissions are missing. Please update your settings.';
      default:
        return 'Something went wrong. Please try again later.';
    }
  }
  
  @override
  String toString() {
    return 'OnboardingError[$code]: $message - $details';
  }
}