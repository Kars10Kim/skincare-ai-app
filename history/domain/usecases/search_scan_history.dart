import '../entities/scan_history_item.dart';
import '../repositories/scan_history_repository.dart';

/// Search scan history use case
class SearchScanHistory {
  /// Scan history repository
  final ScanHistoryRepository repository;
  
  /// Create search scan history use case
  SearchScanHistory(this.repository);
  
  /// Execute use case
  Future<List<ScanHistoryItem>> call({
    required String userId,
    required String query,
    bool favoritesOnly = false,
  }) {
    return repository.searchScanHistory(
      userId: userId,
      query: query,
      favoritesOnly: favoritesOnly,
    );
  }
}