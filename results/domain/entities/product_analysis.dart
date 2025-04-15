import 'package:uuid/uuid.dart';

import 'ingredient_conflict.dart';
import '../../../recognition/domain/entities/scan_history_item.dart';

/// Safety score
class SafetyScore {
  /// Overall safety score (0-100)
  final int overall;
  
  /// Irritation score (0-100)
  final int irritation;
  
  /// Acne score (0-100)
  final int acne;
  
  /// Sensitivity score (0-100)
  final int sensitivity;
  
  /// Create safety score
  const SafetyScore({
    required this.overall,
    required this.irritation,
    required this.acne,
    required this.sensitivity,
  });
  
  /// Get overall safety rating
  String get safetyRating {
    if (overall >= 80) {
      return 'Very Safe';
    } else if (overall >= 60) {
      return 'Mostly Safe';
    } else if (overall >= 40) {
      return 'Moderate Risk';
    } else if (overall >= 20) {
      return 'High Risk';
    } else {
      return 'Very Unsafe';
    }
  }
}

/// Product analysis
class ProductAnalysis {
  /// Analysis ID
  final String id;
  
  /// Original scan data
  final ScanHistoryItem scanData;
  
  /// List of ingredients
  final List<AnalyzedIngredient> ingredients;
  
  /// List of conflicts
  final List<IngredientConflict> conflicts;
  
  /// Safety score
  final SafetyScore safetyScore;
  
  /// Whether this analysis is a favorite
  final bool isFavorite;
  
  /// Analysis timestamp
  final DateTime timestamp;
  
  /// Create product analysis
  ProductAnalysis({
    String? id,
    required this.scanData,
    required this.ingredients,
    required this.conflicts,
    required this.safetyScore,
    this.isFavorite = false,
    DateTime? timestamp,
  }) : id = id ?? const Uuid().v4(),
       timestamp = timestamp ?? DateTime.now();
  
  /// Create copy of product analysis with modified fields
  ProductAnalysis copyWith({
    String? id,
    ScanHistoryItem? scanData,
    List<AnalyzedIngredient>? ingredients,
    List<IngredientConflict>? conflicts,
    SafetyScore? safetyScore,
    bool? isFavorite,
    DateTime? timestamp,
  }) {
    return ProductAnalysis(
      id: id ?? this.id,
      scanData: scanData ?? this.scanData,
      ingredients: ingredients ?? this.ingredients,
      conflicts: conflicts ?? this.conflicts,
      safetyScore: safetyScore ?? this.safetyScore,
      isFavorite: isFavorite ?? this.isFavorite,
      timestamp: timestamp ?? this.timestamp,
    );
  }
  
  /// Get list of high severity conflicts
  List<IngredientConflict> get highSeverityConflicts {
    return conflicts.where((c) => c.severity == ConflictSeverity.high).toList();
  }
  
  /// Get list of medium severity conflicts
  List<IngredientConflict> get mediumSeverityConflicts {
    return conflicts.where((c) => c.severity == ConflictSeverity.medium).toList();
  }
  
  /// Get list of low severity conflicts
  List<IngredientConflict> get lowSeverityConflicts {
    return conflicts.where((c) => c.severity == ConflictSeverity.low).toList();
  }
  
  /// Calculate total number of conflicts
  int get totalConflicts => conflicts.length;
  
  /// Check if analysis has conflicts
  bool get hasConflicts => conflicts.isNotEmpty;
  
  /// Check if analysis has high severity conflicts
  bool get hasHighSeverityConflicts => highSeverityConflicts.isNotEmpty;
}