import '../entities/scan_history_item.dart';
import '../repositories/history_repository.dart';

/// Update scan note use case
class UpdateScanNoteUseCase {
  /// History repository
  final HistoryRepository repository;
  
  /// Create update scan note use case
  const UpdateScanNoteUseCase({required this.repository});
  
  /// Execute use case
  Future<ScanHistoryItem> call(String scanId, String? note) async {
    return await repository.updateScanNote(scanId, note);
  }
}