import 'package:equatable/equatable.dart';

/// Types of scan errors
enum ScanErrorType {
  /// Barcode scanning error
  barcode,
  
  /// Image recognition error
  recognition,
  
  /// Network error
  network,
  
  /// Database error
  database,
  
  /// Data validation error
  validation,
  
  /// Unknown error
  unknown,
}

/// Scan error
class ScanError extends Equatable {
  /// Error type
  final ScanErrorType type;
  
  /// Error message
  final String message;
  
  /// Error code
  final String? code;
  
  /// Technical details for debugging
  final dynamic details;
  
  /// Create scan error
  const ScanError({
    required this.type,
    required this.message,
    this.code,
    this.details,
  });
  
  /// Create barcode error
  factory ScanError.barcode(String message, {String? code, dynamic details}) {
    return ScanError(
      type: ScanErrorType.barcode,
      message: message,
      code: code,
      details: details,
    );
  }
  
  /// Create recognition error
  factory ScanError.recognition(String message, {String? code, dynamic details}) {
    return ScanError(
      type: ScanErrorType.recognition,
      message: message,
      code: code,
      details: details,
    );
  }
  
  /// Create network error
  factory ScanError.network(String message, {String? code, dynamic details}) {
    return ScanError(
      type: ScanErrorType.network,
      message: message,
      code: code,
      details: details,
    );
  }
  
  /// Create database error
  factory ScanError.database(String message, {String? code, dynamic details}) {
    return ScanError(
      type: ScanErrorType.database,
      message: message,
      code: code,
      details: details,
    );
  }
  
  /// Create validation error
  factory ScanError.validation(String message, {String? code, dynamic details}) {
    return ScanError(
      type: ScanErrorType.validation,
      message: message,
      code: code,
      details: details,
    );
  }
  
  /// Create unknown error
  factory ScanError.unknown(dynamic error) {
    String message = 'An unknown error occurred';
    
    if (error is Exception || error is Error) {
      message = error.toString();
    } else if (error is String) {
      message = error;
    }
    
    return ScanError(
      type: ScanErrorType.unknown,
      message: message,
      details: error,
    );
  }
  
  /// Get user-friendly error message
  String get displayMessage {
    switch (type) {
      case ScanErrorType.barcode:
        return 'Barcode scanning error: $message';
      case ScanErrorType.recognition:
        return 'Image recognition error: $message';
      case ScanErrorType.network:
        return 'Network error: $message';
      case ScanErrorType.database:
        return 'Database error: $message';
      case ScanErrorType.validation:
        return message;
      case ScanErrorType.unknown:
        return 'Error: $message';
    }
  }
  
  /// Get recovery hint
  String get recoveryHint {
    switch (type) {
      case ScanErrorType.barcode:
        return 'Try scanning again in better lighting or with a clearer view of the barcode';
      case ScanErrorType.recognition:
        return 'Try using a clearer image or manually enter the ingredients';
      case ScanErrorType.network:
        return 'Check your internet connection and try again';
      case ScanErrorType.database:
        return 'Restart the app and try again';
      case ScanErrorType.validation:
        return 'Check your input and try again';
      case ScanErrorType.unknown:
        return 'Try again later or contact support';
    }
  }
  
  @override
  List<Object?> get props => [type, message, code, details];
}