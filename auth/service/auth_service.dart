import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

import '../../../core/services/lifecycle/lazy_service.dart';
import '../../../core/services/service_locator.dart';
import '../models/auth_models.dart';
import '../../../core/services/individual_services/connectivity_service.dart';

/// Service for authentication and user management
class AuthService extends LazyService {
  /// Factory constructor that returns singleton instance
  factory AuthService() => _instance;
  
  /// Internal constructor for singleton pattern
  AuthService._internal() {
    assert(!_isInstantiated, 'Use ServiceLocator.get<AuthService>() instead');
    _isInstantiated = true;
  }
  
  /// Singleton instance
  static final AuthService _instance = AuthService._internal();
  
  /// Flag to prevent direct instantiation
  static bool _isInstantiated = false;
  
  /// Secure storage for tokens and credentials
  late final FlutterSecureStorage _secureStorage;
  
  /// Local authentication for biometrics
  late final LocalAuthentication _localAuth;
  
  /// HTTP client for API requests
  late final http.Client _httpClient;
  
  /// Current user
  User? _currentUser;
  
  /// Current auth token
  String? _token;
  
  /// Whether biometric authentication is enabled
  bool _biometricEnabled = false;
  
  /// Whether biometric authentication is available
  bool _biometricAvailable = false;
  
  /// Token expiration time
  DateTime? _tokenExpiration;
  
  /// Get the current user
  User? get currentUser => _currentUser;
  
  /// Get whether the user is authenticated
  bool get isAuthenticated => _currentUser != null && _token != null;
  
  /// Get whether biometric authentication is enabled
  bool get biometricEnabled => _biometricEnabled;
  
  /// Get whether biometric authentication is available
  bool get biometricAvailable => _biometricAvailable;
  
  @override
  Future<void> init() async {
    if (isInitialized) return;
    
    await super.init();
    
    // Initialize dependencies
    _secureStorage = const FlutterSecureStorage();
    _localAuth = LocalAuthentication();
    _httpClient = http.Client();
    
    // Check if biometric authentication is available
    await _checkBiometricAvailability();
    
    // Try to restore session
    await _restoreSession();
    
    debugPrint('AuthService initialized');
  }
  
  /// Check if biometric authentication is available
  Future<void> _checkBiometricAvailability() async {
    try {
      _biometricAvailable = await _localAuth.canCheckBiometrics &&
                            await _localAuth.isDeviceSupported();
    } catch (e) {
      debugPrint('Error checking biometric availability: $e');
      _biometricAvailable = false;
    }
  }
  
  /// Restore session from secure storage
  Future<void> _restoreSession() async {
    try {
      // Get token from secure storage
      final token = await _secureStorage.read(key: 'auth_token');
      final tokenExpiration = await _secureStorage.read(key: 'token_expiration');
      final userData = await _secureStorage.read(key: 'user_data');
      final biometricEnabled = await _secureStorage.read(key: 'biometric_enabled');
      
      if (token != null && userData != null && tokenExpiration != null) {
        final expirationDate = DateTime.parse(tokenExpiration);
        
        // Check if token is still valid
        if (expirationDate.isAfter(DateTime.now())) {
          _token = token;
          _tokenExpiration = expirationDate;
          _currentUser = User.fromJson(jsonDecode(userData));
          _biometricEnabled = biometricEnabled == 'true';
          
          debugPrint('Session restored for user: ${_currentUser!.username}');
        } else {
          // Token expired, clear session
          await _clearSession();
          debugPrint('Token expired, session cleared');
        }
      }
    } catch (e) {
      debugPrint('Error restoring session: $e');
      await _clearSession();
    }
  }
  
  /// Clear session data
  Future<void> _clearSession() async {
    try {
      await _secureStorage.delete(key: 'auth_token');
      await _secureStorage.delete(key: 'token_expiration');
      await _secureStorage.delete(key: 'user_data');
      
      _token = null;
      _tokenExpiration = null;
      _currentUser = null;
    } catch (e) {
      debugPrint('Error clearing session: $e');
    }
  }
  
  /// Check if a user is authenticated
  Future<bool> isAuthenticatedAsync() async {
    // Make sure service is initialized
    if (!isInitialized) {
      await init();
    }
    
    return isAuthenticated;
  }
  
  /// Enable or disable biometric authentication
  Future<bool> setBiometricEnabled(bool enabled) async {
    try {
      // Make sure service is initialized
      if (!isInitialized) {
        await init();
      }
      
      if (!_biometricAvailable) {
        return false;
      }
      
      // Verify user with biometrics first
      if (enabled) {
        final authenticated = await _authenticateWithBiometrics(
          'Verify your identity',
          'Authenticate to enable biometric login',
        );
        
        if (!authenticated) {
          return false;
        }
      }
      
      // Save setting
      _biometricEnabled = enabled;
      await _secureStorage.write(
        key: 'biometric_enabled',
        value: enabled.toString(),
      );
      
      return true;
    } catch (e) {
      debugPrint('Error setting biometric enabled: $e');
      return false;
    }
  }
  
  /// Authenticate with biometrics
  Future<bool> _authenticateWithBiometrics(String title, String subtitle) async {
    if (!_biometricAvailable) {
      return false;
    }
    
    try {
      final authenticated = await _localAuth.authenticate(
        localizedReason: subtitle,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
      
      return authenticated;
    } catch (e) {
      debugPrint('Error authenticating with biometrics: $e');
      return false;
    }
  }
  
  /// Login with biometrics
  Future<LoginResult> loginWithBiometrics() async {
    // Make sure service is initialized
    if (!isInitialized) {
      await init();
    }
    
    if (!_biometricEnabled || !_biometricAvailable) {
      return LoginResult(
        success: false,
        errorMessage: 'Biometric authentication is not enabled',
      );
    }
    
    try {
      final authenticated = await _authenticateWithBiometrics(
        'Login with biometrics',
        'Authenticate to login to your account',
      );
      
      if (!authenticated) {
        return LoginResult(
          success: false,
          errorMessage: 'Biometric authentication failed',
        );
      }
      
      // Get stored credentials
      final username = await _secureStorage.read(key: 'biometric_username');
      final password = await _secureStorage.read(key: 'biometric_password');
      
      if (username == null || password == null) {
        return LoginResult(
          success: false,
          errorMessage: 'No stored credentials found',
        );
      }
      
      // Login with stored credentials
      return await login(username, password);
    } catch (e) {
      debugPrint('Error logging in with biometrics: $e');
      return LoginResult(
        success: false,
        errorMessage: 'Authentication error: $e',
      );
    }
  }
  
  /// Login with username and password
  Future<LoginResult> login(String username, String password) async {
    // Make sure service is initialized
    if (!isInitialized) {
      await init();
    }
    
    try {
      // Check connectivity
      final connectivityService = await ServiceLocator.instance.get<ConnectivityService>();
      final isConnected = await connectivityService.checkConnectivity();
      
      if (!isConnected) {
        return LoginResult(
          success: false,
          errorMessage: 'No internet connection',
        );
      }
      
      // Make login request
      final response = await _httpClient.post(
        Uri.parse('http://localhost:5000/api/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        
        // Save user data and token
        _currentUser = User.fromJson(responseData);
        _token = responseData['token'];
        _tokenExpiration = DateTime.now().add(const Duration(days: 7));
        
        // Save to secure storage
        await _secureStorage.write(key: 'auth_token', value: _token);
        await _secureStorage.write(
          key: 'token_expiration',
          value: _tokenExpiration!.toIso8601String(),
        );
        await _secureStorage.write(
          key: 'user_data',
          value: jsonEncode(_currentUser!.toJson()),
        );
        
        // Save credentials for biometric login if enabled
        if (_biometricEnabled) {
          await _secureStorage.write(key: 'biometric_username', value: username);
          await _secureStorage.write(key: 'biometric_password', value: password);
        }
        
        return LoginResult(
          success: true,
          user: _currentUser,
        );
      } else {
        final errorMessage = response.statusCode == 401
            ? 'Invalid username or password'
            : 'Login failed: ${response.body}';
        
        return LoginResult(
          success: false,
          errorMessage: errorMessage,
        );
      }
    } catch (e) {
      debugPrint('Error logging in: $e');
      return LoginResult(
        success: false,
        errorMessage: 'Authentication error: $e',
      );
    }
  }
  
  /// Register a new user
  Future<RegisterResult> register(RegisterRequest request) async {
    // Make sure service is initialized
    if (!isInitialized) {
      await init();
    }
    
    try {
      // Check connectivity
      final connectivityService = await ServiceLocator.instance.get<ConnectivityService>();
      final isConnected = await connectivityService.checkConnectivity();
      
      if (!isConnected) {
        return RegisterResult(
          success: false,
          errorMessage: 'No internet connection',
        );
      }
      
      // Make register request
      final response = await _httpClient.post(
        Uri.parse('http://localhost:5000/api/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      );
      
      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        
        // Auto-login after registration
        _currentUser = User.fromJson(responseData);
        _token = responseData['token'];
        _tokenExpiration = DateTime.now().add(const Duration(days: 7));
        
        // Save to secure storage
        await _secureStorage.write(key: 'auth_token', value: _token);
        await _secureStorage.write(
          key: 'token_expiration',
          value: _tokenExpiration!.toIso8601String(),
        );
        await _secureStorage.write(
          key: 'user_data',
          value: jsonEncode(_currentUser!.toJson()),
        );
        
        return RegisterResult(
          success: true,
          user: _currentUser,
        );
      } else {
        final errorMessage = response.statusCode == 400
            ? 'Username already exists'
            : 'Registration failed: ${response.body}';
        
        return RegisterResult(
          success: false,
          errorMessage: errorMessage,
        );
      }
    } catch (e) {
      debugPrint('Error registering: $e');
      return RegisterResult(
        success: false,
        errorMessage: 'Registration error: $e',
      );
    }
  }
  
  /// Logout the current user
  Future<bool> logout() async {
    // Make sure service is initialized
    if (!isInitialized) {
      await init();
    }
    
    try {
      // Make logout request
      final response = await _httpClient.post(
        Uri.parse('http://localhost:5000/api/logout'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );
      
      // Clear session data regardless of response
      await _clearSession();
      
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error logging out: $e');
      // Clear session data even if request fails
      await _clearSession();
      return false;
    }
  }
  
  /// Get authentication token
  Future<String?> getToken() async {
    // Make sure service is initialized
    if (!isInitialized) {
      await init();
    }
    
    // Check if token is expired
    if (_tokenExpiration != null && _tokenExpiration!.isBefore(DateTime.now())) {
      // Token expired, clear session
      await _clearSession();
      return null;
    }
    
    return _token;
  }
  
  @override
  Future<void> dispose() async {
    if (!isInitialized) return;
    
    _httpClient.close();
    
    await super.dispose();
  }
}