import '../entities/product_analysis.dart';
import '../entities/ingredient_conflict.dart';
import '../../../recognition/domain/entities/scan_history_item.dart';

/// Repository for product analysis
abstract class ProductAnalysisRepository {
  /// Analyze product safety
  /// 
  /// Takes a scan and analyzes the ingredients for conflicts
  Future<ProductAnalysis> analyzeProductSafety(ScanHistoryItem scan);
  
  /// Get the most recent analyses
  Future<List<ProductAnalysis>> getRecentAnalyses({int limit = 10});
  
  /// Get analysis by ID or barcode
  Future<ProductAnalysis?> getAnalysisById(String id);
  
  /// Save analysis
  Future<void> saveAnalysis(ProductAnalysis analysis);
  
  /// Update analysis
  Future<void> updateAnalysis(ProductAnalysis analysis);
  
  /// Delete analysis
  Future<void> deleteAnalysis(String id);
  
  /// Get conflicts for specific ingredients
  Future<List<IngredientConflict>> getConflictsForIngredients(List<String> ingredients);
  
  /// Get ingredient information
  Future<AnalyzedIngredient?> getIngredientInfo(String ingredientName);
  
  /// Get favorite analyses
  Future<List<ProductAnalysis>> getFavoriteAnalyses();
  
  /// Add analysis to favorites
  Future<void> addToFavorites(String id);
  
  /// Remove analysis from favorites
  Future<void> removeFromFavorites(String id);
  
  /// Dispose any resources
  void dispose();
}