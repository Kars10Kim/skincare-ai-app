/// Represents detailed information about a skincare ingredient
class IngredientInfo {
  /// Ingredient name
  final String name;
  
  /// Ingredient category (e.g., acid, retinol, vitamin_c)
  final String category;
  
  /// Safety rating (0-100)
  final int safetyRating;
  
  /// Description of the ingredient
  final String description;
  
  /// List of benefits
  final List<String> benefits;
  
  /// List of potential concerns
  final List<String> concerns;
  
  /// Citations to scientific literature (optional)
  final List<String>? citations;
  
  /// Create a new ingredient info instance
  const IngredientInfo({
    required this.name,
    required this.category,
    required this.safetyRating,
    required this.description,
    required this.benefits,
    required this.concerns,
    this.citations,
  });
  
  /// Create from JSON
  factory IngredientInfo.fromJson(Map<String, dynamic> json) {
    return IngredientInfo(
      name: json['name'] as String,
      category: json['category'] as String,
      safetyRating: json['safety_rating'] as int,
      description: json['description'] as String,
      benefits: List<String>.from(json['benefits'] ?? []),
      concerns: List<String>.from(json['concerns'] ?? []),
      citations: json['citations'] != null 
          ? List<String>.from(json['citations']) 
          : null,
    );
  }
  
  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'category': category,
      'safety_rating': safetyRating,
      'description': description,
      'benefits': benefits,
      'concerns': concerns,
      if (citations != null) 'citations': citations,
    };
  }
}

/// Severity of a conflict between ingredients
enum ConflictSeverity {
  /// Low severity - minimal potential for adverse effects
  low,
  
  /// Moderate severity - potential for reduced effectiveness or mild irritation
  moderate,
  
  /// High severity - potential for significant irritation or negative reactions
  high,
}

/// Represents a conflict between two ingredients
class IngredientConflict {
  /// First ingredient name
  final String ingredient1;
  
  /// Second ingredient name
  final String ingredient2;
  
  /// Severity of the conflict
  final ConflictSeverity severity;
  
  /// Reason for the conflict
  final String reason;
  
  /// Recommendation for how to handle the conflict
  final String recommendation;
  
  /// Citation to scientific literature (optional)
  final String? citation;
  
  /// Create a new ingredient conflict
  const IngredientConflict({
    required this.ingredient1,
    required this.ingredient2,
    required this.severity,
    required this.reason,
    required this.recommendation,
    this.citation,
  });
  
  /// Create from JSON
  factory IngredientConflict.fromJson(Map<String, dynamic> json) {
    return IngredientConflict(
      ingredient1: json['ingredient1'] as String,
      ingredient2: json['ingredient2'] as String,
      severity: ConflictSeverity.values.firstWhere(
        (e) => e.name == json['severity'],
        orElse: () => ConflictSeverity.low,
      ),
      reason: json['reason'] as String,
      recommendation: json['recommendation'] as String,
      citation: json['citation'] as String?,
    );
  }
  
  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'ingredient1': ingredient1,
      'ingredient2': ingredient2,
      'severity': severity.name,
      'reason': reason,
      'recommendation': recommendation,
      if (citation != null) 'citation': citation,
    };
  }
}

/// Result of analyzing a list of ingredients
class IngredientAnalysisResult {
  /// List of conflicts between ingredients
  final List<IngredientConflict> conflicts;
  
  /// Overall safety rating (0-100)
  final int safetyRating;
  
  /// Original list of ingredients
  final List<String> ingredients;
  
  /// When the analysis was performed
  final DateTime analyzedAt;
  
  /// Whether the analysis was performed offline
  final bool offlineMode;
  
  /// Error message, if any
  final String? error;
  
  /// Create a new analysis result
  const IngredientAnalysisResult({
    required this.conflicts,
    required this.safetyRating,
    required this.ingredients,
    required this.analyzedAt,
    this.offlineMode = false,
    this.error,
  });
  
  /// Get whether the analysis has any conflicts
  bool get hasConflicts => conflicts.isNotEmpty;
  
  /// Get whether there was an error analyzing the ingredients
  bool get hasError => error != null && error!.isNotEmpty;
  
  /// Get whether the product is generally safe to use
  /// 
  /// This is based on the safety rating and absence of high severity conflicts
  bool get isSafe {
    if (hasError || offlineMode) {
      return false; // Can't determine safety
    }
    
    // Check for high severity conflicts
    final hasHighSeverityConflicts = conflicts.any(
      (conflict) => conflict.severity == ConflictSeverity.high,
    );
    
    return safetyRating >= 70 && !hasHighSeverityConflicts;
  }
  
  /// Create from JSON
  factory IngredientAnalysisResult.fromJson(Map<String, dynamic> json) {
    return IngredientAnalysisResult(
      conflicts: (json['conflicts'] as List)
          .map((c) => IngredientConflict.fromJson(c as Map<String, dynamic>))
          .toList(),
      safetyRating: json['safety_rating'] as int,
      ingredients: List<String>.from(json['ingredients']),
      analyzedAt: DateTime.parse(json['analyzed_at'] as String),
      offlineMode: json['offline_mode'] as bool? ?? false,
      error: json['error'] as String?,
    );
  }
  
  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'conflicts': conflicts.map((c) => c.toJson()).toList(),
      'safety_rating': safetyRating,
      'ingredients': ingredients,
      'analyzed_at': analyzedAt.toIso8601String(),
      'offline_mode': offlineMode,
      if (error != null) 'error': error,
    };
  }
}