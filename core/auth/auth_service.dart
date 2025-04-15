
import 'dart:convert';
import 'package:mutex/mutex.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import './token_manager.dart';
import './biometric/biometric_auth.dart';
import './exceptions/auth_exceptions.dart';

/// Centralized authentication service that handles all authentication operations
/// including login, registration, token management, and biometric authentication.
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  
  // Private constructor for singleton implementation
  AuthService._internal();

  final TokenManager _tokenManager = TokenManager();
  final BiometricAuth _biometricAuth = BiometricAuth();
  final _lock = Lock();
  final _attempts = <String, int>{};
  final _connectivity = Connectivity();
  
  // API endpoints
  static const String _baseUrl = '/api'; // Use relative URL for flexibility
  static const String _loginEndpoint = '$_baseUrl/login';
  static const String _registerEndpoint = '$_baseUrl/register';
  static const String _refreshEndpoint = '$_baseUrl/refresh';
  static const String _logoutEndpoint = '$_baseUrl/logout';
  
  /// Maximum allowed login attempts before throttling
  static const int _maxAttempts = 5;
  
  /// Cooling off period for throttled accounts (in minutes)
  static const int _coolOffPeriod = 15;
  
  /// Time when attempts should be reset for each user
  final Map<String, DateTime> _throttleExpiry = {};

  /// Authenticate a user with email and password
  /// 
  /// [email] - User's email address
  /// [password] - User's password
  /// [useBiometrics] - Whether to enable biometric auth after successful login
  Future<AuthResult> login({
    required String email,
    required String password,
    bool useBiometrics = false,
  }) async {
    return await _lock.synchronized(() async {
      // Check for throttling
      if (_isThrottled(email)) {
        final timeLeft = _throttleExpiry[email]!.difference(DateTime.now());
        final minutes = (timeLeft.inSeconds / 60).ceil();
        throw ThrottleException('Too many attempts. Try again in $minutes minutes');
      }

      try {
        // Check connectivity before attempting network request
        final connectivityResult = await _connectivity.checkConnectivity();
        if (connectivityResult == ConnectivityResult.none) {
          throw AuthException('No internet connection available');
        }
        
        final token = await _remoteAuth(email, password);
        await _tokenManager.save(token);
        
        if (useBiometrics) {
          await _biometricAuth.enableForAuth();
        }
        
        // Reset attempts on successful login
        _attempts.remove(email);
        _throttleExpiry.remove(email);
        return AuthResult.success;
      } on AuthException catch (e) {
        // Increment failed attempts counter
        _attempts[email] = (_attempts[email] ?? 0) + 1;
        
        // Check if account should be throttled
        if (_attempts[email]! >= _maxAttempts) {
          _throttleExpiry[email] = DateTime.now().add(Duration(minutes: _coolOffPeriod));
        }
        
        _logFailedAttempt(email);
        rethrow;
      } catch (e) {
        throw AuthException('Login failed: ${e.toString()}');
      }
    });
  }

  /// Register a new user account
  /// 
  /// [email] - User's email address
  /// [username] - User's username
  /// [password] - User's password
  Future<AuthResult> register({
    required String email,
    required String username,
    required String password,
  }) async {
    return await _lock.synchronized(() async {
      try {
        // Check connectivity before attempting network request
        final connectivityResult = await _connectivity.checkConnectivity();
        if (connectivityResult == ConnectivityResult.none) {
          throw AuthException('No internet connection available');
        }
        
        // Validate password strength
        if (!_isPasswordStrong(password)) {
          throw WeakPasswordException();
        }
        
        final token = await _remoteRegister(email, username, password);
        await _tokenManager.save(token);
        return AuthResult.success;
      } on AuthException {
        rethrow;
      } catch (e) {
        throw AuthException('Registration failed: ${e.toString()}');
      }
    });
  }

  /// Log out the current user
  Future<void> logout() async {
    await _lock.synchronized(() async {
      try {
        final token = await _tokenManager.getToken();
        if (token != null) {
          // Attempt to notify the server about logout
          try {
            await http.post(
              Uri.parse(_logoutEndpoint),
              headers: {'Authorization': 'Bearer ${token.token}'},
            );
          } catch (_) {
            // Silent failure for server notification
          }
        }
        
        // Always clear local token storage
        await _tokenManager.clear();
        await _biometricAuth.disable();
      } catch (e) {
        throw AuthException('Logout failed: ${e.toString()}');
      }
    });
  }

  /// Check if the user is currently authenticated
  /// 
  /// Returns true if the user has a valid, non-expired token
  Future<bool> isAuthenticated() async {
    try {
      final token = await _tokenManager.getToken();
      // If no token exists, not authenticated
      if (token == null) return false;
      
      // If token is expired, attempt refresh
      if (token.isExpired) {
        try {
          final newToken = await _refreshToken(token);
          await _tokenManager.save(newToken);
          return true;
        } catch (_) {
          // If refresh fails, require re-authentication
          await _tokenManager.clear();
          return false;
        }
      }
      
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Get the current authentication token
  /// 
  /// Returns the current token or null if not authenticated
  Future<AuthToken?> getToken() async {
    final token = await _tokenManager.getToken();
    if (token == null || token.isExpired) {
      return null;
    }
    return token;
  }

  /// Check if biometric authentication is available and enabled
  Future<bool> isBiometricAvailable() async {
    return await _biometricAuth.isAvailable();
  }

  /// Authenticate using device biometrics
  /// 
  /// Returns true if authentication is successful
  Future<bool> authenticateWithBiometrics() async {
    try {
      await _biometricAuth.authenticate();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Enable biometric authentication for the current user
  Future<void> enableBiometrics() async {
    await _biometricAuth.enableForAuth();
  }

  /// Disable biometric authentication for the current user
  Future<void> disableBiometrics() async {
    await _biometricAuth.disable();
  }

  /// Check if a user account is currently throttled due to too many login attempts
  bool _isThrottled(String email) {
    if (!_attempts.containsKey(email) || _attempts[email]! < _maxAttempts) {
      return false;
    }
    
    final expiry = _throttleExpiry[email];
    if (expiry == null) return false;
    
    if (DateTime.now().isAfter(expiry)) {
      // Throttling period expired, reset counters
      _attempts.remove(email);
      _throttleExpiry.remove(email);
      return false;
    }
    
    return true;
  }

  /// Log a failed authentication attempt for security monitoring
  void _logFailedAttempt(String email) {
    // In a production app, this would log to a secure audit system
    // For now, we just maintain the counter
    print('Failed login attempt for $email. Attempt ${_attempts[email]} of $_maxAttempts');
  }

  /// Validate password strength
  bool _isPasswordStrong(String password) {
    // Minimum 8 characters with at least one uppercase, one lowercase, one number
    final hasMinLength = password.length >= 8;
    final hasUppercase = password.contains(RegExp(r'[A-Z]'));
    final hasLowercase = password.contains(RegExp(r'[a-z]'));
    final hasDigit = password.contains(RegExp(r'[0-9]'));
    
    return hasMinLength && hasUppercase && hasLowercase && hasDigit;
  }

  /// Authenticate with the remote server
  Future<AuthToken> _remoteAuth(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(_loginEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );
      
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final expiresIn = jsonResponse['expiresIn'] ?? 3600;
        
        return AuthToken(
          jsonResponse['token'],
          DateTime.now().add(Duration(seconds: expiresIn)),
        );
      } else if (response.statusCode == 401) {
        throw AuthException('Invalid email or password');
      } else {
        throw AuthException('Authentication failed (${response.statusCode})');
      }
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Network error: ${e.toString()}');
    }
  }

  /// Register a new user with the remote server
  Future<AuthToken> _remoteRegister(String email, String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse(_registerEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'username': username,
          'password': password,
        }),
      );
      
      if (response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        final expiresIn = jsonResponse['expiresIn'] ?? 3600;
        
        return AuthToken(
          jsonResponse['token'],
          DateTime.now().add(Duration(seconds: expiresIn)),
        );
      } else if (response.statusCode == 409) {
        throw AuthException('Email or username already exists');
      } else {
        throw AuthException('Registration failed (${response.statusCode})');
      }
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Network error: ${e.toString()}');
    }
  }

  /// Refresh an expired authentication token
  Future<AuthToken> _refreshToken(AuthToken oldToken) async {
    try {
      final response = await http.post(
        Uri.parse(_refreshEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${oldToken.token}'
        },
      );
      
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final expiresIn = jsonResponse['expiresIn'] ?? 3600;
        
        return AuthToken(
          jsonResponse['token'],
          DateTime.now().add(Duration(seconds: expiresIn)),
        );
      } else {
        throw TokenException();
      }
    } catch (e) {
      if (e is AuthException) rethrow;
      throw TokenException();
    }
  }
}

/// Result of an authentication operation
enum AuthResult { 
  success, 
  failure 
}
