import '../entities/personalized_recommendation.dart';
import '../entities/product_analysis.dart';
import '../repositories/recommendation_repository.dart';
import '../../../profile/domain/entities/user_profile.dart';

/// Use case to generate personalized product recommendations
class GenerateRecommendations {
  /// Recommendation repository
  final RecommendationRepository repository;
  
  /// Create use case
  GenerateRecommendations({
    required this.repository,
  });
  
  /// Execute use case
  Future<List<PersonalizedRecommendation>> call({
    required UserProfile userProfile,
    required ProductAnalysis currentProduct,
    int limit = 5,
  }) async {
    return await repository.generateRecommendations(
      userProfile: userProfile,
      currentProduct: currentProduct,
      limit: limit,
    );
  }
  
  /// Get alternatives for a specific ingredient
  Future<List<PersonalizedRecommendation>> getAlternativesForIngredient({
    required String ingredientName,
    required UserProfile userProfile,
    int limit = 5,
  }) async {
    return await repository.getAlternativesForIngredient(
      ingredientName: ingredientName,
      userProfile: userProfile,
      limit: limit,
    );
  }
}