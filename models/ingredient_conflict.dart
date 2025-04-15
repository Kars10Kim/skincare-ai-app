/// Severity level of an ingredient conflict
enum ConflictSeverity {
  /// Low severity - minor potential issue
  low('Low'),
  
  /// Medium severity - moderate concern
  medium('Medium'),
  
  /// High severity - significant concern
  high('High');
  
  /// String representation
  final String value;
  
  /// Constructor
  const ConflictSeverity(this.value);
  
  @override
  String toString() => value;
}

/// Model representing a conflict between an ingredient and user profile
class IngredientConflict {
  /// Ingredient name
  final String ingredient;
  
  /// Severity of the conflict
  final ConflictSeverity severity;
  
  /// Reason for the conflict
  final String reason;
  
  /// Recommendation to mitigate the conflict
  final String recommendation;
  
  /// Scientific reference (if available)
  final String? reference;
  
  /// DOI for the reference (if available)
  final String? doi;
  
  /// Create an ingredient conflict
  const IngredientConflict({
    required this.ingredient,
    required this.severity,
    required this.reason,
    required this.recommendation,
    this.reference,
    this.doi,
  });
  
  /// Create from JSON
  factory IngredientConflict.fromJson(Map<String, dynamic> json) {
    return IngredientConflict(
      ingredient: json['ingredient'] as String,
      severity: ConflictSeverity.values.firstWhere(
        (s) => s.value.toLowerCase() == (json['severity'] as String).toLowerCase(),
        orElse: () => ConflictSeverity.low,
      ),
      reason: json['reason'] as String,
      recommendation: json['recommendation'] as String,
      reference: json['reference'] as String?,
      doi: json['doi'] as String?,
    );
  }
  
  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'ingredient': ingredient,
      'severity': severity.value,
      'reason': reason,
      'recommendation': recommendation,
      'reference': reference,
      'doi': doi,
    };
  }
}