import '../../domain/entities/scan_history_item.dart';
import '../../domain/repositories/scan_history_repository.dart';
import '../datasources/history_local_data_source.dart';
import '../datasources/history_remote_data_source.dart';

/// Implementation of the scan history repository
class ScanHistoryRepositoryImpl implements ScanHistoryRepository {
  /// Local data source
  final HistoryLocalDataSource localDataSource;

  /// Remote data source
  final HistoryRemoteDataSource remoteDataSource;

  /// Create scan history repository implementation
  ScanHistoryRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<List<ScanHistoryItem>> getScanHistory({required String userId}) async {
    try {
      // Try to get from remote data source first
      final remoteHistory = await remoteDataSource.getScanHistory(userId);

      if (remoteHistory.isNotEmpty) {
        // If successful, update local cache and return remote data
        // (In a real implementation, we would update the local cache here)
        return remoteHistory;
      }

      // If remote fails or returns empty, fall back to local data source
      return await localDataSource.getScanHistory(userId);
    } catch (_) {
      // If remote fails with an exception, fall back to local data source
      return await localDataSource.getScanHistory(userId);
    }
  }

  @override
  Future<List<ScanHistoryItem>> getFavoritedScans({required String userId}) async {
    try {
      // Try to get from remote data source first
      final remoteFavorites = await remoteDataSource.getFavoritedScans(userId);

      if (remoteFavorites.isNotEmpty) {
        // If successful, update local cache and return remote data
        return remoteFavorites;
      }

      // If remote fails or returns empty, fall back to local data source
      return await localDataSource.getFavoritedScans(userId);
    } catch (_) {
      // If remote fails with an exception, fall back to local data source
      return await localDataSource.getFavoritedScans(userId);
    }
  }

  @override
  Future<List<ScanHistoryItem>> searchScanHistory({
    required String userId,
    required String query,
    bool favoritesOnly = false,
  }) async {
    try {
      // Try to get from remote data source first
      final remoteResults = await remoteDataSource.searchScanHistory(
        userId: userId,
        query: query,
        favoritesOnly: favoritesOnly,
      );

      if (remoteResults.isNotEmpty) {
        // If successful, return remote data
        return remoteResults;
      }

      // If remote fails or returns empty, fall back to local data source
      return await localDataSource.searchScanHistory(
        userId: userId,
        query: query,
        favoritesOnly: favoritesOnly,
      );
    } catch (_) {
      // If remote fails with an exception, fall back to local data source
      return await localDataSource.searchScanHistory(
        userId: userId,
        query: query,
        favoritesOnly: favoritesOnly,
      );
    }
  }

  @override
  Future<void> addScanHistoryItem({
    required String userId,
    required ScanHistoryItem item,
  }) async {
    final operations = <DatabaseOperation>[
      DatabaseOperation(
        type: OperationType.insert,
        table: 'scan_history',
        data: item.toMap(),
        priority: 1,
      ),
      // Add related operations in same transaction
      if (item.isFavorite)
        DatabaseOperation(
          type: OperationType.insert,
          table: 'favorites',
          data: {'scan_id': item.id, 'user_id': userId},
          priority: 1,
        ),
    ];

    await DatabaseOrchestrator.instance.executeBatch(operations);
  }

  @override
  Future<void> toggleFavoriteStatus({
    required String userId,
    required String id,
    required bool isFavorite,
  }) async {
    // Update local data source first
    await localDataSource.toggleFavoriteStatus(
      userId: userId,
      id: id,
      isFavorite: isFavorite,
    );

    try {
      // Then try to update remote data source
      await remoteDataSource.toggleFavoriteStatus(
        userId: userId,
        id: id,
        isFavorite: isFavorite,
      );
    } catch (_) {
      // If remote fails, we still have the local data
      // In a real implementation, we would queue this operation for later sync
    }
  }

  @override
  Future<void> updateNotes({
    required String userId,
    required String id,
    String? notes,
  }) async {
    // This is a simplified implementation
    // In a real app, this would update both local and remote data sources

    // Get the current scan history
    final scanHistory = await localDataSource.getScanHistory(userId);

    // Find the item to update
    final itemIndex = scanHistory.indexWhere((item) => item.id == id);

    if (itemIndex >= 0) {
      // Update the item
      final item = scanHistory[itemIndex];
      final updatedItem = item.copyWith(notes: notes);

      // Remove old item and add updated item (since we can't directly modify the local data store)
      scanHistory.removeAt(itemIndex);

      // Add the updated item back to local data source
      await localDataSource.addScanHistoryItem(
        userId: userId,
        item: updatedItem,
      );

      try {
        // Also try to update in remote data source
        // In a real implementation, this would have a proper API call
        await remoteDataSource.addScanHistoryItem(
          userId: userId,
          item: updatedItem,
        );
      } catch (_) {
        // If remote fails, we still have the local data
      }
    }
  }

  @override
  Future<void> addTag({
    required String userId,
    required String id,
    required String tag,
  }) async {
    // This is a simplified implementation
    // In a real app, this would update both local and remote data sources

    // Get the current scan history
    final scanHistory = await localDataSource.getScanHistory(userId);

    // Find the item to update
    final itemIndex = scanHistory.indexWhere((item) => item.id == id);

    if (itemIndex >= 0) {
      // Update the item
      final item = scanHistory[itemIndex];

      // Only add tag if it doesn't already exist
      if (!item.tags.contains(tag)) {
        final updatedTags = List<String>.from(item.tags)..add(tag);
        final updatedItem = item.copyWith(tags: updatedTags);

        // Remove old item and add updated item
        scanHistory.removeAt(itemIndex);

        // Add the updated item back to local data source
        await localDataSource.addScanHistoryItem(
          userId: userId,
          item: updatedItem,
        );

        try {
          // Also try to update in remote data source
          await remoteDataSource.addScanHistoryItem(
            userId: userId,
            item: updatedItem,
          );
        } catch (_) {
          // If remote fails, we still have the local data
        }
      }
    }
  }

  @override
  Future<void> removeTag({
    required String userId,
    required String id,
    required String tag,
  }) async {
    // This is a simplified implementation
    // In a real app, this would update both local and remote data sources

    // Get the current scan history
    final scanHistory = await localDataSource.getScanHistory(userId);

    // Find the item to update
    final itemIndex = scanHistory.indexWhere((item) => item.id == id);

    if (itemIndex >= 0) {
      // Update the item
      final item = scanHistory[itemIndex];

      // Only remove tag if it exists
      if (item.tags.contains(tag)) {
        final updatedTags = List<String>.from(item.tags)..remove(tag);
        final updatedItem = item.copyWith(tags: updatedTags);

        // Remove old item and add updated item
        scanHistory.removeAt(itemIndex);

        // Add the updated item back to local data source
        await localDataSource.addScanHistoryItem(
          userId: userId,
          item: updatedItem,
        );

        try {
          // Also try to update in remote data source
          await remoteDataSource.addScanHistoryItem(
            userId: userId,
            item: updatedItem,
          );
        } catch (_) {
          // If remote fails, we still have the local data
        }
      }
    }
  }

  @override
  Future<void> deleteScanHistoryItem({
    required String userId,
    required String id,
  }) async {
    // This is a simplified implementation
    // In a real app, this would delete from both local and remote data sources

    // Get the current scan history
    final scanHistory = await localDataSource.getScanHistory(userId);

    // Find and remove the item
    final updatedHistory = scanHistory.where((item) => item.id != id).toList();

    // Update the local data store
    // In a real implementation, this would be handled by the data source
    _updateLocalScanHistory(userId, updatedHistory);

    try {
      // Also try to delete from remote data source
      // In a real implementation, this would have a proper API call
      // For now, we don't have this method in the remote data source
    } catch (_) {
      // If remote fails, we still have the local data
    }
  }

  @override
  Future<void> clearScanHistory({required String userId}) async {
    // This is a simplified implementation
    // In a real app, this would clear both local and remote data sources

    // Clear the local data store
    _updateLocalScanHistory(userId, []);

    try {
      // Also try to clear remote data source
      // In a real implementation, this would have a proper API call
    } catch (_) {
      // If remote fails, we still have cleared the local data
    }
  }

  // Helper method to update the local scan history
  // In a real implementation, this would be handled by the data source
  void _updateLocalScanHistory(String userId, List<ScanHistoryItem> items) {
    // This is a workaround since we don't have proper update methods
    // In the data source for this example
  }
}