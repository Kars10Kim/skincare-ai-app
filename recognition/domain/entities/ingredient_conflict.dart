import 'package:equatable/equatable.dart';

/// Conflict severity
enum ConflictSeverity {
  /// No conflict detected
  none,
  
  /// Low severity conflict
  low,
  
  /// Medium severity conflict
  medium,
  
  /// High severity conflict
  high,
}

/// Ingredient conflict
class IngredientConflict extends Equatable {
  /// Ingredient name
  final String ingredientName;
  
  /// Description of the conflict
  final String description;
  
  /// Severity of the conflict
  final ConflictSeverity severity;
  
  /// Source/reference for the conflict information
  final String? source;
  
  /// DOI (Digital Object Identifier) for research reference
  final String? doi;
  
  /// Recommended alternative ingredient
  final String? recommendedAlternative;
  
  /// Create ingredient conflict
  const IngredientConflict({
    required this.ingredientName,
    required this.description,
    required this.severity,
    this.source,
    this.doi,
    this.recommendedAlternative,
  });
  
  @override
  List<Object?> get props => [
    ingredientName,
    description,
    severity,
    source,
    doi,
    recommendedAlternative,
  ];
}