import '../entities/favorite_product.dart';
import '../repositories/favorites_repository.dart';

/// Add favorite product use case
class AddFavoriteProduct {
  /// Favorites repository
  final FavoritesRepository repository;
  
  /// Create add favorite product use case
  AddFavoriteProduct(this.repository);
  
  /// Execute use case
  Future<void> call({
    required String userId,
    required FavoriteProduct product,
  }) {
    return repository.addFavoriteProduct(
      userId: userId,
      product: product,
    );
  }
}