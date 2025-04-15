import '../entities/product_analysis.dart';
import '../repositories/product_analysis_repository.dart';
import '../../../recognition/domain/entities/scan_history_item.dart';

/// Use case to analyze product safety
class AnalyzeProductSafety {
  /// Product analysis repository
  final ProductAnalysisRepository repository;
  
  /// Create use case
  AnalyzeProductSafety({
    required this.repository,
  });
  
  /// Execute use case
  Future<ProductAnalysis> call(ScanHistoryItem scan) async {
    return await repository.analyzeProductSafety(scan);
  }
}