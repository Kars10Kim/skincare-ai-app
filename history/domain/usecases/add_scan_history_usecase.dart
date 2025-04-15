import '../entities/scan_history_item.dart';
import '../repositories/history_repository.dart';

/// Add scan history use case
class AddScanHistoryUseCase {
  /// History repository
  final HistoryRepository repository;
  
  /// Create add scan history use case
  const AddScanHistoryUseCase({required this.repository});
  
  /// Execute use case
  Future<ScanHistoryItem> call(ScanHistoryItem item) async {
    return await repository.addScanToHistory(item);
  }
}