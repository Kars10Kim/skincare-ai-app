import 'package:equatable/equatable.dart';

/// Base failure class
abstract class Failure extends Equatable {
  @override
  List<Object> get props => [];
}

/// Server failure
class ServerFailure extends Failure {
  @override
  List<Object> get props => [];
}

/// Cache failure
class CacheFailure extends Failure {
  @override
  List<Object> get props => [];
}

/// Network failure
class NetworkFailure extends Failure {
  @override
  List<Object> get props => [];
}

/// Authentication failure
class AuthFailure extends Failure {
  /// Error message
  final String message;
  
  /// Create auth failure
  AuthFailure(this.message);
  
  @override
  List<Object> get props => [message];
}

/// Input validation failure
class ValidationFailure extends Failure {
  /// Error messages
  final List<String> errors;
  
  /// Create validation failure
  ValidationFailure(this.errors);
  
  @override
  List<Object> get props => [errors];
}

/// Not found failure
class NotFoundFailure extends Failure {
  /// Item that wasn't found
  final String item;
  
  /// Create not found failure
  NotFoundFailure(this.item);
  
  @override
  List<Object> get props => [item];
}

/// Permission denied failure
class PermissionFailure extends Failure {
  /// Permission that was denied
  final String permission;
  
  /// Create permission failure
  PermissionFailure(this.permission);
  
  @override
  List<Object> get props => [permission];
}

/// Unknown failure
class UnknownFailure extends Failure {
  /// Error message
  final String message;
  
  /// Create unknown failure
  UnknownFailure(this.message);
  
  @override
  List<Object> get props => [message];
}