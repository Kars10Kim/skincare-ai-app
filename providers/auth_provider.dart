import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../services/auth_service.dart';
import '../services/encryption_service.dart';
import '../utils/secure_storage.dart';
import '../models/user_model.dart';
import 'package:jwt_decoder/jwt_decoder.dart'; // Added import for JWT decoding


/// Provider for handling authentication state and operations
class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  final SecurePreferences _securePreferences;
  final EncryptionService _encryptionService;

  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isInitialized = false;

  /// Constructor
  AuthProvider({
    required AuthService authService,
    required SecurePreferences securePreferences,
    required EncryptionService encryptionService,
  }) :
        _authService = authService,
        _securePreferences = securePreferences,
        _encryptionService = encryptionService {
    // Initialize the provider
    _initialize();
  }

  /// Current authenticated user
  User? get currentUser => _currentUser;

  /// Whether user is currently authenticated
  bool get isAuthenticated => _currentUser != null;

  /// Whether authentication is in progress
  bool get isLoading => _isLoading;

  /// Current error message if any
  String? get errorMessage => _errorMessage;

  /// Initialize the provider
  Future<void> _initialize() async {
    if (_isInitialized) return;

    _isLoading = true;
    notifyListeners();

    try {
      // Try to load user data from secure storage
      final userData = await _securePreferences.getString('user_data');

      if (userData != null) {
        // Decrypt user data if it's encrypted
        final decryptedData = await _encryptionService.decrypt(userData);
        _currentUser = User.fromJson(jsonDecode(decryptedData));

        // Verify that token is valid
        final isValid = await _authService.refreshTokenIfNeeded();
        if (!isValid) {
          // Token couldn't be refreshed, clear user
          await signOut();
        }
      }
    } catch (e) {
      debugPrint('Error initializing auth provider: $e');
      _errorMessage = 'Failed to restore authentication state';
    } finally {
      _isLoading = false;
      _isInitialized = true;
      notifyListeners();
    }
  }

  /// Sign in with email and password
  Future<bool> signIn({required String email, required String password}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('/api/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Save tokens
        await _securePreferences.setString('access_token', data['accessToken']);
        await _securePreferences.setString('refresh_token', data['refreshToken']);

        // Save user data
        _currentUser = User.fromJson(data['user']);
        final encryptedUserData = await _encryptionService.encrypt(jsonEncode(_currentUser!.toJson()));
        await _securePreferences.setString('user_data', encryptedUserData);

        notifyListeners();
        return true;
      } else {
        final error = jsonDecode(response.body);
        _errorMessage = error['error'] ?? 'Failed to sign in';
        return false;
      }
    } catch (e) {
      debugPrint('Error signing in: $e');
      _errorMessage = 'Network error or server unavailable';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Register a new user
  Future<bool> register({
    required String username,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('/api/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);

        // Save tokens (if they are returned with registration)
        if (data['accessToken'] != null) {
          await _securePreferences.setString('access_token', data['accessToken']);
        }
        if (data['refreshToken'] != null) {
          await _securePreferences.setString('refresh_token', data['refreshToken']);
        }

        // Save user data
        _currentUser = User.fromJson(data['user']);
        final encryptedUserData = await _encryptionService.encrypt(jsonEncode(_currentUser!.toJson()));
        await _securePreferences.setString('user_data', encryptedUserData);

        notifyListeners();
        return true;
      } else {
        final error = jsonDecode(response.body);
        _errorMessage = error['error'] ?? 'Failed to register';
        return false;
      }
    } catch (e) {
      debugPrint('Error registering: $e');
      _errorMessage = 'Network error or server unavailable';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sign out the current user
  Future<void> signOut({VoidCallback? onSignOut}) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Call logout endpoint to invalidate the token
      await _authService.authenticatedRequest('POST', '/api/logout');
    } catch (e) {
      debugPrint('Error signing out: $e');
    } finally {
      // Clear tokens and user data regardless of server response
      await _authService.clearTokens();
      await _securePreferences.remove('user_data');
      _currentUser = null;
      _isLoading = false;
      notifyListeners();

      // Call onSignOut callback if provided
      if (onSignOut != null) {
        onSignOut();
      }
    }
  }

  /// Refresh the user profile data
  Future<void> refreshUserData() async {
    if (!isAuthenticated) return;

    try {
      final response = await _authService.authenticatedRequest('GET', '/api/user');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _currentUser = User.fromJson(data);

        // Update stored user data
        final encryptedUserData = await _encryptionService.encrypt(jsonEncode(_currentUser!.toJson()));
        await _securePreferences.setString('user_data', encryptedUserData);

        notifyListeners();
      } else if (response.statusCode == 401) {
        // Token is invalid, sign out
        await signOut();
      }
    } catch (e) {
      debugPrint('Error refreshing user data: $e');
    }
  }

  /// Clear any error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> refreshTokenIfNeeded() async {
    try {
      final accessToken = await _securePreferences.getString('access_token');
      final refreshToken = await _securePreferences.getString('refresh_token');

      if (accessToken == null || refreshToken == null) {
        return false;
      }

      // Check token expiration
      final tokenData = JwtDecoder.decode(accessToken);
      final expiration = DateTime.fromMillisecondsSinceEpoch(tokenData['exp'] * 1000);
      final currentTime = DateTime.now();

      // Refresh if token expires in less than 5 minutes
      if (expiration.difference(currentTime).inMinutes <= 5) {
        final success = await refreshToken();
        if (!success) {
          await signOut();
          return false;
        }
        return true;
      }

      return true;
    } catch (e) {
      await signOut();
      return false;
    }
  }

  Future<bool> refreshToken() async {
    try {
      final refreshToken = await _securePreferences.getString('refresh_token');
      if (refreshToken == null) return false;

      final response = await http.post(
        Uri.parse('/api/refresh'), // Assumed refresh endpoint
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _securePreferences.setString('access_token', data['accessToken']);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}