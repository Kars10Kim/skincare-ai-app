import '../entities/favorite_product.dart';
import '../repositories/favorites_repository.dart';

/// Get products by category use case
class GetProductsByCategory {
  /// Favorites repository
  final FavoritesRepository repository;
  
  /// Create get products by category use case
  GetProductsByCategory(this.repository);
  
  /// Execute use case
  Future<List<FavoriteProduct>> call({
    required String userId,
    required String categoryId,
  }) {
    return repository.getProductsByCategory(
      userId: userId,
      categoryId: categoryId,
    );
  }
}