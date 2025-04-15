import 'package:camera/camera.dart';

enum CameraErrorType {
  permissionDenied,
  initializationError,
  processingError,
  hardwareError,
  unknown,
}

class CameraErrorHandler {
  static CameraErrorType getErrorType(String errorCode) {
    switch (errorCode) {
      case 'permissionDenied':
        return CameraErrorType.permissionDenied;
      case 'CameraAccessDenied':
        return CameraErrorType.permissionDenied;
      case 'noCameras':
        return CameraErrorType.hardwareError;
      default:
        return CameraErrorType.unknown;
    }
  }
  
  static String getErrorMessage(CameraException exception) {
    final errorType = getErrorType(exception.code);
    
    switch (errorType) {
      case CameraErrorType.permissionDenied:
        return 'Camera permission was denied. Please enable camera access in your device settings.';
      case CameraErrorType.initializationError:
        return 'Failed to initialize the camera. Please restart the app.';
      case CameraErrorType.hardwareError:
        return 'No camera available or camera hardware error.';
      case CameraErrorType.processingError:
        return 'Error processing camera image.';
      case CameraErrorType.unknown:
      default:
        return 'An unexpected camera error occurred: ${exception.description}';
    }
  }
}