part of 'recommendation_cubit.dart';

/// Base state for recommendations
abstract class RecommendationState extends Equatable {
  /// Create recommendation state
  const RecommendationState();
  
  @override
  List<Object?> get props => [];
}

/// Initial state
class RecommendationInitial extends RecommendationState {}

/// Loading state
class RecommendationLoading extends RecommendationState {}

/// Loaded state
class RecommendationLoaded extends RecommendationState {
  /// List of recommendations
  final List<PersonalizedRecommendation> recommendations;
  
  /// Create loaded state
  const RecommendationLoaded({required this.recommendations});
  
  @override
  List<Object?> get props => [recommendations];
}

/// Error state
class RecommendationError extends RecommendationState {
  /// Error message
  final String message;
  
  /// Create error state
  const RecommendationError({required this.message});
  
  @override
  List<Object?> get props => [message];
}