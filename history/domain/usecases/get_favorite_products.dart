import '../entities/favorite_product.dart';
import '../repositories/favorites_repository.dart';

/// Get favorite products use case
class GetFavoriteProducts {
  /// Favorites repository
  final FavoritesRepository repository;
  
  /// Create get favorite products use case
  GetFavoriteProducts(this.repository);
  
  /// Execute use case
  Future<List<FavoriteProduct>> call({required String userId}) {
    return repository.getFavoriteProducts(userId: userId);
  }
}