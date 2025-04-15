import '../entities/scan_history_item.dart';

/// Scan history repository
abstract class ScanHistoryRepository {
  /// Get scan history for user
  Future<List<ScanHistoryItem>> getScanHistory({required String userId});
  
  /// Get favorited scans for user
  Future<List<ScanHistoryItem>> getFavoritedScans({required String userId});
  
  /// Search scan history
  Future<List<ScanHistoryItem>> searchScanHistory({
    required String userId,
    required String query,
    bool favoritesOnly = false,
  });
  
  /// Add scan history item
  Future<void> addScanHistoryItem({
    required String userId,
    required ScanHistoryItem item,
  });
  
  /// Toggle favorite status
  Future<void> toggleFavoriteStatus({
    required String userId,
    required String id,
    required bool isFavorite,
  });
  
  /// Update scan notes
  Future<void> updateNotes({
    required String userId,
    required String id,
    String? notes,
  });
  
  /// Add tag to scan
  Future<void> addTag({
    required String userId,
    required String id,
    required String tag,
  });
  
  /// Remove tag from scan
  Future<void> removeTag({
    required String userId,
    required String id,
    required String tag,
  });
  
  /// Delete scan history item
  Future<void> deleteScanHistoryItem({
    required String userId,
    required String id,
  });
  
  /// Clear scan history
  Future<void> clearScanHistory({required String userId});
}