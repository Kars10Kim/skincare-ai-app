import '../entities/personalized_recommendation.dart';
import '../entities/product_analysis.dart';
import '../../../profile/domain/entities/user_profile.dart';

/// Repository for product recommendations
abstract class RecommendationRepository {
  /// Generate personalized recommendations
  /// 
  /// Takes a user profile and current product analysis to generate
  /// personalized product recommendations
  Future<List<PersonalizedRecommendation>> generateRecommendations({
    required UserProfile userProfile,
    required ProductAnalysis currentProduct,
    int limit = 5,
  });
  
  /// Get saved recommendations
  Future<List<PersonalizedRecommendation>> getSavedRecommendations();
  
  /// Save recommendation
  Future<void> saveRecommendation(PersonalizedRecommendation recommendation);
  
  /// Delete recommendation
  Future<void> deleteRecommendation(String id);
  
  /// Get alternative products for a specific ingredient
  Future<List<PersonalizedRecommendation>> getAlternativesForIngredient({
    required String ingredientName,
    required UserProfile userProfile,
    int limit = 5,
  });
  
  /// Dispose any resources
  void dispose();
}