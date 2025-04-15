import 'ingredient_category.dart';
import 'ingredient_conflict.dart';

/// Represents a skincare ingredient with properties and category
class Ingredient {
  final String name;
  final String category;
  final List<String>? functions;
  final Map<String, dynamic>? properties;
  final List<String>? conflicts;

  const Ingredient({
    required this.name,
    required this.category,
    this.functions,
    this.properties,
    this.conflicts,
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      name: json['name'] as String,
      category: json['category'] as String,
      functions: json['functions'] != null 
          ? List<String>.from(json['functions']) 
          : null,
      properties: json['properties'] as Map<String, dynamic>?,
      conflicts: json['conflicts'] != null 
          ? List<String>.from(json['conflicts']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'category': category,
      if (functions != null) 'functions': functions,
      if (properties != null) 'properties': properties,
      if (conflicts != null) 'conflicts': conflicts,
    };
  }
  
  /// Create a copy of this ingredient with updated fields
  Ingredient copyWith({
    String? name,
    String? category,
    List<String>? functions,
    Map<String, dynamic>? properties,
    List<String>? conflicts,
  }) {
    return Ingredient(
      name: name ?? this.name,
      category: category ?? this.category,
      functions: functions ?? this.functions,
      properties: properties ?? this.properties,
      conflicts: conflicts ?? this.conflicts,
    );
  }
}