import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

/// Enum representing camera-related errors
enum CameraError {
  /// No camera detected on the device
  noCamera('CAM_01', 'No camera detected'),
  
  /// Camera permission denied
  permissionDenied('CAM_02', 'Enable camera access in settings'),
  
  /// Failed to capture image
  captureFailed('CAM_03', 'Failed to capture image'),
  
  /// Failed to initialize camera
  initializationFailed('CAM_04', 'Failed to initialize camera'),
  
  /// Failed to scan barcode
  barcodeScanFailed('CAM_05', 'Failed to scan barcode'),
  
  /// Failed to recognize text
  textRecognitionFailed('CAM_06', 'Failed to recognize text'),
  
  /// Gallery access denied
  galleryAccessDenied('CAM_07', 'Enable photo library access in settings'),
  
  /// Failed to load images from gallery
  galleryLoadFailed('CAM_08', 'Failed to load images from gallery'),
  
  /// Unknown error
  unknown('CAM_99', 'An unknown error occurred');

  /// Error code
  final String code;
  
  /// User-friendly message
  final String userMessage;
  
  /// Create a camera error
  const CameraError(this.code, this.userMessage);
}

/// Extension for handling camera errors
extension CameraErrorHandler on CameraError {
  /// Show an alert dialog for this error
  Future<void> showAlert(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error $code'),
          content: Text(userMessage),
          actions: <Widget>[
            if (this == CameraError.permissionDenied || 
                this == CameraError.galleryAccessDenied)
              TextButton(
                child: const Text('Open Settings'),
                onPressed: () {
                  Navigator.of(context).pop();
                  openAppSettings();
                },
              ),
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  
  /// Show a snackbar for this error
  void showSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$code: $userMessage'),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
}

/// Class for camera-specific exceptions
class CameraCaptureException implements Exception {
  /// Error message
  final String message;
  
  /// Camera error enum
  final CameraError error;
  
  /// Create a camera capture exception
  CameraCaptureException(this.message, [this.error = CameraError.captureFailed]);
  
  @override
  String toString() => 'CameraCaptureException: $message';
}

/// Class for barcode-specific exceptions
class BarcodeScanException implements Exception {
  /// Error message
  final String message;
  
  /// Camera error enum
  final CameraError error;
  
  /// Create a barcode scan exception
  BarcodeScanException(this.message, [this.error = CameraError.barcodeScanFailed]);
  
  @override
  String toString() => 'BarcodeScanException: $message';
}

/// Class for text recognition exceptions
class TextRecognitionException implements Exception {
  /// Error message
  final String message;
  
  /// Camera error enum
  final CameraError error;
  
  /// Create a text recognition exception
  TextRecognitionException(this.message, [this.error = CameraError.textRecognitionFailed]);
  
  @override
  String toString() => 'TextRecognitionException: $message';
}