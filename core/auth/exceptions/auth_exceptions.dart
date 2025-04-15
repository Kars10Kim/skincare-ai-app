
class AuthException implements Exception {
  final String message;
  AuthException(this.message);
}

class ThrottleException extends AuthException {
  ThrottleException(String message) : super(message);
}

class WeakPasswordException extends AuthException {
  WeakPasswordException() : super('Password does not meet security requirements');
}

class BiometricException extends AuthException {
  BiometricException() : super('Biometric authentication failed');
}

class TokenException extends AuthException {
  TokenException() : super('Token validation failed');
}
