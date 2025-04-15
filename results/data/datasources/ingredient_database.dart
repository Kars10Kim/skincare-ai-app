import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import '../../domain/entities/ingredient_conflict.dart';
import '../../domain/entities/product_analysis.dart';
import '../../domain/entities/scientific_reference.dart';

/// Local database for ingredient information
class IngredientDatabase {
  /// Box name for ingredients
  static const String _ingredientsBox = 'ingredients';
  
  /// Box name for conflicts
  static const String _conflictsBox = 'ingredient_conflicts';
  
  /// Box name for scientific references
  static const String _referencesBox = 'scientific_references';
  
  /// Box for ingredients
  final Box _ingredients;
  
  /// Box for conflicts
  final Box _conflicts;
  
  /// Box for scientific references
  final Box _references;
  
  /// Create ingredient database
  IngredientDatabase({
    Box? ingredients,
    Box? conflicts,
    Box? references,
  }) : _ingredients = ingredients ?? Hive.box(_ingredientsBox),
       _conflicts = conflicts ?? Hive.box(_conflictsBox),
       _references = references ?? Hive.box(_referencesBox);
  
  /// Initialize the database
  static Future<void> initialize() async {
    try {
      await Hive.openBox(_ingredientsBox);
      await Hive.openBox(_conflictsBox);
      await Hive.openBox(_referencesBox);
    } catch (e) {
      debugPrint('Error initializing ingredient database: $e');
      rethrow;
    }
  }
  
  /// Get ingredient information
  Future<AnalyzedIngredient?> getIngredientInfo(String name) async {
    try {
      final normalizedName = name.toLowerCase().trim();
      
      // Check if ingredient exists in the database
      if (!_ingredients.containsKey(normalizedName)) {
        return null;
      }
      
      final data = _ingredients.get(normalizedName);
      
      // Check if there are conflicts for this ingredient
      final hasConflict = _conflicts.values.any(
        (conflict) => conflict['primaryIngredient'].toString().toLowerCase() == normalizedName ||
            conflict['secondaryIngredient'].toString().toLowerCase() == normalizedName
      );
      
      return AnalyzedIngredient(
        name: name,
        purpose: data['purpose'],
        ewgScore: data['ewgScore'],
        concerns: data['concerns'] != null ? List<String>.from(data['concerns']) : null,
        hasConflict: hasConflict,
      );
    } catch (e) {
      debugPrint('Error getting ingredient info: $e');
      return null;
    }
  }
  
  /// Get conflicts for ingredients
  Future<List<IngredientConflict>> getConflictsForIngredients(List<String> ingredients) async {
    try {
      final normalizedIngredients = ingredients
          .map((i) => i.toLowerCase().trim())
          .toSet()
          .toList();
      
      final conflicts = <IngredientConflict>[];
      
      // Check each conflict in the database
      for (final conflictData in _conflicts.values) {
        final primaryIngredient = conflictData['primaryIngredient'].toString().toLowerCase();
        final secondaryIngredient = conflictData['secondaryIngredient']?.toString().toLowerCase();
        
        // Check if any of the ingredients are involved in this conflict
        final hasPrimary = normalizedIngredients.contains(primaryIngredient);
        final hasSecondary = secondaryIngredient != null &&
            normalizedIngredients.contains(secondaryIngredient);
        
        if (hasPrimary || hasSecondary) {
          // Get scientific references for this conflict
          final referenceIds = List<String>.from(conflictData['referenceIds'] ?? []);
          final scientificReferences = <ScientificReference>[];
          
          for (final id in referenceIds) {
            if (_references.containsKey(id)) {
              final refData = _references.get(id);
              
              scientificReferences.add(
                ScientificReference(
                  doi: refData['doi'],
                  pubMedId: refData['pubMedId'],
                  title: refData['title'],
                  authors: refData['authors'] != null ? List<String>.from(refData['authors']) : null,
                  journal: refData['journal'],
                  year: refData['year'],
                  summary: refData['summary'],
                  url: refData['url'],
                  keywords: refData['keywords'] != null ? List<String>.from(refData['keywords']) : null,
                  verificationStatus: _parseVerificationStatus(refData['verificationStatus']),
                ),
              );
            }
          }
          
          conflicts.add(
            IngredientConflict(
              primaryIngredient: conflictData['primaryIngredient'],
              secondaryIngredient: conflictData['secondaryIngredient'],
              description: conflictData['description'],
              severity: _parseSeverity(conflictData['severity']),
              type: _parseConflictType(conflictData['type']),
              scientificReferences: scientificReferences,
              recommendation: conflictData['recommendation'],
              notes: conflictData['notes'],
            ),
          );
        }
      }
      
      return conflicts;
    } catch (e) {
      debugPrint('Error getting conflicts for ingredients: $e');
      return [];
    }
  }
  
  /// Parse severity from string
  ConflictSeverity _parseSeverity(String? severity) {
    switch (severity?.toLowerCase()) {
      case 'high':
        return ConflictSeverity.high;
      case 'medium':
        return ConflictSeverity.medium;
      case 'low':
      default:
        return ConflictSeverity.low;
    }
  }
  
  /// Parse conflict type from string
  ConflictType _parseConflictType(String? type) {
    switch (type?.toLowerCase()) {
      case 'chemical':
        return ConflictType.chemical;
      case 'irritation':
        return ConflictType.irritation;
      case 'allergic':
        return ConflictType.allergic;
      case 'effectiveness':
        return ConflictType.effectiveness;
      case 'environmental':
        return ConflictType.environmental;
      case 'other':
      default:
        return ConflictType.other;
    }
  }
  
  /// Parse verification status from string
  VerificationStatus _parseVerificationStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'verified':
        return VerificationStatus.verified;
      case 'failed':
        return VerificationStatus.failed;
      case 'pending':
      default:
        return VerificationStatus.pending;
    }
  }
}