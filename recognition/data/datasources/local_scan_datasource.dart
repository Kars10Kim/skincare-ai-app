import '../../domain/entities/scan_history_item.dart';

/// Interface for local scan data source
abstract class LocalScanDataSource {
  /// Get scan history
  Future<List<ScanHistoryItem>> getScanHistory({int limit = 20});
  
  /// Add a scan to history
  Future<void> addScanToHistory(ScanHistoryItem scan);
  
  /// Update a scan in history
  Future<void> updateScan(ScanHistoryItem scan);
  
  /// Delete a scan from history
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