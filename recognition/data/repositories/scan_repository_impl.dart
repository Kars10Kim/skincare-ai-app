import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import '../../domain/entities/scan_error.dart';
import '../../domain/entities/scan_history_item.dart';
import '../../domain/repositories/scan_repository.dart';
import '../datasources/local_scan_datasource.dart';
import '../datasources/remote_scan_datasource.dart';
import '../../utils/ingredient_parser.dart';

/// Implementation of ScanRepository
class ScanRepositoryImpl implements ScanRepository {
  /// Local data source
  final LocalScanDataSource localDataSource;
  
  /// Remote data source
  final RemoteScanDataSource remoteDataSource;
  
  /// Create scan repository
  ScanRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });
  
  @override
  Future<ScanHistoryItem> scanBarcode(String barcode) async {
    try {
      // First check local cache
      final localScan = await localDataSource.getScanByBarcode(barcode);
      if (localScan != null) {
        return localScan;
      }
      
      // If not in cache, fetch from remote
      final remoteResult = await remoteDataSource.getProductByBarcode(barcode);
      
      // Cache the result
      await localDataSource.addScanToHistory(remoteResult);
      
      return remoteResult;
    } catch (e) {
      debugPrint('Error scanning barcode: $e');
      throw ScanError.barcode('Failed to scan barcode: ${e.toString()}');
    }
  }
  
  @override
  Future<List<String>> extractIngredientsFromImage(XFile image) async {
    try {
      // Extract ingredients from image using OCR
      final scanResult = await remoteDataSource.extractIngredientsFromImage(image);
      
      if (scanResult.ingredients == null || scanResult.ingredients!.isEmpty) {
        // If remote extraction fails, try to extract locally
        final text = await _extractTextFromImage(image);
        return IngredientParser.extractIngredients(text);
      }
      
      return scanResult.ingredients!;
    } catch (e) {
      debugPrint('Error extracting ingredients from image: $e');
      throw ScanError.recognition('Failed to extract ingredients: ${e.toString()}');
    }
  }
  
  /// Extract text from image (delegated to remote or OCR package)
  Future<String> _extractTextFromImage(XFile image) async {
    try {
      // This should call a text recognition service or package
      final scanResult = await remoteDataSource.extractIngredientsFromImage(image);
      // Normally extract the text from the result, but for now just return empty
      return '';
    } catch (e) {
      debugPrint('Error extracting text from image: $e');
      return '';
    }
  }
  
  @override
  Future<ScanHistoryItem> processImage(XFile image) async {
    try {
      // Extract ingredients from image
      final scanResult = await remoteDataSource.extractIngredientsFromImage(image);
      
      // Save to history
      await localDataSource.addScanToHistory(scanResult);
      
      return scanResult;
    } catch (e) {
      debugPrint('Error processing image: $e');
      throw ScanError.recognition('Failed to process image: ${e.toString()}');
    }
  }
  
  @override
  Future<ScanHistoryItem> processText(String text) async {
    try {
      // Extract ingredients from text using remote service or local parsing
      final scanResult = await remoteDataSource.extractIngredientsFromText(text);
      
      // Save to history
      await localDataSource.addScanToHistory(scanResult);
      
      return scanResult;
    } catch (e) {
      // If remote fails or doesn't exist, extract locally
      final ingredients = IngredientParser.extractIngredients(text);
      
      if (ingredients.isEmpty) {
        throw ScanError.validation('No ingredients found in the text');
      }
      
      // Create a scan history item
      final scanItem = ScanHistoryItem(
        barcode: 'text_scan_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Text Scan',
        ingredients: ingredients,
        timestamp: DateTime.now(),
        scanType: ScanType.text,
      );
      
      // Save to history
      await localDataSource.addScanToHistory(scanItem);
      
      return scanItem;
    }
  }
  
  @override
  Future<List<ScanHistoryItem>> getScanHistory({int limit = 20}) async {
    try {
      return await localDataSource.getScanHistory(limit: limit);
    } catch (e) {
      debugPrint('Error getting scan history: $e');
      throw ScanError.database('Failed to get scan history: ${e.toString()}');
    }
  }
  
  @override
  Future<void> addScanToHistory(ScanHistoryItem scan) async {
    try {
      await localDataSource.addScanToHistory(scan);
      
      // Sync with remote if available
      try {
        await remoteDataSource.addScanToHistory(scan);
      } catch (e) {
        // Ignore remote errors
        debugPrint('Error syncing scan to remote: $e');
      }
    } catch (e) {
      debugPrint('Error adding scan to history: $e');
      throw ScanError.database('Failed to add scan to history: ${e.toString()}');
    }
  }
  
  @override
  Future<void> updateScan(ScanHistoryItem scan) async {
    try {
      await localDataSource.updateScan(scan);
      
      // Sync with remote if available
      try {
        await remoteDataSource.updateScan(scan);
      } catch (e) {
        // Ignore remote errors
        debugPrint('Error syncing scan update to remote: $e');
      }
    } catch (e) {
      debugPrint('Error updating scan: $e');
      throw ScanError.database('Failed to update scan: ${e.toString()}');
    }
  }
  
  @override
  Future<void> deleteScan(String barcode) async {
    try {
      await localDataSource.deleteScan(barcode);
      
      // Sync with remote if available
      try {
        await remoteDataSource.deleteScan(barcode);
      } catch (e) {
        // Ignore remote errors
        debugPrint('Error syncing scan deletion to remote: $e');
      }
    } catch (e) {
      debugPrint('Error deleting scan: $e');
      throw ScanError.database('Failed to delete scan: ${e.toString()}');
    }
  }
  
  @override
  Future<void> clearScanHistory() async {
    try {
      await localDataSource.clearScanHistory();
      
      // Sync with remote if available
      try {
        await remoteDataSource.clearScanHistory();
      } catch (e) {
        // Ignore remote errors
        debugPrint('Error syncing scan history clearing to remote: $e');
      }
    } catch (e) {
      debugPrint('Error clearing scan history: $e');
      throw ScanError.database('Failed to clear scan history: ${e.toString()}');
    }
  }
  
  @override
  Future<List<ScanHistoryItem>> getFavorites() async {
    try {
      return await localDataSource.getFavorites();
    } catch (e) {
      debugPrint('Error getting favorites: $e');
      throw ScanError.database('Failed to get favorites: ${e.toString()}');
    }
  }
  
  @override
  Future<ScanHistoryItem?> getScanByBarcode(String barcode) async {
    try {
      return await localDataSource.getScanByBarcode(barcode);
    } catch (e) {
      debugPrint('Error getting scan by barcode: $e');
      throw ScanError.database('Failed to get scan by barcode: ${e.toString()}');
    }
  }
  
  @override
  Future<List<String>> analyzeIngredientConflicts(List<String> ingredients) async {
    try {
      // First try remote analysis
      try {
        return await remoteDataSource.analyzeIngredientConflicts(ingredients);
      } catch (e) {
        // If remote fails, use local
        debugPrint('Remote conflict analysis failed, using local: $e');
        return await localDataSource.analyzeIngredientConflicts(ingredients);
      }
    } catch (e) {
      debugPrint('Error analyzing ingredient conflicts: $e');
      throw ScanError.validation('Failed to analyze ingredient conflicts: ${e.toString()}');
    }
  }
  
  @override
  void dispose() {
    localDataSource.dispose();
    remoteDataSource.dispose();
  }
}