import '../../domain/entities/scan_history_item.dart';
import '../../domain/repositories/history_repository.dart';
import '../datasources/local_history_datasource.dart';

/// History repository implementation
class HistoryRepositoryImpl implements HistoryRepository {
  /// Local data source
  final LocalHistoryDataSource localDataSource;
  
  /// Create history repository implementation
  const HistoryRepositoryImpl({required this.localDataSource});
  
  @override
  Future<List<ScanHistoryItem>> getHistory() async {
    return await localDataSource.getHistory();
  }
  
  @override
  Future<ScanHistoryItem> addScanToHistory(ScanHistoryItem item) async {
    return await localDataSource.addScanToHistory(item);
  }
  
  @override
  Future<void> clearHistory() async {
    await localDataSource.clearHistory();
  }
  
  @override
  Future<ScanHistoryItem> updateScanNote(String scanId, String? note) async {
    return await localDataSource.updateScanNote(scanId, note);
  }
  
  @override
  Future<ScanHistoryItem> addTagsToScan(String scanId, List<String> tags) async {
    // This would require extending the data source, but for now we'll
    // get the scan, add the tags, and then update it
    final scans = await localDataSource.getHistory();
    final scan = scans.firstWhere((s) => s.id == scanId);
    
    final updatedTags = [...scan.tags, ...tags].toSet().toList();
    final updatedScan = scan.copyWith(tags: updatedTags);
    
    return await localDataSource.addScanToHistory(updatedScan);
  }
  
  @override
  Future<ScanHistoryItem> removeTagFromScan(String scanId, String tag) async {
    // This would require extending the data source, but for now we'll
    // get the scan, remove the tag, and then update it
    final scans = await localDataSource.getHistory();
    final scan = scans.firstWhere((s) => s.id == scanId);
    
    final updatedTags = scan.tags.where((t) => t != tag).toList();
    final updatedScan = scan.copyWith(tags: updatedTags);
    
    return await localDataSource.addScanToHistory(updatedScan);
  }
  
  @override
  Future<ScanHistoryItem> toggleFavorite(String scanId, bool isFavorite) async {
    return await localDataSource.toggleFavorite(scanId, isFavorite);
  }
}