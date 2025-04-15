/// Model for user's skin profile
class SkinProfile {
  /// Unique identifier
  final String id;
  
  /// User ID associated with this profile
  final String userId;
  
  /// Skin type (dry, oily, combination, normal, sensitive)
  final String skinType;
  
  /// Skin concerns (acne, aging, etc.)
  final List<String> concerns;
  
  /// Skin conditions (eczema, psoriasis, etc.)
  final List<String> conditions;
  
  /// Ingredients to avoid
  final List<String> avoidsIngredients;
  
  /// Preferred ingredients
  final List<String> preferredIngredients;
  
  /// Sensitivity level (low, medium, high)
  final String sensitivityLevel;
  
  /// When this profile was created
  final DateTime createdAt;
  
  /// When this profile was last updated
  final DateTime updatedAt;
  
  /// Create a skin profile
  const SkinProfile({
    required this.id,
    required this.userId,
    required this.skinType,
    this.concerns = const [],
    this.conditions = const [],
    this.avoidsIngredients = const [],
    this.preferredIngredients = const [],
    this.sensitivityLevel = 'medium',
    required this.createdAt,
    required this.updatedAt,
  });
  
  /// Create from JSON
  factory SkinProfile.fromJson(Map<String, dynamic> json) {
    return SkinProfile(
      id: json['id'] as String,
      userId: json['userId'] as String,
      skinType: json['skinType'] as String,
      concerns: (json['concerns'] as List?)?.cast<String>() ?? [],
      conditions: (json['conditions'] as List?)?.cast<String>() ?? [],
      avoidsIngredients: (json['avoidsIngredients'] as List?)?.cast<String>() ?? [],
      preferredIngredients: (json['preferredIngredients'] as List?)?.cast<String>() ?? [],
      sensitivityLevel: json['sensitivityLevel'] as String? ?? 'medium',
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
  
  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'skinType': skinType,
      'concerns': concerns,
      'conditions': conditions,
      'avoidsIngredients': avoidsIngredients,
      'preferredIngredients': preferredIngredients,
      'sensitivityLevel': sensitivityLevel,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
  
  /// Create a copy with updated values
  SkinProfile copyWith({
    String? id,
    String? userId,
    String? skinType,
    List<String>? concerns,
    List<String>? conditions,
    List<String>? avoidsIngredients,
    List<String>? preferredIngredients,
    String? sensitivityLevel,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SkinProfile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      skinType: skinType ?? this.skinType,
      concerns: concerns ?? this.concerns,
      conditions: conditions ?? this.conditions,
      avoidsIngredients: avoidsIngredients ?? this.avoidsIngredients,
      preferredIngredients: preferredIngredients ?? this.preferredIngredients,
      sensitivityLevel: sensitivityLevel ?? this.sensitivityLevel,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}