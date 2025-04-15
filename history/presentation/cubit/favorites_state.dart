import 'package:equatable/equatable.dart';
import '../../domain/entities/favorite_product.dart';

/// Favorites state
abstract class FavoritesState extends Equatable {
  /// Create favorites state
  const FavoritesState();

  @override
  List<Object?> get props => [];
}

/// Initial favorites state
class FavoritesInitial extends FavoritesState {}

/// Loading favorites state
class FavoritesLoading extends FavoritesState {}

/// Favorites loaded state
class FavoritesLoaded extends FavoritesState {
  /// List of favorite products
  final List<FavoriteProduct> favorites;
  
  /// List of categories
  final List<FavoriteCategory> categories;
  
  /// Selected category (null means all categories)
  final String? selectedCategoryId;
  
  /// Create favorites loaded state
  const FavoritesLoaded({
    required this.favorites,
    required this.categories,
    this.selectedCategoryId,
  });
  
  @override
  List<Object?> get props => [favorites, categories, selectedCategoryId];
  
  /// Create copy with modified fields
  FavoritesLoaded copyWith({
    List<FavoriteProduct>? favorites,
    List<FavoriteCategory>? categories,
    String? selectedCategoryId,
    bool clearSelectedCategory = false,
  }) {
    return FavoritesLoaded(
      favorites: favorites ?? this.favorites,
      categories: categories ?? this.categories,
      selectedCategoryId: clearSelectedCategory 
          ? null 
          : selectedCategoryId ?? this.selectedCategoryId,
    );
  }
}

/// Favorites error state
class FavoritesError extends FavoritesState {
  /// Error message
  final String message;
  
  /// Create favorites error state
  const FavoritesError(this.message);
  
  @override
  List<Object> get props => [message];
}

/// Favorites operation success state
class FavoritesOperationSuccess extends FavoritesState {
  /// Success message
  final String message;
  
  /// Updated product (if applicable)
  final FavoriteProduct? product;
  
  /// Create favorites operation success state
  const FavoritesOperationSuccess({
    required this.message,
    this.product,
  });
  
  @override
  List<Object?> get props => [message, product];
}

/// Favorites operation error state
class FavoritesOperationError extends FavoritesState {
  /// Error message
  final String message;
  
  /// Create favorites operation error state
  const FavoritesOperationError(this.message);
  
  @override
  List<Object> get props => [message];
}

/// Favorite category
class FavoriteCategory extends Equatable {
  /// Category ID
  final String id;
  
  /// Category name
  final String name;
  
  /// Category color (hex code)
  final String color;
  
  /// Create favorite category
  const FavoriteCategory({
    required this.id,
    required this.name,
    required this.color,
  });
  
  @override
  List<Object> get props => [id, name, color];
}

/// Default categories
class DefaultCategories {
  /// Uncategorized category
  static const uncategorized = FavoriteCategory(
    id: 'uncategorized',
    name: 'Uncategorized',
    color: '#9E9E9E',
  );
  
  /// Cleansers category
  static const cleansers = FavoriteCategory(
    id: 'cleansers',
    name: 'Cleansers',
    color: '#42A5F5',
  );
  
  /// Moisturizers category
  static const moisturizers = FavoriteCategory(
    id: 'moisturizers',
    name: 'Moisturizers',
    color: '#66BB6A',
  );
  
  /// Sunscreens category
  static const sunscreens = FavoriteCategory(
    id: 'sunscreens',
    name: 'Sunscreens',
    color: '#FFCA28',
  );
  
  /// Serums category
  static const serums = FavoriteCategory(
    id: 'serums',
    name: 'Serums',
    color: '#EC407A',
  );
  
  /// Treatments category
  static const treatments = FavoriteCategory(
    id: 'treatments',
    name: 'Treatments',
    color: '#AB47BC',
  );
  
  /// Get all default categories
  static List<FavoriteCategory> getAll() {
    return [
      uncategorized,
      cleansers,
      moisturizers,
      sunscreens,
      serums,
      treatments,
    ];
  }
}

/// HexColor utility for converting hex strings to Color objects
class HexColor extends Color {
  /// Create hex color from string
  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));

  /// Get color from hex string
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }
    return int.parse(hexColor, radix: 16);
  }
}