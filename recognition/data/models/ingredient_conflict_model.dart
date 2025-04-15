import 'package:hive/hive.dart';

part 'ingredient_conflict_model.g.dart';

/// Conflict severity
@HiveType(typeId: 3)
enum ConflictSeverity {
  @HiveField(0)
  low,
  @HiveField(1)
  medium,
  @HiveField(2)
  high,
}

/// Ingredient conflict model for Hive
@HiveType(typeId: 2)
class IngredientConflictModel extends HiveObject {
  @HiveField(0)
  final String ingredientName;
  
  @HiveField(1)
  final String conflictingIngredient;
  
  @HiveField(2)
  final String description;
  
  @HiveField(3)
  final ConflictSeverity severity;
  
  @HiveField(4)
  final List<String>? sources;
  
  @HiveField(5)
  final String? recommendation;
  
  /// Create ingredient conflict model
  IngredientConflictModel({
    required this.ingredientName,
    required this.conflictingIngredient,
    required this.description,
    required this.severity,
    this.sources,
    this.recommendation,
  });
}