import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skincare_scanner/features/onboarding/domain/entities/skin_profile.dart';

/// Model representing a user
class User {
  /// User ID
  final String id;
  
  /// Username
  final String username;
  
  /// Email address
  final String? email;
  
  /// Display name
  final String? displayName;
  
  /// Avatar URL
  final String? avatarUrl;
  
  /// Whether the user has completed onboarding
  final bool hasCompletedOnboarding;
  
  /// Skin profile
  final SkinProfile? skinProfile;
  
  /// Create a user
  User({
    required this.id,
    required this.username,
    this.email,
    this.displayName,
    this.avatarUrl,
    this.hasCompletedOnboarding = false,
    this.skinProfile,
  });
  
  /// Create a copy with new values
  User copyWith({
    String? id,
    String? username,
    String? email,
    String? displayName,
    String? avatarUrl,
    bool? hasCompletedOnboarding,
    SkinProfile? skinProfile,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      hasCompletedOnboarding: hasCompletedOnboarding ?? this.hasCompletedOnboarding,
      skinProfile: skinProfile ?? this.skinProfile,
    );
  }
  
  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'displayName': displayName,
      'avatarUrl': avatarUrl,
      'hasCompletedOnboarding': hasCompletedOnboarding,
      'skinProfile': skinProfile?.toJson(),
    };
  }
  
  /// Create from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      displayName: json['displayName'],
      avatarUrl: json['avatarUrl'],
      hasCompletedOnboarding: json['hasCompletedOnboarding'] ?? false,
      skinProfile: json['skinProfile'] != null 
          ? SkinProfile.fromJson(json['skinProfile']) 
          : null,
    );
  }
}

/// Provider for user state
class UserProvider extends ChangeNotifier {
  /// Current user
  User? _currentUser;
  
  /// Loading state
  bool _isLoading = false;
  
  /// Error message
  String? _error;
  
  /// Get the current user
  User? get currentUser => _currentUser;
  
  /// Get whether the user is authenticated
  bool get isAuthenticated => _currentUser != null;
  
  /// Get whether the user has completed onboarding
  bool get hasCompletedOnboarding => 
      _currentUser?.hasCompletedOnboarding ?? false;
  
  /// Get whether data is loading
  bool get isLoading => _isLoading;
  
  /// Get the error message
  String? get error => _error;
  
  /// Initialize the provider
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // Try to load user from local storage
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user');
      
      if (userJson != null) {
        _currentUser = User.fromJson(Map<String, dynamic>.from(
          const JsonDecoder().convert(userJson),
        ));
      }
      
      _error = null;
    } catch (e) {
      _error = 'Failed to load user data';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Sign in a user
  Future<bool> signIn(String username, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));
      
      // In a real app, this would call an authentication service
      // For now, accept any non-empty values
      if (username.isNotEmpty && password.isNotEmpty) {
        _currentUser = User(
          id: 'user_${DateTime.now().millisecondsSinceEpoch}',
          username: username,
          displayName: username,
          hasCompletedOnboarding: false,
        );
        
        // Save to local storage
        await _saveUserToStorage();
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Invalid username or password';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Authentication failed: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  /// Register a new user
  Future<bool> register(String username, String password, String? email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));
      
      // In a real app, this would call a registration service
      // For now, accept any non-empty values
      if (username.isNotEmpty && password.isNotEmpty) {
        _currentUser = User(
          id: 'user_${DateTime.now().millisecondsSinceEpoch}',
          username: username,
          email: email,
          displayName: username,
          hasCompletedOnboarding: false,
        );
        
        // Save to local storage
        await _saveUserToStorage();
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Invalid username or password';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Registration failed: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  /// Sign out the current user
  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // Clear user from local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user');
      
      _currentUser = null;
      _error = null;
    } catch (e) {
      _error = 'Sign out failed: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Update the user's profile
  Future<bool> updateProfile({
    String? displayName,
    String? email,
    String? avatarUrl,
    bool? hasCompletedOnboarding,
    SkinProfile? skinProfile,
  }) async {
    if (_currentUser == null) return false;
    
    _isLoading = true;
    notifyListeners();
    
    try {
      _currentUser = _currentUser!.copyWith(
        displayName: displayName,
        email: email,
        avatarUrl: avatarUrl,
        hasCompletedOnboarding: hasCompletedOnboarding,
        skinProfile: skinProfile,
      );
      
      // Save to local storage
      await _saveUserToStorage();
      
      _error = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to update profile: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  /// Set whether the user has completed onboarding
  Future<bool> setOnboardingComplete(bool complete) async {
    return updateProfile(hasCompletedOnboarding: complete);
  }
  
  /// Set the user's skin profile
  Future<bool> setSkinProfile(SkinProfile profile) async {
    return updateProfile(
      skinProfile: profile,
      hasCompletedOnboarding: true,
    );
  }
  
  /// Save the user to local storage
  Future<void> _saveUserToStorage() async {
    if (_currentUser == null) return;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'user',
      const JsonEncoder().convert(_currentUser!.toJson()),
    );
  }
}