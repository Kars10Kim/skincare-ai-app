import 'package:flutter/material.dart';
import 'package:skincare_scanner/features/recognition/utils/exceptions.dart';
import 'package:skincare_scanner/localization/product_recognition_localizations.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

/// Helper class for handling recognition errors and providing recovery options
class RecognitionErrorHandler {
  /// Handle various recognition errors and show appropriate UI
  /// 
  /// Returns a Future<bool> indicating whether the operation should be retried
  static Future<bool> handleError(BuildContext context, dynamic error) async {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);
    
    // Default error message
    String errorTitle = localizations.unknownError;
    String errorMessage = 'An unexpected error occurred during product recognition.';
    List<Widget> actions = [];
    
    // Determine specific error type and message
    if (error is BarcodeRecognitionException) {
      errorTitle = localizations.invalidBarcode;
      errorMessage = 'The barcode could not be recognized. Please ensure the barcode is clear and try again.';
    } else if (error is MLRecognitionException) {
      errorTitle = localizations.noIngredientsFound;
      errorMessage = 'No ingredients could be recognized in the image. Try with better lighting or a clearer image.';
    } else if (error is ProductNotFoundException) {
      errorTitle = localizations.productNotFound;
      errorMessage = 'This product was not found in our database. Would you like to add it manually?';
      actions.add(
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(false);
            Navigator.of(context).pushNamed('/manual-entry');
          },
          child: Text(localizations.manualEntry),
        ),
      );
    } else if (error is NetworkException) {
      errorTitle = localizations.networkError;
      errorMessage = 'Unable to connect to the server. Please check your connection and try again.';
    }
    
    // Add device-specific information if helpful
    if (!kIsWeb) {
      if (Platform.isAndroid || Platform.isIOS) {
        errorMessage += ' If the problem persists, try updating your app or device.';
      }
    }
    
    // Always add retry option
    actions.add(
      TextButton(
        onPressed: () {
          Navigator.of(context).pop(true); // Return true to indicate retry
        },
        child: Text(localizations.tryAgain),
      ),
    );
    
    // Add cancel option
    actions.add(
      TextButton(
        onPressed: () {
          Navigator.of(context).pop(false); // Return false to indicate no retry
        },
        child: Text(localizations.cancel),
      ),
    );
    
    // Show dialog with error and recovery options
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(errorTitle),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(errorMessage),
                const SizedBox(height: 16),
                _buildRecoveryTips(context, error),
              ],
            ),
          ),
          actions: actions,
        );
      },
    ) ?? false; // Default to false if dialog is dismissed
  }
  
  /// Build recovery tips based on error type
  static Widget _buildRecoveryTips(BuildContext context, dynamic error) {
    final theme = Theme.of(context);
    
    List<String> tips = [];
    
    if (error is BarcodeRecognitionException) {
      tips = [
        'Ensure the barcode is well-lit and clearly visible',
        'Hold the camera steady and align the barcode in the frame',
        'Try scanning the UPC barcode if available',
      ];
    } else if (error is MLRecognitionException) {
      tips = [
        'Make sure the ingredient list is clearly visible',
        'Try with better lighting conditions',
        'Hold the camera steady to avoid blur',
        'Make sure the text is in focus',
      ];
    } else if (error is ProductNotFoundException) {
      tips = [
        'Check if the product is available in our database',
        'You can manually enter product details',
        'Some regional products may not be available',
      ];
    } else if (error is NetworkException) {
      tips = [
        'Check your internet connection',
        'Try again in a few moments',
        'If using Wi-Fi, try switching to mobile data',
      ];
    } else {
      tips = [
        'Restart the app and try again',
        'Update to the latest version',
        'Try scanning in better lighting conditions',
      ];
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tips:',
          style: theme.textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        ...tips.map((tip) => Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.tips_and_updates_outlined,
                size: 16,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(tip),
              ),
            ],
          ),
        )),
      ],
    );
  }
}