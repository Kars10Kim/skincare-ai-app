part of 'product_analysis_cubit.dart';

/// Base state for product analysis
abstract class ProductAnalysisState extends Equatable {
  /// Create product analysis state
  const ProductAnalysisState();
  
  @override
  List<Object?> get props => [];
}

/// Initial state
class ProductAnalysisInitial extends ProductAnalysisState {}

/// Loading state
class ProductAnalysisLoading extends ProductAnalysisState {}

/// List loading state
class ProductAnalysisListLoading extends ProductAnalysisState {}

/// Loaded state with single analysis
class ProductAnalysisLoaded extends ProductAnalysisState {
  /// Product analysis
  final ProductAnalysis analysis;
  
  /// Create loaded state
  const ProductAnalysisLoaded({required this.analysis});
  
  @override
  List<Object?> get props => [analysis];
}

/// Loaded state with list of analyses
class ProductAnalysisListLoaded extends ProductAnalysisState {
  /// List of product analyses
  final List<ProductAnalysis> analyses;
  
  /// Create list loaded state
  const ProductAnalysisListLoaded({required this.analyses});
  
  @override
  List<Object?> get props => [analyses];
}

/// Validating ingredient state
class ProductAnalysisValidatingIngredient extends ProductAnalysisState {
  /// Product analysis
  final ProductAnalysis analysis;
  
  /// Ingredient being validated
  final String ingredient;
  
  /// Create validating ingredient state
  const ProductAnalysisValidatingIngredient({
    required this.analysis,
    required this.ingredient,
  });
  
  @override
  List<Object?> get props => [analysis, ingredient];
}

/// Ingredient validated state
class ProductAnalysisIngredientValidated extends ProductAnalysisState {
  /// Product analysis
  final ProductAnalysis analysis;
  
  /// Validated ingredient
  final String ingredient;
  
  /// Scientific references
  final List<ScientificReference> references;
  
  /// Create ingredient validated state
  const ProductAnalysisIngredientValidated({
    required this.analysis,
    required this.ingredient,
    required this.references,
  });
  
  @override
  List<Object?> get props => [analysis, ingredient, references];
}

/// Error state
class ProductAnalysisError extends ProductAnalysisState {
  /// Error message
  final String message;
  
  /// Create error state
  const ProductAnalysisError({required this.message});
  
  @override
  List<Object?> get props => [message];
}