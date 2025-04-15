/// For categorizing ingredients based on their type
enum IngredientCategory {
  acid,
  vitamin,
  oil,
  plantExtract,
  alcohol,
  preservative,
  antioxidant,
  fragrance,
  colorant,
  surfactant,
  emollient,
  humectant,
  other,
}

extension IngredientCategoryExtension on IngredientCategory {
  String get displayName {
    switch (this) {
      case IngredientCategory.acid:
        return 'Acid';
      case IngredientCategory.vitamin:
        return 'Vitamin';
      case IngredientCategory.oil:
        return 'Oil';
      case IngredientCategory.plantExtract:
        return 'Plant Extract';
      case IngredientCategory.alcohol:
        return 'Alcohol';
      case IngredientCategory.preservative:
        return 'Preservative';
      case IngredientCategory.antioxidant:
        return 'Antioxidant';
      case IngredientCategory.fragrance:
        return 'Fragrance';
      case IngredientCategory.colorant:
        return 'Colorant';
      case IngredientCategory.surfactant:
        return 'Surfactant';
      case IngredientCategory.emollient:
        return 'Emollient';
      case IngredientCategory.humectant:
        return 'Humectant';
      case IngredientCategory.other:
        return 'Other';
    }
  }
}

/// Severity levels for ingredient conflicts
enum ConflictSeverity {
  mild,
  moderate,
  severe,
  critical;
  
  /// Get a descriptive name for this severity level
  String get displayName {
    switch (this) {
      case ConflictSeverity.mild:
        return 'Mild';
      case ConflictSeverity.moderate:
        return 'Moderate';
      case ConflictSeverity.severe:
        return 'Severe';
      case ConflictSeverity.critical:
        return 'Critical';
    }
  }
  
  /// Get a score value (0-100) for this severity level
  int get score {
    switch (this) {
      case ConflictSeverity.mild:
        return 75;
      case ConflictSeverity.moderate:
        return 50;
      case ConflictSeverity.severe:
        return 25;
      case ConflictSeverity.critical:
        return 0;
    }
  }
  
  /// Parse a severity string into an enum value
  static ConflictSeverity fromString(String value) {
    switch (value.toLowerCase()) {
      case 'mild':
        return ConflictSeverity.mild;
      case 'moderate':
        return ConflictSeverity.moderate;
      case 'severe':
        return ConflictSeverity.severe;
      case 'critical':
        return ConflictSeverity.critical;
      default:
        return ConflictSeverity.moderate; // Default value
    }
  }
}