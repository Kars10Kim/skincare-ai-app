import '../repositories/history_repository.dart';

/// Clear history use case
class ClearHistoryUseCase {
  /// History repository
  final HistoryRepository repository;
  
  /// Create clear history use case
  const ClearHistoryUseCase({required this.repository});
  
  /// Execute use case
  Future<void> call() async {
    return await repository.clearHistory();
  }
}