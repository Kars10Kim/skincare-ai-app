import '../entities/scan_history_item.dart';
import '../repositories/history_repository.dart';

/// Get history use case
class GetHistoryUseCase {
  /// History repository
  final HistoryRepository repository;
  
  /// Create get history use case
  const GetHistoryUseCase({required this.repository});
  
  /// Execute use case
  Future<List<ScanHistoryItem>> call() async {
    return await repository.getHistory();
  }
}