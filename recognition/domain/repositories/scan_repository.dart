import 'package:image_picker/image_picker.dart';

import '../entities/scan_history_item.dart';

/// Repository for scan operations
abstract class ScanRepository {
  /// Scan a barcode
  Future<ScanHistoryItem> scanBarcode(String barcode);
  
  /// Extract ingredients from an image
  Future<List<String>> extractIngredientsFromImage(XFile image);
  
  /// Process an image for a scan
  Future<ScanHistoryItem> processImage(XFile image);
  
  /// Process text for a scan
  Future<ScanHistoryItem> processText(String text);
  
  /// Get scan history
  Future<List<ScanHistoryItem>> getScanHistory({int limit = 20});
  
  /// Add a scan to history
  Future<void> addScanToHistory(ScanHistoryItem scan);
  
  /// Update a scan
  Future<void> updateScan(ScanHistoryItem scan);
  
  /// Delete a scan
  Future<void> deleteScan(String barcode);
  
  /// Clear scan history
  Future<void> clearScanHistory();
  
  /// Get favorite scans
  Future<List<ScanHistoryItem>> getFavorites();
  
  /// Get scan by barcode
  Future<ScanHistoryItem?> getScanByBarcode(String barcode);
  
  /// Analyze ingredient conflicts
  Future<List<String>> analyzeIngredientConflicts(List<String> ingredients);
  
  /// Dispose resources
  void dispose();
}