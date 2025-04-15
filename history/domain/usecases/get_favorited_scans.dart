import '../entities/scan_history_item.dart';
import '../repositories/scan_history_repository.dart';

/// Get favorited scans use case
class GetFavoritedScans {
  /// Scan history repository
  final ScanHistoryRepository repository;
  
  /// Create get favorited scans use case
  GetFavoritedScans(this.repository);
  
  /// Execute use case
  Future<List<ScanHistoryItem>> call({required String userId}) {
    return repository.getFavoritedScans(userId: userId);
  }
}