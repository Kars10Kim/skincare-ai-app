import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import '../../domain/entities/ingredient_conflict.dart';
import '../../domain/entities/product_analysis.dart';
import '../../domain/repositories/product_analysis_repository.dart';
import '../../../recognition/domain/entities/scan_history_item.dart';
import '../datasources/ingredient_database.dart';
import '../datasources/scientific_reference_datasource.dart';

/// Implementation of product analysis repository
class ProductAnalysisRepositoryImpl implements ProductAnalysisRepository {
  /// Ingredient database
  final IngredientDatabase _ingredientDb;
  
  /// Scientific reference data source
  final ScientificReferenceDataSource _referenceDataSource;
  
  /// Box name for analyses
  static const String _analysesBox = 'product_analyses';
  
  /// Box name for favorites
  static const String _favoritesBox = 'favorite_analyses';
  
  /// Box for analyses
  final Box _analyses;
  
  /// Box for favorites
  final Box _favorites;
  
  /// Create product analysis repository implementation
  ProductAnalysisRepositoryImpl({
    IngredientDatabase? ingredientDb,
    ScientificReferenceDataSource? referenceDataSource,
    Box? analyses,
    Box? favorites,
  }) : _ingredientDb = ingredientDb ?? IngredientDatabase(),
       _referenceDataSource = referenceDataSource ?? ScientificReferenceDataSource(),
       _analyses = analyses ?? Hive.box(_analysesBox),
       _favorites = favorites ?? Hive.box(_favoritesBox);
  
  /// Initialize the repository
  static Future<void> initialize() async {
    try {
      await Hive.openBox(_analysesBox);
      await Hive.openBox(_favoritesBox);
      await IngredientDatabase.initialize();
      await ScientificReferenceDataSource.initialize();
    } catch (e) {
      debugPrint('Error initializing product analysis repository: $e');
      rethrow;
    }
  }
  
  @override
  Future<ProductAnalysis> analyzeProductSafety(ScanHistoryItem scan) async {
    try {
      // Get analyzed ingredients
      final analyzedIngredients = <AnalyzedIngredient>[];
      
      for (final ingredient in scan.ingredients) {
        final analyzedIngredient = await _ingredientDb.getIngredientInfo(ingredient);
        
        if (analyzedIngredient != null) {
          analyzedIngredients.add(analyzedIngredient);
        } else {
          // If ingredient not found in database, add a basic entry
          analyzedIngredients.add(
            AnalyzedIngredient(
              name: ingredient,
              hasConflict: false,
            ),
          );
        }
      }
      
      // Get conflicts for ingredients
      final conflicts = await _ingredientDb.getConflictsForIngredients(scan.ingredients);
      
      // Calculate safety scores
      final safetyScore = _calculateSafetyScore(
        analyzedIngredients: analyzedIngredients,
        conflicts: conflicts,
      );
      
      // Create and save the analysis
      final analysis = ProductAnalysis(
        scanData: scan,
        ingredients: analyzedIngredients,
        conflicts: conflicts,
        safetyScore: safetyScore,
      );
      
      await saveAnalysis(analysis);
      
      return analysis;
    } catch (e) {
      debugPrint('Error analyzing product safety: $e');
      rethrow;
    }
  }
  
  @override
  Future<List<ProductAnalysis>> getRecentAnalyses({int limit = 10}) async {
    try {
      // Sort analyses by timestamp (descending)
      final keys = _analyses.keys.toList()
        ..sort((a, b) {
          final aData = _analyses.get(a);
          final bData = _analyses.get(b);
          
          final aTimestamp = DateTime.parse(aData['timestamp']);
          final bTimestamp = DateTime.parse(bData['timestamp']);
          
          return bTimestamp.compareTo(aTimestamp);
        });
      
      // Get the most recent analyses
      final limitedKeys = keys.take(limit).toList();
      
      // Map to ProductAnalysis objects
      final analyses = <ProductAnalysis>[];
      
      for (final key in limitedKeys) {
        final analysis = await _mapToProductAnalysis(_analyses.get(key));
        
        if (analysis != null) {
          analyses.add(analysis);
        }
      }
      
      return analyses;
    } catch (e) {
      debugPrint('Error getting recent analyses: $e');
      return [];
    }
  }
  
  @override
  Future<ProductAnalysis?> getAnalysisById(String id) async {
    try {
      if (!_analyses.containsKey(id)) {
        return null;
      }
      
      return await _mapToProductAnalysis(_analyses.get(id));
    } catch (e) {
      debugPrint('Error getting analysis by ID: $e');
      return null;
    }
  }
  
  @override
  Future<void> saveAnalysis(ProductAnalysis analysis) async {
    try {
      await _analyses.put(analysis.id, _productAnalysisToMap(analysis));
    } catch (e) {
      debugPrint('Error saving analysis: $e');
      rethrow;
    }
  }
  
  @override
  Future<void> updateAnalysis(ProductAnalysis analysis) async {
    try {
      await _analyses.put(analysis.id, _productAnalysisToMap(analysis));
    } catch (e) {
      debugPrint('Error updating analysis: $e');
      rethrow;
    }
  }
  
  @override
  Future<void> deleteAnalysis(String id) async {
    try {
      if (_analyses.containsKey(id)) {
        await _analyses.delete(id);
      }
      
      // Also remove from favorites if present
      if (_favorites.containsKey(id)) {
        await _favorites.delete(id);
      }
    } catch (e) {
      debugPrint('Error deleting analysis: $e');
      rethrow;
    }
  }
  
  @override
  Future<List<IngredientConflict>> getConflictsForIngredients(List<String> ingredients) async {
    try {
      return await _ingredientDb.getConflictsForIngredients(ingredients);
    } catch (e) {
      debugPrint('Error getting conflicts for ingredients: $e');
      return [];
    }
  }
  
  @override
  Future<AnalyzedIngredient?> getIngredientInfo(String ingredientName) async {
    try {
      return await _ingredientDb.getIngredientInfo(ingredientName);
    } catch (e) {
      debugPrint('Error getting ingredient info: $e');
      return null;
    }
  }
  
  @override
  Future<List<ProductAnalysis>> getFavoriteAnalyses() async {
    try {
      final favoriteIds = _favorites.keys.toList();
      final favorites = <ProductAnalysis>[];
      
      for (final id in favoriteIds) {
        if (_analyses.containsKey(id)) {
          final analysis = await _mapToProductAnalysis(_analyses.get(id));
          
          if (analysis != null) {
            favorites.add(analysis.copyWith(isFavorite: true));
          }
        }
      }
      
      // Sort by timestamp (descending)
      favorites.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      
      return favorites;
    } catch (e) {
      debugPrint('Error getting favorite analyses: $e');
      return [];
    }
  }
  
  @override
  Future<void> addToFavorites(String id) async {
    try {
      if (_analyses.containsKey(id)) {
        await _favorites.put(id, true);
        
        // Update the analysis as well
        final analysis = await getAnalysisById(id);
        
        if (analysis != null) {
          await updateAnalysis(analysis.copyWith(isFavorite: true));
        }
      }
    } catch (e) {
      debugPrint('Error adding analysis to favorites: $e');
      rethrow;
    }
  }
  
  @override
  Future<void> removeFromFavorites(String id) async {
    try {
      if (_favorites.containsKey(id)) {
        await _favorites.delete(id);
        
        // Update the analysis as well
        final analysis = await getAnalysisById(id);
        
        if (analysis != null) {
          await updateAnalysis(analysis.copyWith(isFavorite: false));
        }
      }
    } catch (e) {
      debugPrint('Error removing analysis from favorites: $e');
      rethrow;
    }
  }
  
  @override
  void dispose() {
    // No need to dispose of anything here as Hive boxes are closed by Hive
  }
  
  /// Calculate safety score for a product
  SafetyScore _calculateSafetyScore({
    required List<AnalyzedIngredient> analyzedIngredients,
    required List<IngredientConflict> conflicts,
  }) {
    // Base score starts at 100
    int overallScore = 100;
    int irritationScore = 100;
    int acneScore = 100;
    int sensitivityScore = 100;
    
    // Each high severity conflict reduces score by 20 points
    final highSeverityCount = conflicts
        .where((c) => c.severity == ConflictSeverity.high)
        .length;
    
    // Each medium severity conflict reduces score by 10 points
    final mediumSeverityCount = conflicts
        .where((c) => c.severity == ConflictSeverity.medium)
        .length;
    
    // Each low severity conflict reduces score by 5 points
    final lowSeverityCount = conflicts
        .where((c) => c.severity == ConflictSeverity.low)
        .length;
    
    // Calculate reduction based on conflict type
    int irritationReduction = 0;
    int acneReduction = 0;
    int sensitivityReduction = 0;
    
    for (final conflict in conflicts) {
      switch (conflict.type) {
        case ConflictType.irritation:
          switch (conflict.severity) {
            case ConflictSeverity.high:
              irritationReduction += 30;
              break;
            case ConflictSeverity.medium:
              irritationReduction += 15;
              break;
            case ConflictSeverity.low:
              irritationReduction += 5;
              break;
          }
          break;
        
        case ConflictType.allergic:
          switch (conflict.severity) {
            case ConflictSeverity.high:
              sensitivityReduction += 30;
              break;
            case ConflictSeverity.medium:
              sensitivityReduction += 15;
              break;
            case ConflictSeverity.low:
              sensitivityReduction += 5;
              break;
          }
          break;
          
        case ConflictType.chemical:
        case ConflictType.effectiveness:
        case ConflictType.environmental:
        case ConflictType.other:
          // These are accounted for in the overall reduction
          break;
      }
    }
    
    // Check for ingredients that may cause acne
    for (final ingredient in analyzedIngredients) {
      if (ingredient.concerns != null && 
          ingredient.concerns!.any((c) => c.toLowerCase().contains('acne') || 
                                         c.toLowerCase().contains('comedogenic'))) {
        acneReduction += 15;
      }
    }
    
    // Calculate overall score reduction
    final overallReduction = 
        (highSeverityCount * 20) + 
        (mediumSeverityCount * 10) + 
        (lowSeverityCount * 5);
    
    // Apply reductions, ensuring scores don't go below 0
    overallScore = (overallScore - overallReduction).clamp(0, 100);
    irritationScore = (irritationScore - irritationReduction).clamp(0, 100);
    acneScore = (acneScore - acneReduction).clamp(0, 100);
    sensitivityScore = (sensitivityScore - sensitivityReduction).clamp(0, 100);
    
    return SafetyScore(
      overall: overallScore,
      irritation: irritationScore,
      acne: acneScore,
      sensitivity: sensitivityScore,
    );
  }
  
  /// Map data to product analysis
  Future<ProductAnalysis?> _mapToProductAnalysis(Map<dynamic, dynamic>? data) async {
    if (data == null) return null;
    
    try {
      // Map scan data
      final scanData = ScanHistoryItem(
        id: data['scanData']['id'],
        productName: data['scanData']['productName'],
        brand: data['scanData']['brand'],
        barcode: data['scanData']['barcode'],
        imagePath: data['scanData']['imagePath'],
        rawIngredientsText: data['scanData']['rawIngredientsText'],
        ingredients: List<String>.from(data['scanData']['ingredients']),
        source: ScanSource.values[data['scanData']['source']],
        timestamp: DateTime.parse(data['scanData']['timestamp']),
        isAnalyzed: data['scanData']['isAnalyzed'] ?? true,
      );
      
      // Map ingredients
      final ingredients = <AnalyzedIngredient>[];
      
      for (final ingredientData in data['ingredients']) {
        ingredients.add(
          AnalyzedIngredient(
            name: ingredientData['name'],
            purpose: ingredientData['purpose'],
            ewgScore: ingredientData['ewgScore'],
            concerns: ingredientData['concerns'] != null 
                ? List<String>.from(ingredientData['concerns']) 
                : null,
            hasConflict: ingredientData['hasConflict'] ?? false,
          ),
        );
      }
      
      // Map conflicts
      final conflicts = <IngredientConflict>[];
      
      for (final conflictData in data['conflicts']) {
        final scientificReferences = <ScientificReference>[];
        
        // Map scientific references (if any)
        if (conflictData['scientificReferences'] != null) {
          for (final refData in conflictData['scientificReferences']) {
            scientificReferences.add(
              ScientificReference(
                doi: refData['doi'],
                pubMedId: refData['pubMedId'],
                title: refData['title'],
                authors: refData['authors'] != null 
                    ? List<String>.from(refData['authors']) 
                    : null,
                journal: refData['journal'],
                year: refData['year'],
                summary: refData['summary'],
                url: refData['url'],
                keywords: refData['keywords'] != null 
                    ? List<String>.from(refData['keywords']) 
                    : null,
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
      
      // Map safety score
      final safetyScore = SafetyScore(
        overall: data['safetyScore']['overall'],
        irritation: data['safetyScore']['irritation'],
        acne: data['safetyScore']['acne'],
        sensitivity: data['safetyScore']['sensitivity'],
      );
      
      return ProductAnalysis(
        id: data['id'],
        scanData: scanData,
        ingredients: ingredients,
        conflicts: conflicts,
        safetyScore: safetyScore,
        isFavorite: data['isFavorite'] ?? false,
        timestamp: DateTime.parse(data['timestamp']),
      );
    } catch (e) {
      debugPrint('Error mapping to product analysis: $e');
      return null;
    }
  }
  
  /// Map product analysis to data
  Map<String, dynamic> _productAnalysisToMap(ProductAnalysis analysis) {
    return {
      'id': analysis.id,
      'scanData': {
        'id': analysis.scanData.id,
        'productName': analysis.scanData.productName,
        'brand': analysis.scanData.brand,
        'barcode': analysis.scanData.barcode,
        'imagePath': analysis.scanData.imagePath,
        'rawIngredientsText': analysis.scanData.rawIngredientsText,
        'ingredients': analysis.scanData.ingredients,
        'source': analysis.scanData.source.index,
        'timestamp': analysis.scanData.timestamp.toIso8601String(),
        'isAnalyzed': analysis.scanData.isAnalyzed,
      },
      'ingredients': analysis.ingredients.map((ingredient) => {
        'name': ingredient.name,
        'purpose': ingredient.purpose,
        'ewgScore': ingredient.ewgScore,
        'concerns': ingredient.concerns,
        'hasConflict': ingredient.hasConflict,
      }).toList(),
      'conflicts': analysis.conflicts.map((conflict) => {
        'primaryIngredient': conflict.primaryIngredient,
        'secondaryIngredient': conflict.secondaryIngredient,
        'description': conflict.description,
        'severity': _severityToString(conflict.severity),
        'type': _conflictTypeToString(conflict.type),
        'scientificReferences': conflict.scientificReferences.map((reference) => {
          'doi': reference.doi,
          'pubMedId': reference.pubMedId,
          'title': reference.title,
          'authors': reference.authors,
          'journal': reference.journal,
          'year': reference.year,
          'summary': reference.summary,
          'url': reference.url,
          'keywords': reference.keywords,
          'verificationStatus': reference.verificationStatus.index,
        }).toList(),
        'recommendation': conflict.recommendation,
        'notes': conflict.notes,
      }).toList(),
      'safetyScore': {
        'overall': analysis.safetyScore.overall,
        'irritation': analysis.safetyScore.irritation,
        'acne': analysis.safetyScore.acne,
        'sensitivity': analysis.safetyScore.sensitivity,
      },
      'isFavorite': analysis.isFavorite,
      'timestamp': analysis.timestamp.toIso8601String(),
    };
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
  
  /// Convert severity to string
  String _severityToString(ConflictSeverity severity) {
    switch (severity) {
      case ConflictSeverity.high:
        return 'high';
      case ConflictSeverity.medium:
        return 'medium';
      case ConflictSeverity.low:
        return 'low';
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
  
  /// Convert conflict type to string
  String _conflictTypeToString(ConflictType type) {
    switch (type) {
      case ConflictType.chemical:
        return 'chemical';
      case ConflictType.irritation:
        return 'irritation';
      case ConflictType.allergic:
        return 'allergic';
      case ConflictType.effectiveness:
        return 'effectiveness';
      case ConflictType.environmental:
        return 'environmental';
      case ConflictType.other:
        return 'other';
    }
  }
  
  /// Parse verification status from string
  VerificationStatus _parseVerificationStatus(dynamic status) {
    if (status is int) {
      return VerificationStatus.values[status];
    }
    
    switch (status?.toString().toLowerCase()) {
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