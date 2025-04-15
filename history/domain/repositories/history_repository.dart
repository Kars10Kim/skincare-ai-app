import '../entities/scan_history_item.dart';

/// History repository interface
abstract class HistoryRepository {
  /// Get scan history items
  Future<List<ScanHistoryItem>> getHistory();
  
  /// Add a scan to history
  Future<ScanHistoryItem> addScanToHistory(ScanHistoryItem item);
  
  /// Clear scan history
  Future<void> clearHistory();
  
  /// Update scan note
  Future<ScanHistoryItem> updateScanNote(String scanId, String? note);
  
  /// Add tags to a scan item
  Future<ScanHistoryItem> addTagsToScan(String scanId, List<String> tags);
  
  /// Remove tags from a scan item
  Future<ScanHistoryItem> removeTagFromScan(String scanId, String tag);
  
  /// Toggle favorite status
  Future<ScanHistoryItem> toggleFavorite(String scanId, bool isFavorite);
}