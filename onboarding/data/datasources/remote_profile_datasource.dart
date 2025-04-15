import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../domain/entities/skin_profile.dart';
import '../../domain/entities/survey_step.dart';
import '../models/default_survey_config.dart';

/// Abstract remote profile data source
abstract class RemoteProfileDataSource {
  /// Get user's skin profile
  Future<SkinProfile?> getSkinProfile();
  
  /// Save user's skin profile
  Future<void> saveSkinProfile(SkinProfile profile);
  
  /// Get survey configuration
  Future<List<SurveyStep>> getSurveyConfig();
  
  /// Check if user has completed onboarding
  Future<bool> hasCompletedOnboarding();
  
  /// Set onboarding completion status
  Future<void> setOnboardingComplete(bool completed);
  
  /// Dispose of any resources
  void dispose();
}

/// API-based implementation
class ApiProfileDataSource implements RemoteProfileDataSource {
  /// Base URL for API
  final String baseUrl;
  
  /// HTTP client
  final http.Client _client;
  
  /// User ID
  final String userId;
  
  /// API key
  final String? apiKey;
  
  /// Create an API profile data source
  ApiProfileDataSource({
    required this.baseUrl,
    required this.userId,
    this.apiKey,
    http.Client? client,
  }) : _client = client ?? http.Client();
  
  @override
  Future<SkinProfile?> getSkinProfile() async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/users/$userId/profile'),
        headers: _getHeaders(),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return SkinProfile.fromJson(data);
      }
      
      return null;
    } catch (e) {
      // Handle network errors
      return null;
    }
  }
  
  @override
  Future<void> saveSkinProfile(SkinProfile profile) async {
    try {
      await _client.post(
        Uri.parse('$baseUrl/users/$userId/profile'),
        headers: _getHeaders(),
        body: json.encode(profile.toJson()),
      );
    } catch (e) {
      // Handle network errors
      rethrow;
    }
  }
  
  @override
  Future<List<SurveyStep>> getSurveyConfig() async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/survey-config'),
        headers: _getHeaders(),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final stepsJson = data['steps'] as List<dynamic>;
        
        return stepsJson
            .map((stepJson) => SurveyStep.fromJson(stepJson))
            .toList();
      }
      
      // Return empty list if API call fails
      return [];
    } catch (e) {
      // Return empty list for any network errors
      return [];
    }
  }
  
  @override
  Future<bool> hasCompletedOnboarding() async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/users/$userId/onboarding-status'),
        headers: _getHeaders(),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return data['completed'] == true;
      }
      
      return false;
    } catch (e) {
      // Assume not completed if there's an error
      return false;
    }
  }
  
  @override
  Future<void> setOnboardingComplete(bool completed) async {
    try {
      await _client.post(
        Uri.parse('$baseUrl/users/$userId/onboarding-status'),
        headers: _getHeaders(),
        body: json.encode({'completed': completed}),
      );
    } catch (e) {
      // Handle network errors
      rethrow;
    }
  }
  
  @override
  void dispose() {
    _client.close();
  }
  
  /// Get headers for API requests
  Map<String, String> _getHeaders() {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    if (apiKey != null) {
      headers['Authorization'] = 'Bearer $apiKey';
    }
    
    return headers;
  }
}

/// Mock implementation for testing or development
class MockProfileDataSource implements RemoteProfileDataSource {
  @override
  Future<SkinProfile?> getSkinProfile() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    return null;
  }
  
  @override
  Future<void> saveSkinProfile(SkinProfile profile) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
  }
  
  @override
  Future<List<SurveyStep>> getSurveyConfig() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Return default survey config
    return DefaultSurveyConfig.getSteps();
  }
  
  @override
  Future<bool> hasCompletedOnboarding() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    return false;
  }
  
  @override
  Future<void> setOnboardingComplete(bool completed) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
  }
  
  @override
  void dispose() {
    // Nothing to dispose
  }
}