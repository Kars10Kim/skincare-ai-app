/// Base class for recognition exceptions
abstract class RecognitionException implements Exception {
  /// Error message
  final String message;
  
  /// Create a recognition exception
  const RecognitionException(this.message);
  
  @override
  String toString() => 'RecognitionException: $message';
}

/// Exception thrown when barcode recognition fails
class BarcodeRecognitionException extends RecognitionException {
  /// Create a barcode recognition exception
  const BarcodeRecognitionException(String message) : super(message);
  
  @override
  String toString() => 'BarcodeRecognitionException: $message';
}

/// Exception thrown when ML text recognition fails
class MLRecognitionException extends RecognitionException {
  /// Create an ML recognition exception
  const MLRecognitionException(String message) : super(message);
  
  @override
  String toString() => 'MLRecognitionException: $message';
}

/// Exception thrown when a product is not found in the database
class ProductNotFoundException extends RecognitionException {
  /// Create a product not found exception
  const ProductNotFoundException(String message) : super(message);
  
  @override
  String toString() => 'ProductNotFoundException: $message';
}

/// Exception thrown when a network error occurs
class NetworkException extends RecognitionException {
  /// Create a network exception
  const NetworkException(String message) : super(message);
  
  @override
  String toString() => 'NetworkException: $message';
}

/// Exception thrown when permission is denied
class PermissionDeniedException extends RecognitionException {
  /// Create a permission denied exception
  const PermissionDeniedException(String message) : super(message);
  
  @override
  String toString() => 'PermissionDeniedException: $message';
}

/// Exception thrown when the device doesn't support a feature
class UnsupportedFeatureException extends RecognitionException {
  /// Create an unsupported feature exception
  const UnsupportedFeatureException(String message) : super(message);
  
  @override
  String toString() => 'UnsupportedFeatureException: $message';
}