import '../entities/favorite_product.dart';
import '../repositories/favorites_repository.dart';

/// Get favorites use case
class GetFavoritesUseCase {
  /// Favorites repository
  final FavoritesRepository repository;
  
  /// Create get favorites use case
  const GetFavoritesUseCase({required this.repository});
  
  /// Execute use case to get all favorites
  Future<List<FavoriteProduct>> call() async {
    return await repository.getFavorites();
  }
  
  /// Execute use case to get favorites by category
  Future<List<FavoriteProduct>> callByCategory(FavoriteCategory category) async {
    return await repository.getFavoritesByCategory(category);
  }
}