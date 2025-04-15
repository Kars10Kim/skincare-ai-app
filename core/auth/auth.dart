/// This file provides a centralized export point for all auth-related functionality
/// 
/// Import this file to access all auth-related functionality in one import:
/// ```dart
/// import 'package:skincare_scanner/core/auth/auth.dart';
/// ```

// Core services
export 'auth_service.dart';
export 'token_manager.dart';

// Providers
export 'providers/auth_provider.dart';

// Models
export 'models/user.dart';

// Utils
export 'utils/auth_validator.dart';
export 'utils/http_client.dart';

// Exceptions
export 'exceptions/auth_exceptions.dart';

// Biometric authentication
export 'biometric/biometric_auth.dart';

// Navigation and route protection
export 'navigation/auth_route.dart';
export 'navigation/route_protection.dart';