# Authentication Service Migration Guide

This guide provides instructions for migrating from the old authentication implementation to the new consolidated authentication service.

## Overview

The new authentication service provides:

- Centralized authentication logic with token management
- Built-in biometric authentication support
- Comprehensive error handling
- Route protection
- Password validation
- Token refresh mechanism
- Session persistence

## Migration Steps

### 1. Import the Consolidated Auth Module

Instead of importing individual auth-related files, import the consolidated auth module:

```dart
// Old imports
import '../../providers/auth_provider.dart';
import '../../services/auth_service.dart';

// New import
import '../../core/auth/auth.dart';
```

### 2. Update AuthProvider Usage

The new AuthProvider has a different interface:

```dart
// Old usage
final success = await authProvider.signIn(
  email: email,
  password: password,
);

// New usage
await authProvider.login(
  email,
  password,
);
// Check state via authProvider.isAuthenticated
```

```dart
// Old usage
final success = await authProvider.register(
  username: username,
  email: email,
  password: password,
);

// New usage
await authProvider.register(
  email,
  username,
  password,
);
// Check state via authProvider.isAuthenticated
```

### 3. Error Handling

Error handling has changed:

```dart
// Old code
if (authProvider.errorMessage != null) {
  // Show error
}

// New code
if (authProvider.state.error != null) {
  // Show error
}
```

### 4. Route Protection

Use the new AuthRoute component for route protection:

```dart
// Old manual protection
if (!authProvider.isAuthenticated) {
  Navigator.of(context).pushReplacementNamed('/auth');
  return Container();
}

// New automatic protection using AuthRoute
return AuthRoute(
  child: YourProtectedScreen(),
);
```

Or use the RouteProtection utility for more complex cases:

```dart
if (RouteProtection.requiresAuth(routeName)) {
  // Handle authentication requirement
}
```

### 5. Using the HTTP Client

Use the new authenticated HTTP client for API requests:

```dart
// Old code
final response = await authProvider.authenticatedRequest(
  'GET',
  '/api/data',
);

// New code
final httpClient = AuthenticatedHttpClient();
final response = await httpClient.get('/api/data');
```

### 6. Form Validation

Use the built-in validators for auth-related forms:

```dart
// Old validation
validator: (value) {
  if (value == null || value.isEmpty) {
    return 'Email is required';
  }
  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
    return 'Please enter a valid email';
  }
  return null;
},

// New validation
validator: (value) => AuthValidator.validateEmail(value),
```

## Files to Remove

Once migration is complete, these files can be safely removed:

- `lib/providers/auth_provider.dart`
- `lib/services/auth_service.dart`
- `lib/utils/route_guard.dart` (replaced by `lib/core/auth/navigation/route_protection.dart`)

## Additional Notes

- The new AuthService is a singleton to ensure consistent state across the app
- All authentication operations are protected by a mutex to prevent race conditions
- Biometric authentication is now integrated directly into the auth service
- Token refresh happens automatically when tokens expire