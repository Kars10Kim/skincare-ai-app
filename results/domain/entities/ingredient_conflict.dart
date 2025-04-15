import 'scientific_reference.dart';

/// Conflict severity
enum ConflictSeverity {
  /// Low severity
  low,
  
  /// Medium severity
  medium,
  
  /// High severity
  high,
}

/// Conflict type
enum ConflictType {
  /// Chemical conflict (e.g., pH incompatibility)
  chemical,
  
  /// Irritation conflict (e.g., multiple exfoliants)
  irritation,
  
  /// Allergic conflict (e.g., known allergens)
  allergic,
  
  /// Effectiveness conflict (e.g., one ingredient reduces effectiveness of another)
  effectiveness,
  
  /// Environmental conflict (e.g., photosensitivity)
  environmental,
  
  /// Other conflict type
  other,
}

/// Analyzed ingredient
class AnalyzedIngredient {
  /// Ingredient name
  final String name;
  
  /// Ingredient purpose
  final String? purpose;
  
  /// EWG score (1-10, with 1 being the safest)
  final int? ewgScore;
  
  /// Concerns about this ingredient
  final List<String>? concerns;
  
  /// Whether this ingredient has conflicts with other ingredients
  final bool hasConflict;

  /// Create analyzed ingredient
  AnalyzedIngredient({
    required this.name,
    this.purpose,
    this.ewgScore,
    this.concerns,
    this.hasConflict = false,
  });
}

/// Ingredient conflict
class IngredientConflict {
  /// Primary ingredient
  final String primaryIngredient;
  
  /// Secondary ingredient (may be null for single-ingredient issues)
  final String? secondaryIngredient;
  
  /// Conflict description
  final String description;
  
  /// Conflict severity
  final ConflictSeverity severity;
  
  /// Conflict type
  final ConflictType type;
  
  /// Scientific references for this conflict
  final List<ScientificReference> scientificReferences;
  
  /// Recommendation to resolve conflict
  final String? recommendation;
  
  /// Additional notes
  final String? notes;
  
  /// Create ingredient conflict
  IngredientConflict({
    required this.primaryIngredient,
    this.secondaryIngredient,
    required this.description,
    this.severity = ConflictSeverity.low,
    this.type = ConflictType.other,
    this.scientificReferences = const [],
    this.recommendation,
    this.notes,
  });
  
  /// Get conflict name
  String getConflictName() {
    if (secondaryIngredient != null) {
      return '$primaryIngredient + $secondaryIngredient';
    } else {
      return primaryIngredient;
    }
  }
  
  /// Get severity as string
  String getSeverityText() {
    switch (severity) {
      case ConflictSeverity.high:
        return 'High';
      case ConflictSeverity.medium:
        return 'Medium';
      case ConflictSeverity.low:
        return 'Low';
    }
  }
  
  /// Get type as string
  String getTypeText() {
    switch (type) {
      case ConflictType.chemical:
        return 'Chemical Incompatibility';
      case ConflictType.irritation:
        return 'Potential Irritation';
      case ConflictType.allergic:
        return 'Allergic Reaction Risk';
      case ConflictType.effectiveness:
        return 'Reduced Effectiveness';
      case ConflictType.environmental:
        return 'Environmental Factor';
      case ConflictType.other:
        return 'Other Conflict';
    }
  }
  
  /// Check if conflict has verified references
  bool get hasVerifiedReferences {
    return scientificReferences.any((ref) => ref.isValid);
  }
}