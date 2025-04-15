
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../auth_service.dart';
import '../exceptions/auth_exceptions.dart';
import '../models/user.dart';
import '../utils/http_client.dart';

/// Authentication provider that manages auth state for the application
/// 
/// This provider exposes authentication state and methods to login, register,
/// logout, and check authentication status
class AuthProvider with ChangeNotifier {
  final AuthService _service = AuthService();
  final AuthenticatedHttpClient _httpClient = AuthenticatedHttpClient();
  
  AuthState _state = AuthState.initial();
  bool _initialized = false;
  User? _user;

  /// Current authentication state
  AuthState get state => _state;
  
  /// The currently authenticated user
  User? get user => _user;
  
  /// Whether the provider has been initialized
  bool get initialized => _initialized;
  
  /// Whether the user is authenticated
  bool get isAuthenticated => _state.isAuthenticated;

  /// Initialize the provider
  /// 
  /// Checks if the user is already authenticated and updates the state
  Future<void> initialize() async {
    if (_initialized) return;
    
    _state = AuthState.loading();
    notifyListeners();
    
    try {
      final isAuthenticated = await _service.isAuthenticated();
      if (isAuthenticated) {
        await _loadUserData();
        _state = AuthState.authenticated();
      } else {
        _user = null;
        _state = AuthState.initial();
      }
    } catch (e) {
      _user = null;
      _state = AuthState.initial();
    } finally {
      _initialized = true;
      notifyListeners();
    }
  }

  /// Authenticate a user with email and password
  /// 
  /// [email] - User's email
  /// [password] - User's password
  /// [useBiometrics] - Whether to enable biometric authentication
  Future<void> login(String email, String password, {bool useBiometrics = false}) async {
    _state = AuthState.loading();
    notifyListeners();

    try {
      await _service.login(
        email: email, 
        password: password, 
        useBiometrics: useBiometrics
      );
      
      await _loadUserData();
      _state = AuthState.authenticated();
    } on AuthException catch (e) {
      _user = null;
      _state = AuthState.error(e.message);
    } catch (e) {
      _user = null;
      _state = AuthState.error('An unexpected error occurred');
    }
    
    notifyListeners();
  }
  
  /// Register a new user
  /// 
  /// [email] - User's email
  /// [username] - User's username
  /// [password] - User's password
  Future<void> register(String email, String username, String password) async {
    _state = AuthState.loading();
    notifyListeners();

    try {
      await _service.register(
        email: email, 
        username: username, 
        password: password
      );
      
      await _loadUserData();
      _state = AuthState.authenticated();
    } on AuthException catch (e) {
      _user = null;
      _state = AuthState.error(e.message);
    } catch (e) {
      _user = null;
      _state = AuthState.error('An unexpected error occurred during registration');
    }
    
    notifyListeners();
  }

  /// Log out the current user
  Future<void> logout() async {
    try {
      await _service.logout();
    } finally {
      _user = null;
      _state = AuthState.initial();
      notifyListeners();
    }
  }
  
  /// Check if biometric authentication is available
  Future<bool> isBiometricAvailable() async {
    return await _service.isBiometricAvailable();
  }
  
  /// Authenticate using biometrics
  Future<bool> authenticateWithBiometrics() async {
    try {
      final result = await _service.authenticateWithBiometrics();
      if (result) {
        await _loadUserData();
        _state = AuthState.authenticated();
        notifyListeners();
      }
      return result;
    } catch (e) {
      return false;
    }
  }
  
  /// Check if the user is authenticated
  Future<bool> checkAuthenticated() async {
    try {
      final isAuthenticated = await _service.isAuthenticated();
      
      if (isAuthenticated) {
        if (_user == null) {
          await _loadUserData();
        }
        
        if (isAuthenticated != _state.isAuthenticated) {
          _state = AuthState.authenticated();
          notifyListeners();
        }
      } else {
        _user = null;
        
        if (_state.isAuthenticated) {
          _state = AuthState.initial();
          notifyListeners();
        }
      }
      
      return isAuthenticated;
    } catch (e) {
      _user = null;
      
      if (_state.isAuthenticated) {
        _state = AuthState.initial();
        notifyListeners();
      }
      
      return false;
    }
  }
  
  /// Update the user's preferences
  Future<bool> updateUserPreferences(Map<String, dynamic> preferences) async {
    if (_user == null) return false;
    
    try {
      final response = await _httpClient.put(
        '/api/user/preferences',
        body: preferences,
      );
      
      if (response.statusCode == 200) {
        final updatedUser = User.fromJson(jsonDecode(response.body));
        _user = updatedUser;
        notifyListeners();
        return true;
      }
      
      return false;
    } catch (e) {
      return false;
    }
  }
  
  /// Load user data from the API
  Future<void> _loadUserData() async {
    try {
      final response = await _httpClient.get('/api/user');
      
      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        _user = User.fromJson(userData);
      } else {
        _user = null;
      }
    } catch (e) {
      _user = null;
    }
  }
}

/// Represents the current authentication state
class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final String? error;

  AuthState({
    required this.isAuthenticated,
    required this.isLoading,
    this.error,
  });

  factory AuthState.initial() => AuthState(
    isAuthenticated: false,
    isLoading: false,
  );

  factory AuthState.loading() => AuthState(
    isAuthenticated: false,
    isLoading: true,
  );

  factory AuthState.authenticated() => AuthState(
    isAuthenticated: true,
    isLoading: false,
  );

  factory AuthState.error(String message) => AuthState(
    isAuthenticated: false,
    isLoading: false,
    error: message,
  );
  
  @override
  String toString() => 'AuthState(isAuthenticated: $isAuthenticated, isLoading: $isLoading, error: $error)';
}
