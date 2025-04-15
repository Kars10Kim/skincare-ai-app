import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import '../../../../core/storage/hive_manager.dart';
import '../../domain/entities/scan_history_item.dart';
import '../models/scan_history_model.dart';
import '../models/ingredient_conflict_model.dart';
import 'local_scan_datasource.dart';

/// Implementation of local scan data source using Hive
class LocalScanDataSourceImpl implements LocalScanDataSource {
  /// Hive manager
  final HiveManager _hiveManager;
  
  /// Create local scan data source
  LocalScanDataSourceImpl({
    HiveManager? hiveManager,
  }) : _hiveManager = hiveManager ?? HiveManager();
  
  @override
  Future<List<ScanHistoryItem>> getScanHistory({int limit = 20}) async {
    try {
      final box = _hiveManager.scanHistoryBox;
      
      final models = box.values.toList();
      
      // Sort by timestamp descending
      models.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      
      // Apply limit
      final limitedModels = models.take(limit).toList();
      
      // Convert to entities
      return limitedModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      debugPrint('Error getting scan history: $e');
      return [];
    }
  }
  
  @override
  Future<void> addScanToHistory(ScanHistoryItem scan) async {
    try {
      final box = _hiveManager.scanHistoryBox;
      
      // Convert to model
      final model = ScanHistoryModel.fromEntity(scan);
      
      // Use barcode as key
      await box.put(scan.barcode, model);
    } catch (e) {
      debugPrint('Error adding scan to history: $e');
      rethrow;
    }
  }
  
  @override
  Future<void> updateScan(ScanHistoryItem scan) async {
    try {
      final box = _hiveManager.scanHistoryBox;
      
      // Check if scan exists
      if (!box.containsKey(scan.barcode)) {
        throw Exception('Scan not found');
      }
      
      // Convert to model
      final model = ScanHistoryModel.fromEntity(scan);
      
      // Update
      await box.put(scan.barcode, model);
    } catch (e) {
      debugPrint('Error updating scan: $e');
      rethrow;
    }
  }
  
  @override
  Future<void> deleteScan(String barcode) async {
    try {
      final box = _hiveManager.scanHistoryBox;
      
      // Delete
      await box.delete(barcode);
    } catch (e) {
      debugPrint('Error deleting scan: $e');
      rethrow;
    }
  }
  
  @override
  Future<void> clearScanHistory() async {
    try {
      final box = _hiveManager.scanHistoryBox;
      
      // Clear
      await box.clear();
    } catch (e) {
      debugPrint('Error clearing scan history: $e');
      rethrow;
    }
  }
  
  @override
  Future<List<ScanHistoryItem>> getFavorites() async {
    try {
      final box = _hiveManager.scanHistoryBox;
      
      // Get favorites
      final models = box.values.where((model) => model.isFavorite).toList();
      
      // Sort by timestamp descending
      models.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      
      // Convert to entities
      return models.map((model) => model.toEntity()).toList();
    } catch (e) {
      debugPrint('Error getting favorites: $e');
      return [];
    }
  }
  
  @override
  Future<ScanHistoryItem?> getScanByBarcode(String barcode) async {
    try {
      final box = _hiveManager.scanHistoryBox;
      
      // Get scan
      final model = box.get(barcode);
      
      // Convert to entity
      return model?.toEntity();
    } catch (e) {
      debugPrint('Error getting scan by barcode: $e');
      return null;
    }
  }
  
  @override
  Future<List<String>> analyzeIngredientConflicts(List<String> ingredients) async {
    try {
      final box = _hiveManager.ingredientConflictsBox;
      
      // Map of ingredient names to list of conflicts
      final Map<String, List<IngredientConflictModel>> conflictsMap = {};
      
      // Populate map
      for (final conflict in box.values) {
        if (!conflictsMap.containsKey(conflict.ingredientName)) {
          conflictsMap[conflict.ingredientName] = [];
        }
        
        conflictsMap[conflict.ingredientName]!.add(conflict);
      }
      
      // Find conflicts
      final conflicts = <String>[];
      
      for (final ingredient in ingredients) {
        final lowerIngredient = ingredient.toLowerCase();
        
        // Check if ingredient has conflicts
        for (final entry in conflictsMap.entries) {
          if (lowerIngredient == entry.key.toLowerCase()) {
            conflicts.add(ingredient);
            break;
          }
        }
      }
      
      return conflicts;
    } catch (e) {
      debugPrint('Error analyzing ingredient conflicts: $e');
      return [];
    }
  }
  
  @override
  void dispose() {
    // No resources to dispose
  }
}