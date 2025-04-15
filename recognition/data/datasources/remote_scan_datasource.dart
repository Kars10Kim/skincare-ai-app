import '../../domain/entities/scan_history_item.dart';

/// Interface for remote scan data source
abstract class RemoteScanDataSource {
  /// Get product information by barcode
  Future<ScanHistoryItem> getProductByBarcode(String barcode);
  
  /// Extract ingredients from an image
  Future<ScanHistoryItem> extractIngredientsFromImage(dynamic image);
  
  /// Extract ingredients from text
  Future<ScanHistoryItem> extractIngredientsFromText(String text);
  
  /// Add a scan to history
  Future<void> addScanToHistory(ScanHistoryItem scan);
  
  /// Update a scan
  Future<void> updateScan(ScanHistoryItem scan);
  
  /// Delete a scan
  Future<void> deleteScan(String barcode);
  
  /// Clear scan history
  Future<void> clearScanHistory();
  
  /// Analyze ingredient conflicts
  Future<List<String>> analyzeIngredientConflicts(List<String> ingredients);
  
  /// Dispose resources
  void dispose();
}