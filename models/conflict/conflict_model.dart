import 'package:flutter/foundation.dart';

/// Type of ingredient conflict
enum ConflictType {
  /// Combination can cause skin irritation
  irritation,
  
  /// Combination reduces effectiveness
  neutralization,
  
  /// Combination can cause excessive dryness
  dryness,
  
  /// Combination can cause oxidation
  oxidation,
  
  /// Combination can increase sensitivity
  sensitivity,
  
  /// Combination can cause pH incompatibility
  ph,
  
  /// Conflict not categorized
  other
}

/// Extension to provide display names for ConflictType
extension ConflictTypeExtension on ConflictType {
  /// Get display name for conflict type
  String get displayName {
    switch (this) {
      case ConflictType.irritation:
        return 'Irritation';
      case ConflictType.neutralization:
        return 'Neutralization';
      case ConflictType.dryness:
        return 'Excessive Dryness';
      case ConflictType.oxidation:
        return 'Oxidation';
      case ConflictType.sensitivity:
        return 'Increased Sensitivity';
      case ConflictType.ph:
        return 'pH Incompatibility';
      case ConflictType.other:
        return 'Other Conflict';
    }
  }
}

/// Model representing an ingredient conflict
class Conflict {
  /// Unique identifier
  final String id;
  
  /// Name of the conflict
  final String name;
  
  /// Conflict type
  final ConflictType type;
  
  /// Severity level (low, medium, high)
  final String severity;
  
  /// List of ingredients involved in the conflict
  final List<String> ingredients;
  
  /// Detailed description of the conflict
  final String description;
  
  /// Recommendation for resolving the conflict
  final String? recommendation;
  
  /// Scientific evidence level (clinical, lab, anecdotal)
  final String? evidence;
  
  /// Digital Object Identifier (DOI) for scientific reference
  final String? doi;
  
  /// URL for more information
  final String? url;
  
  /// Data source
  final String? source;
  
  /// Create a new conflict
  const Conflict({
    required this.id,
    required this.name,
    required this.type,
    required this.severity,
    required this.ingredients,
    required this.description,
    this.recommendation,
    this.evidence,
    this.doi,
    this.url,
    this.source,
  });
  
  /// Create from JSON
  factory Conflict.fromJson(Map<String, dynamic> json) {
    return Conflict(
      id: json['id'] as String,
      name: json['name'] as String,
      type: _parseConflictType(json['type'] as String),
      severity: json['severity'] as String,
      ingredients: (json['ingredients'] as List).cast<String>(),
      description: json['description'] as String,
      recommendation: json['recommendation'] as String?,
      evidence: json['evidence'] as String?,
      doi: json['doi'] as String?,
      url: json['url'] as String?,
      source: json['source'] as String?,
    );
  }
  
  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.toString().split('.').last,
      'severity': severity,
      'ingredients': ingredients,
      'description': description,
      'recommendation': recommendation,
      'evidence': evidence,
      'doi': doi,
      'url': url,
      'source': source,
    };
  }
  
  /// Convert to a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type.toString().split('.').last,
      'severity': severity,
      'ingredients': ingredients,
      'description': description,
      'recommendation': recommendation,
      'evidence': evidence,
      'doi': doi,
      'url': url,
      'source': source,
    };
  }
  
  /// Create a copy with updated values
  Conflict copyWith({
    String? id,
    String? name,
    ConflictType? type,
    String? severity,
    List<String>? ingredients,
    String? description,
    String? recommendation,
    String? evidence,
    String? doi,
    String? url,
    String? source,
  }) {
    return Conflict(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      severity: severity ?? this.severity,
      ingredients: ingredients ?? this.ingredients,
      description: description ?? this.description,
      recommendation: recommendation ?? this.recommendation,
      evidence: evidence ?? this.evidence,
      doi: doi ?? this.doi,
      url: url ?? this.url,
      source: source ?? this.source,
    );
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is Conflict &&
        other.id == id &&
        other.name == name &&
        other.type == type &&
        other.severity == severity &&
        listEquals(other.ingredients, ingredients) &&
        other.description == description &&
        other.recommendation == recommendation &&
        other.evidence == evidence &&
        other.doi == doi &&
        other.url == url &&
        other.source == source;
  }
  
  @override
  int get hashCode {
    return id.hashCode ^
      name.hashCode ^
      type.hashCode ^
      severity.hashCode ^
      ingredients.hashCode ^
      description.hashCode ^
      recommendation.hashCode ^
      evidence.hashCode ^
      doi.hashCode ^
      url.hashCode ^
      source.hashCode;
  }
}

/// Parse conflict type from string
ConflictType _parseConflictType(String typeStr) {
  switch (typeStr.toLowerCase()) {
    case 'irritation':
      return ConflictType.irritation;
    case 'neutralization':
      return ConflictType.neutralization;
    case 'dryness':
      return ConflictType.dryness;
    case 'oxidation':
      return ConflictType.oxidation;
    case 'sensitivity':
      return ConflictType.sensitivity;
    case 'ph':
      return ConflictType.ph;
    default:
      return ConflictType.other;
  }
}