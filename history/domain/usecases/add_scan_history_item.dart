import '../entities/scan_history_item.dart';
import '../repositories/scan_history_repository.dart';

/// Add scan history item use case
class AddScanHistoryItem {
  /// Scan history repository
  final ScanHistoryRepository repository;
  
  /// Create add scan history item use case
  AddScanHistoryItem(this.repository);
  
  /// Execute use case
  Future<void> call({
    required String userId,
    required ScanHistoryItem item,
  }) {
    return repository.addScanHistoryItem(
      userId: userId,
      item: item,
    );
  }
}