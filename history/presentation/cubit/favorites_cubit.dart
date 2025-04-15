import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/favorite_product.dart';
import '../../domain/usecases/add_favorite_usecase.dart';
import '../../domain/usecases/get_favorites_usecase.dart';
import '../../domain/usecases/remove_favorite_usecase.dart';

/// Favorites state
abstract class FavoritesState extends Equatable {
  /// Create favorites state
  const FavoritesState();
  
  @override
  List<Object> get props => [];
}

/// Initial favorites state
class FavoritesInitial extends FavoritesState {}

/// Favorites loading state
class FavoritesLoading extends FavoritesState {}

/// Favorites loaded state
class FavoritesLoaded extends FavoritesState {
  /// List of favorite products
  final List<FavoriteProduct> favorites;
  
  /// Current selected category
  final FavoriteCategory? selectedCategory;
  
  /// Current search query
  final String? searchQuery;
  
  /// Create favorites loaded state
  const FavoritesLoaded({
    required this.favorites,
    this.selectedCategory,
    this.searchQuery,
  });
  
  /// Create a copy with new values
  FavoritesLoaded copyWith({
    List<FavoriteProduct>? favorites,
    FavoriteCategory? selectedCategory,
    String? searchQuery,
  }) {
    return FavoritesLoaded(
      favorites: favorites ?? this.favorites,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
  
  @override
  List<Object?> get props => [favorites, selectedCategory, searchQuery];
}

/// Favorites error state
class FavoritesError extends FavoritesState {
  /// Error message
  final String message;
  
  /// Create favorites error state
  const FavoritesError({required this.message});
  
  @override
  List<Object> get props => [message];
}

/// Favorites cubit
class FavoritesCubit extends Cubit<FavoritesState> {
  /// Get favorites use case
  final GetFavoritesUseCase getFavoritesUseCase;
  
  /// Add favorite use case
  final AddFavoriteUseCase addFavoriteUseCase;
  
  /// Remove favorite use case
  final RemoveFavoriteUseCase removeFavoriteUseCase;
  
  /// Create favorites cubit
  FavoritesCubit({
    required this.getFavoritesUseCase,
    required this.addFavoriteUseCase,
    required this.removeFavoriteUseCase,
  }) : super(FavoritesInitial());
  
  /// Load all favorites
  Future<void> loadFavorites() async {
    emit(FavoritesLoading());
    
    try {
      final favorites = await getFavoritesUseCase();
      emit(FavoritesLoaded(favorites: favorites));
    } catch (e) {
      emit(FavoritesError(message: e.toString()));
    }
  }
  
  /// Load favorites by category
  Future<void> loadFavoritesByCategory(FavoriteCategory category) async {
    emit(FavoritesLoading());
    
    try {
      final favorites = await getFavoritesUseCase.callByCategory(category);
      emit(FavoritesLoaded(
        favorites: favorites,
        selectedCategory: category,
      ));
    } catch (e) {
      emit(FavoritesError(message: e.toString()));
    }
  }
  
  /// Add to favorites
  Future<void> addToFavorites(FavoriteProduct favorite) async {
    try {
      final addedFavorite = await addFavoriteUseCase(favorite);
      
      final currentState = state;
      if (currentState is FavoritesLoaded) {
        final updatedFavorites = [...currentState.favorites, addedFavorite];
        final filteredFavorites = _applyFilters(
          updatedFavorites,
          currentState.selectedCategory,
          currentState.searchQuery,
        );
        
        emit(currentState.copyWith(favorites: filteredFavorites));
      } else {
        await loadFavorites();
      }
    } catch (e) {
      emit(FavoritesError(message: e.toString()));
    }
  }
  
  /// Remove from favorites
  Future<void> removeFromFavorites(String favoriteId) async {
    try {
      await removeFavoriteUseCase(favoriteId);
      
      final currentState = state;
      if (currentState is FavoritesLoaded) {
        final updatedFavorites = currentState.favorites
            .where((f) => f.id != favoriteId)
            .toList();
        
        emit(currentState.copyWith(favorites: updatedFavorites));
      }
    } catch (e) {
      emit(FavoritesError(message: e.toString()));
    }
  }
  
  /// Filter by category
  void filterByCategory(FavoriteCategory? category) async {
    final currentState = state;
    if (currentState is FavoritesLoaded) {
      if (category == null) {
        // Load all favorites
        await loadFavorites();
      } else {
        // Load favorites for the selected category
        await loadFavoritesByCategory(category);
      }
    }
  }
  
  /// Search favorites
  void searchFavorites(String query) async {
    final currentState = state;
    if (currentState is FavoritesLoaded) {
      // Load all favorites first
      final allFavorites = await getFavoritesUseCase();
      
      final filteredFavorites = _applyFilters(
        allFavorites,
        currentState.selectedCategory,
        query,
      );
      
      emit(currentState.copyWith(
        favorites: filteredFavorites,
        searchQuery: query,
      ));
    }
  }
  
  /// Reset search
  void resetSearch() async {
    final currentState = state;
    if (currentState is FavoritesLoaded) {
      if (currentState.selectedCategory != null) {
        await loadFavoritesByCategory(currentState.selectedCategory!);
      } else {
        await loadFavorites();
      }
    }
  }
  
  /// Apply filters to favorites
  List<FavoriteProduct> _applyFilters(
    List<FavoriteProduct> favorites,
    FavoriteCategory? selectedCategory,
    String? searchQuery,
  ) {
    var filteredFavorites = List<FavoriteProduct>.from(favorites);
    
    // Apply category filter
    if (selectedCategory != null) {
      filteredFavorites = filteredFavorites
          .where((favorite) => favorite.category == selectedCategory)
          .toList();
    }
    
    // Apply search query
    if (searchQuery != null && searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filteredFavorites = filteredFavorites.where((favorite) {
        // Search in product name
        if (favorite.product.name.toLowerCase().contains(query)) {
          return true;
        }
        
        // Search in brand
        if (favorite.product.brand != null &&
            favorite.product.brand!.toLowerCase().contains(query)) {
          return true;
        }
        
        // Search in category
        if (favorite.product.category != null &&
            favorite.product.category!.toLowerCase().contains(query)) {
          return true;
        }
        
        // Search in ingredients
        if (favorite.product.ingredients.any((i) => i.toLowerCase().contains(query))) {
          return true;
        }
        
        // Search in notes
        if (favorite.notes != null && favorite.notes!.toLowerCase().contains(query)) {
          return true;
        }
        
        // Search in tags
        if (favorite.tags.any((t) => t.toLowerCase().contains(query))) {
          return true;
        }
        
        return false;
      }).toList();
    }
    
    return filteredFavorites;
  }
}