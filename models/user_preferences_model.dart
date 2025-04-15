import 'dart:convert';

/// User preferences model for storing user-specific settings and preferences
class UserPreferences {
  /// Unique identifier
  final int? id;
  
  /// User ID if linked to a user account
  final int? userId;
  
  /// User's skin type
  final String skinType;
  
  /// List of user's skin concerns
  final List<String> skinConcerns;
  
  /// List of user's allergies
  final List<String> allergies;
  
  /// List of user's preferred brands
  final List<String>? preferredBrands;
  
  /// List of ingredients user wants to avoid
  final List<String>? avoidIngredients;
  
  /// Whether onboarding is completed
  final bool onboardingCompleted;
  
  /// Last update timestamp
  final DateTime? updatedAt;
  
  /// Create a new user preferences instance
  UserPreferences({
    this.id,
    this.userId,
    required this.skinType,
    required this.skinConcerns,
    required this.allergies,
    this.preferredBrands,
    this.avoidIngredients,
    this.onboardingCompleted = false,
    this.updatedAt,
  });
  
  /// Create a user preferences instance from JSON
  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      id: json['id'],
      userId: json['userId'],
      skinType: json['skinType'] ?? 'Normal',
      skinConcerns: _parseStringList(json['skinConcerns']),
      allergies: _parseStringList(json['allergies']),
      preferredBrands: json['preferredBrands'] != null 
          ? _parseStringList(json['preferredBrands']) 
          : null,
      avoidIngredients: json['avoidIngredients'] != null 
          ? _parseStringList(json['avoidIngredients']) 
          : null,
      onboardingCompleted: json['onboardingCompleted'] ?? false,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : null,
    );
  }
  
  /// Convert user preferences to JSON
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (userId != null) 'userId': userId,
      'skinType': skinType,
      'skinConcerns': skinConcerns,
      'allergies': allergies,
      if (preferredBrands != null) 'preferredBrands': preferredBrands,
      if (avoidIngredients != null) 'avoidIngredients': avoidIngredients,
      'onboardingCompleted': onboardingCompleted,
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }
  
  /// Create a copy of this preferences with updated fields
  UserPreferences copyWith({
    int? id,
    int? userId,
    String? skinType,
    List<String>? skinConcerns,
    List<String>? allergies,
    List<String>? preferredBrands,
    List<String>? avoidIngredients,
    bool? onboardingCompleted,
    DateTime? updatedAt,
  }) {
    return UserPreferences(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      skinType: skinType ?? this.skinType,
      skinConcerns: skinConcerns ?? this.skinConcerns,
      allergies: allergies ?? this.allergies,
      preferredBrands: preferredBrands ?? this.preferredBrands,
      avoidIngredients: avoidIngredients ?? this.avoidIngredients,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
  
  /// Helper method to parse string list from various formats
  static List<String> _parseStringList(dynamic value) {
    if (value == null) {
      return [];
    } else if (value is List) {
      return value.map((item) => item.toString()).toList();
    } else if (value is String) {
      try {
        // Try to parse as JSON array
        final List<dynamic> parsed = jsonDecode(value);
        return parsed.map((item) => item.toString()).toList();
      } catch (_) {
        // If not a JSON array, split by commas
        return value.split(',').map((s) => s.trim()).toList();
      }
    }
    return [];
  }
  
  /// Get empty preferences instance with default values
  static UserPreferences empty() {
    return UserPreferences(
      skinType: 'Normal',
      skinConcerns: [],
      allergies: [],
      onboardingCompleted: false,
    );
  }
}