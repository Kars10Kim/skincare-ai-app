import '../entities/scientific_reference.dart';
import '../repositories/product_analysis_repository.dart';

/// Use case to validate scientific claims about ingredients
class ValidateScientificClaims {
  /// Product analysis repository
  final ProductAnalysisRepository repository;
  
  /// Create use case
  ValidateScientificClaims({
    required this.repository,
  });
  
  /// Validate scientific claims for a specific ingredient
  Future<List<ScientificReference>> validateIngredient(String ingredient) async {
    // Get detailed ingredient info from repository
    final analyzedIngredient = await repository.getIngredientInfo(ingredient);
    
    if (analyzedIngredient == null) {
      return [];
    }
    
    // Get conflicts for the ingredient
    final conflicts = await repository.getConflictsForIngredients([ingredient]);
    
    // Extract and validate scientific references from conflicts
    final references = <ScientificReference>[];
    
    for (final conflict in conflicts) {
      references.addAll(conflict.scientificReferences);
    }
    
    // Verify the references (this would normally call an external API)
    // For now, we'll just return the references as is
    
    return references;
  }
  
  /// Validate scientific claims for multiple ingredients
  Future<Map<String, List<ScientificReference>>> validateIngredients(
    List<String> ingredients,
  ) async {
    final result = <String, List<ScientificReference>>{};
    
    for (final ingredient in ingredients) {
      result[ingredient] = await validateIngredient(ingredient);
    }
    
    return result;
  }
}