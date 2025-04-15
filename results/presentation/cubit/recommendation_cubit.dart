import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/personalized_recommendation.dart';
import '../../domain/entities/product_analysis.dart';
import '../../domain/repositories/recommendation_repository.dart';
import '../../domain/usecases/generate_recommendations.dart';
import '../../../profile/domain/entities/user_profile.dart';

part 'recommendation_state.dart';

/// Cubit for recommendations
class RecommendationCubit extends Cubit<RecommendationState> {
  /// Generate recommendations use case
  final GenerateRecommendations _generateRecommendations;
  
  /// Recommendation repository
  final RecommendationRepository _repository;
  
  /// Create recommendation cubit
  RecommendationCubit({
    required GenerateRecommendations generateRecommendations,
    required RecommendationRepository repository,
  }) : _generateRecommendations = generateRecommendations,
       _repository = repository,
       super(RecommendationInitial());
  
  /// Generate recommendations
  Future<void> generateRecommendations({
    required UserProfile userProfile,
    required ProductAnalysis currentProduct,
    int limit = 5,
  }) async {
    try {
      emit(RecommendationLoading());
      
      final recommendations = await _generateRecommendations(
        userProfile: userProfile,
        currentProduct: currentProduct,
        limit: limit,
      );
      
      emit(RecommendationLoaded(recommendations: recommendations));
    } catch (e) {
      emit(RecommendationError(message: e.toString()));
    }
  }
  
  /// Get saved recommendations
  Future<void> getSavedRecommendations() async {
    try {
      emit(RecommendationLoading());
      
      final recommendations = await _repository.getSavedRecommendations();
      
      emit(RecommendationLoaded(recommendations: recommendations));
    } catch (e) {
      emit(RecommendationError(message: e.toString()));
    }
  }
  
  /// Save recommendation
  Future<void> saveRecommendation(PersonalizedRecommendation recommendation) async {
    try {
      await _repository.saveRecommendation(recommendation);
      
      if (state is RecommendationLoaded) {
        final recommendations = (state as RecommendationLoaded).recommendations;
        
        final index = recommendations.indexWhere((r) => r.id == recommendation.id);
        
        if (index != -1) {
          final updatedRecommendations = List<PersonalizedRecommendation>.from(recommendations);
          updatedRecommendations[index] = recommendation.copyWith(isSaved: true);
          
          emit(RecommendationLoaded(recommendations: updatedRecommendations));
        }
      }
    } catch (e) {
      emit(RecommendationError(message: e.toString()));
    }
  }
  
  /// Delete recommendation
  Future<void> deleteRecommendation(String id) async {
    try {
      await _repository.deleteRecommendation(id);
      
      if (state is RecommendationLoaded) {
        final recommendations = (state as RecommendationLoaded).recommendations;
        
        final index = recommendations.indexWhere((r) => r.id == id);
        
        if (index != -1) {
          final updatedRecommendations = List<PersonalizedRecommendation>.from(recommendations);
          updatedRecommendations[index] = recommendations[index].copyWith(isSaved: false);
          
          emit(RecommendationLoaded(recommendations: updatedRecommendations));
        }
      }
    } catch (e) {
      emit(RecommendationError(message: e.toString()));
    }
  }
  
  /// Get alternatives for ingredient
  Future<void> getAlternativesForIngredient({
    required String ingredientName,
    required UserProfile userProfile,
    int limit = 5,
  }) async {
    try {
      emit(RecommendationLoading());
      
      final alternatives = await _generateRecommendations.getAlternativesForIngredient(
        ingredientName: ingredientName,
        userProfile: userProfile,
        limit: limit,
      );
      
      emit(RecommendationLoaded(recommendations: alternatives));
    } catch (e) {
      emit(RecommendationError(message: e.toString()));
    }
  }
}