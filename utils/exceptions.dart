/// Base exception class for the application
abstract class AppException implements Exception {
  /// Exception message
  final String message;
  
  /// Create an app exception
  const AppException(this.message);
  
  @override
  String toString() => message;
}

/// Exception thrown when a product is not found
class ProductNotFoundException extends AppException {
  /// Create a product not found exception
  const ProductNotFoundException(String message) : super(message);
}

/// Exception thrown when there is a problem parsing ingredients
class IngredientParseException extends AppException {
  /// Create an ingredient parse exception
  const IngredientParseException(String message) : super(message);
}

/// Exception thrown when a product already exists
class ProductExistsException extends AppException {
  /// Create a product exists exception
  const ProductExistsException(String message) : super(message);
}

/// Exception thrown when there is a problem with network connectivity
class ConnectivityException extends AppException {
  /// Whether the operation can use fallback data
  final bool canUseFallbackData;
  
  /// Create a connectivity exception
  const ConnectivityException(
    String message, {
    this.canUseFallbackData = true,
  }) : super(message);
}

/// Exception thrown when a resource is not available
class ResourceUnavailableException extends AppException {
  /// Create a resource unavailable exception
  const ResourceUnavailableException(String message) : super(message);
}

/// Exception thrown when authentication fails
class AuthenticationException extends AppException {
  /// Create an authentication exception
  const AuthenticationException(String message) : super(message);
}

/// Exception thrown when user input is invalid
class ValidationException extends AppException {
  /// Field with the error
  final String field;
  
  /// Create a validation exception
  const ValidationException(this.field, String message) : super(message);
  
  @override
  String toString() => 'Invalid $field: $message';
}

/// Exception thrown when there's a camera error
class CameraException extends AppException {
  /// Create a camera exception
  const CameraException(String message) : super(message);
}

/// Exception thrown when barcode scanning fails
class BarcodeScanException extends AppException {
  /// Create a barcode scan exception
  const BarcodeScanException(String message) : super(message);
}

/// Exception thrown when text recognition fails
class TextRecognitionException extends AppException {
  /// Create a text recognition exception
  const TextRecognitionException(String message) : super(message);
}

/// Exception thrown when an operation times out
class TimeoutException extends AppException {
  /// The operation that timed out
  final String operation;
  
  /// Create a timeout exception
  const TimeoutException(this.operation, String message) : super(message);
  
  @override
  String toString() => 'Timeout during $operation: $message';
}

/// Exception thrown for storage-related issues
class StorageException extends AppException {
  /// Create a storage exception
  const StorageException(String message) : super(message);
}

/// Exception thrown for permission-related issues
class PermissionDeniedException extends AppException {
  /// The permission that was denied
  final String permission;
  
  /// Create a permission denied exception
  const PermissionDeniedException(this.permission, String message) : super(message);
  
  @override
  String toString() => 'Permission denied for $permission: $message';
}

/// Base class for database exceptions
abstract class DatabaseException extends AppException {
  /// Create a database exception
  const DatabaseException(String message) : super(message);
}

/// Exception thrown when database operations conflict
class DatabaseLockException extends DatabaseException {
  /// Create a database lock exception
  const DatabaseLockException(String message) : super(message);
}

/// Exception thrown when database integrity is violated
class DatabaseIntegrityException extends DatabaseException {
  /// Create a database integrity exception
  const DatabaseIntegrityException(String message) : super(message);
}