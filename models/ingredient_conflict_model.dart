/// Model for tracking conflicts between ingredients
class IngredientConflict {
  /// Unique identifier
  final int? id;
  
  /// First ingredient ID
  final int ingredientId;
  
  /// Second ingredient ID (that conflicts with the first)
  final int conflictingIngredientId;
  
  /// Severity level of the conflict
  final String severity;
  
  /// Description of the conflict
  final String description;
  
  /// Optional scientific reference for the conflict
  final String? reference;
  
  /// Name of the first ingredient
  final String? ingredientName;
  
  /// Name of the conflicting ingredient
  final String? conflictingIngredientName;
  
  /// Constructor
  IngredientConflict({
    this.id,
    required this.ingredientId,
    required this.conflictingIngredientId,
    required this.severity,
    required this.description,
    this.reference,
    this.ingredientName,
    this.conflictingIngredientName,
  });
  
  /// Create from JSON
  factory IngredientConflict.fromJson(Map<String, dynamic> json) {
    String? ingredientName;
    String? conflictingName;
    
    // Check if the related ingredient objects are included
    if (json['ingredient'] != null && json['ingredient'] is Map<String, dynamic>) {
      ingredientName = json['ingredient']['name'];
    }
    
    if (json['conflictingIngredient'] != null && 
        json['conflictingIngredient'] is Map<String, dynamic>) {
      conflictingName = json['conflictingIngredient']['name'];
    }
    
    return IngredientConflict(
      id: json['id'],
      ingredientId: json['ingredientId'] ?? json['ingredient_id'],
      conflictingIngredientId: json['conflictingIngredientId'] ?? 
          json['conflicting_ingredient_id'],
      severity: json['severity'],
      description: json['description'],
      reference: json['reference'],
      ingredientName: ingredientName,
      conflictingIngredientName: conflictingName,
    );
  }
  
  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'ingredientId': ingredientId,
      'conflictingIngredientId': conflictingIngredientId,
      'severity': severity,
      'description': description,
      if (reference != null) 'reference': reference,
    };
  }
  
  /// Create a copy with modified fields
  IngredientConflict copyWith({
    int? id,
    int? ingredientId,
    int? conflictingIngredientId,
    String? severity,
    String? description,
    String? reference,
    String? ingredientName,
    String? conflictingIngredientName,
  }) {
    return IngredientConflict(
      id: id ?? this.id,
      ingredientId: ingredientId ?? this.ingredientId,
      conflictingIngredientId: conflictingIngredientId ?? this.conflictingIngredientId,
      severity: severity ?? this.severity,
      description: description ?? this.description,
      reference: reference ?? this.reference,
      ingredientName: ingredientName ?? this.ingredientName,
      conflictingIngredientName: conflictingIngredientName ?? this.conflictingIngredientName,
    );
  }
}

/// Helper class for simplified conflict data 
/// (used when returning conflicts between ingredients in a product)
class IngredientConflictSimplified {
  /// First ingredient name
  final String ingredient;
  
  /// Second ingredient name
  final String conflictingIngredient;
  
  /// Severity level
  final String severity;
  
  /// Description of the conflict
  final String description;
  
  /// Scientific reference if available
  final String? reference;
  
  /// Constructor
  IngredientConflictSimplified({
    required this.ingredient,
    required this.conflictingIngredient,
    required this.severity,
    required this.description,
    this.reference,
  });
  
  /// Create from JSON
  factory IngredientConflictSimplified.fromJson(
    Map<String, dynamic> json, 
    String ingredientName
  ) {
    return IngredientConflictSimplified(
      ingredient: ingredientName,
      conflictingIngredient: json['ingredient'],
      severity: json['severity'],
      description: json['description'],
      reference: json['reference'],
    );
  }
  
  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'ingredient': ingredient,
      'conflictingIngredient': conflictingIngredient,
      'severity': severity,
      'description': description,
      if (reference != null) 'reference': reference,
    };
  }
}