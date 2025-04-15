import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/ingredient_conflict.dart';
import '../../domain/entities/product_analysis.dart';
import '../../domain/entities/scientific_reference.dart';
import '../../domain/repositories/product_analysis_repository.dart';
import '../../domain/usecases/analyze_product_safety.dart';
import '../../domain/usecases/validate_scientific_claims.dart';
import '../../../recognition/domain/entities/scan_history_item.dart';

part 'product_analysis_state.dart';

/// Cubit for product analysis
class ProductAnalysisCubit extends Cubit<ProductAnalysisState> {
  /// Product analysis use case
  final AnalyzeProductSafety _analyzeProductSafety;
  
  /// Scientific claims validation use case
  final ValidateScientificClaims _validateScientificClaims;
  
  /// Product analysis repository
  final ProductAnalysisRepository _repository;
  
  /// Create product analysis cubit
  ProductAnalysisCubit({
    required AnalyzeProductSafety analyzeProductSafety,
    required ValidateScientificClaims validateScientificClaims,
    required ProductAnalysisRepository repository,
  }) : _analyzeProductSafety = analyzeProductSafety,
       _validateScientificClaims = validateScientificClaims,
       _repository = repository,
       super(ProductAnalysisInitial());
  
  /// Analyze product
  Future<void> analyzeProduct(ScanHistoryItem scan) async {
    try {
      emit(ProductAnalysisLoading());
      
      final analysis = await _analyzeProductSafety(scan);
      
      emit(ProductAnalysisLoaded(analysis: analysis));
    } catch (e) {
      emit(ProductAnalysisError(message: e.toString()));
    }
  }
  
  /// Validate ingredient
  Future<void> validateIngredient(String ingredient) async {
    try {
      if (state is ProductAnalysisLoaded) {
        emit(
          ProductAnalysisValidatingIngredient(
            analysis: (state as ProductAnalysisLoaded).analysis,
            ingredient: ingredient,
          ),
        );
        
        final references = await _validateScientificClaims.validateIngredient(ingredient);
        
        emit(
          ProductAnalysisIngredientValidated(
            analysis: (state as ProductAnalysisValidatingIngredient).analysis,
            ingredient: ingredient,
            references: references,
          ),
        );
      }
    } catch (e) {
      emit(ProductAnalysisError(message: e.toString()));
    }
  }
  
  /// Get analysis by ID
  Future<void> getAnalysisById(String id) async {
    try {
      emit(ProductAnalysisLoading());
      
      final analysis = await _repository.getAnalysisById(id);
      
      if (analysis != null) {
        emit(ProductAnalysisLoaded(analysis: analysis));
      } else {
        emit(ProductAnalysisError(message: 'Analysis not found'));
      }
    } catch (e) {
      emit(ProductAnalysisError(message: e.toString()));
    }
  }
  
  /// Get recent analyses
  Future<void> getRecentAnalyses({int limit = 10}) async {
    try {
      emit(ProductAnalysisListLoading());
      
      final analyses = await _repository.getRecentAnalyses(limit: limit);
      
      emit(ProductAnalysisListLoaded(analyses: analyses));
    } catch (e) {
      emit(ProductAnalysisError(message: e.toString()));
    }
  }
  
  /// Get favorite analyses
  Future<void> getFavoriteAnalyses() async {
    try {
      emit(ProductAnalysisListLoading());
      
      final analyses = await _repository.getFavoriteAnalyses();
      
      emit(ProductAnalysisListLoaded(analyses: analyses));
    } catch (e) {
      emit(ProductAnalysisError(message: e.toString()));
    }
  }
  
  /// Toggle favorite
  Future<void> toggleFavorite(String id) async {
    try {
      if (state is ProductAnalysisLoaded) {
        final analysis = (state as ProductAnalysisLoaded).analysis;
        
        if (analysis.id == id) {
          if (analysis.isFavorite) {
            await _repository.removeFromFavorites(id);
            
            emit(
              ProductAnalysisLoaded(
                analysis: analysis.copyWith(isFavorite: false),
              ),
            );
          } else {
            await _repository.addToFavorites(id);
            
            emit(
              ProductAnalysisLoaded(
                analysis: analysis.copyWith(isFavorite: true),
              ),
            );
          }
        }
      } else if (state is ProductAnalysisListLoaded) {
        final analyses = (state as ProductAnalysisListLoaded).analyses;
        final index = analyses.indexWhere((a) => a.id == id);
        
        if (index != -1) {
          final analysis = analyses[index];
          
          if (analysis.isFavorite) {
            await _repository.removeFromFavorites(id);
          } else {
            await _repository.addToFavorites(id);
          }
          
          // Update the list
          final updatedAnalyses = List<ProductAnalysis>.from(analyses);
          updatedAnalyses[index] = analysis.copyWith(
            isFavorite: !analysis.isFavorite,
          );
          
          emit(ProductAnalysisListLoaded(analyses: updatedAnalyses));
        }
      }
    } catch (e) {
      emit(ProductAnalysisError(message: e.toString()));
    }
  }
  
  /// Delete analysis
  Future<void> deleteAnalysis(String id) async {
    try {
      if (state is ProductAnalysisListLoaded) {
        await _repository.deleteAnalysis(id);
        
        final analyses = (state as ProductAnalysisListLoaded).analyses;
        final updatedAnalyses = analyses.where((a) => a.id != id).toList();
        
        emit(ProductAnalysisListLoaded(analyses: updatedAnalyses));
      }
    } catch (e) {
      emit(ProductAnalysisError(message: e.toString()));
    }
  }
}