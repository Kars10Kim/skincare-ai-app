import '../entities/scan_history_item.dart';
import '../repositories/scan_history_repository.dart';

/// Get scan history use case
class GetScanHistory {
  /// Scan history repository
  final ScanHistoryRepository repository;
  
  /// Create get scan history use case
  GetScanHistory(this.repository);
  
  /// Execute use case
  Future<List<ScanHistoryItem>> call({required String userId}) {
    return repository.getScanHistory(userId: userId);
  }
}