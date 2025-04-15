import '../repositories/scan_history_repository.dart';

/// Toggle favorite status use case
class ToggleFavoriteStatus {
  /// Scan history repository
  final ScanHistoryRepository repository;
  
  /// Create toggle favorite status use case
  ToggleFavoriteStatus(this.repository);
  
  /// Execute use case
  Future<void> call({
    required String userId,
    required String id,
    required bool isFavorite,
  }) {
    return repository.toggleFavoriteStatus(
      userId: userId,
      id: id,
      isFavorite: isFavorite,
    );
  }
}